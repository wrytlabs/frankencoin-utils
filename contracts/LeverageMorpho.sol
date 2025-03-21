// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

import {IMorpho, MarketParams} from './morpho/IMorpho.sol';
import {IMorphoFlashLoanCallback} from './morpho/IMorphoCallbacks.sol';

contract DeployerLeverageMorpho {
	LeverageMorpho public immutable provider;

	constructor() {
		provider = new LeverageMorpho(
			0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb, // morpho
			0xB58E61C3098d85632Df34EecfB899A1Ed80921cB, // loan
			0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // collateral
			0x2B397B78d26e763a4c599E77a5Ab5a224a64825b, // oracle
			0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC, // IRM
			860000000000000000, // lltv
			0xE592427A0AEce92De3Edee1F18E0157C05861564, // uniswap router
			msg.sender
		);
	}
}

contract LeverageMorpho is Ownable, IMorphoFlashLoanCallback {
	using Math for uint256;

	IMorpho private immutable morpho;
	IERC20 public immutable loan;
	IERC20 public immutable collateral;
	ISwapRouter public immutable uniswap;

	// opcodes
	uint8 private constant INCREASE_LEVERAGE = 0;
	uint8 private constant DECREASE_LEVERAGE = 1;

	// vars
	MarketParams public market;

	// events
	event Executed(uint8 opcode, uint256 flash, uint256 swapIn, uint256 swapOut, uint256 provided);

	// errors
	error NotMorpho();
	error Invalid();
	error InvalidOpcode(uint8 given);
	error WrongEncodePathInputs();
	error WrongInputToken(address input, address needed);
	error WrongOutputToken(address output, address needed);

	constructor(
		address _morpho,
		address _loan,
		address _collateral,
		address _oracle,
		address _irm,
		uint256 _lltv,
		address _uniswap,
		address _owner
	) Ownable(_owner) {
		morpho = IMorpho(_morpho);
		loan = IERC20(_loan);
		collateral = IERC20(_collateral);
		uniswap = ISwapRouter(_uniswap);
		market = MarketParams(_loan, _collateral, _oracle, _irm, _lltv);
	}

	// ---------------------------------------------------------------------------------------

	function setMarket(MarketParams memory marketParams) public onlyOwner {
		market = marketParams;
	}

	// ---------------------------------------------------------------------------------------

	function supplyCollateral(uint256 assets) external onlyOwner {
		collateral.transferFrom(msg.sender, address(this), assets); // needs allowance
		_supplyCollateral(assets);
	}

	function _supplyCollateral(uint256 assets) internal {
		collateral.approve(address(morpho), assets);
		morpho.supplyCollateral(market, assets, address(this), new bytes(0));
	}

	// ---------------------------------------------------------------------------------------

	function withdrawCollateral(uint256 assets) external onlyOwner {
		_withdrawCollateral(assets, true);
	}

	function _withdrawCollateral(uint256 assets, bool toWallet) internal {
		morpho.withdrawCollateral(market, assets, address(this), toWallet ? msg.sender : address(this));
	}

	function recover(address coin, address target, uint256 amount) public onlyOwner {
		IERC20(coin).transfer(target, amount);
	}

	// ---------------------------------------------------------------------------------------

	function borrow(uint256 assets) public onlyOwner returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		return _borrow(assets, true);
	}

	function _borrow(uint256 assets, bool toWallet) internal returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		(assetsBorrowed, sharesBorrowed) = morpho.borrow(
			market,
			assets,
			0,
			address(this),
			toWallet ? msg.sender : address(this)
		);
	}

	// ---------------------------------------------------------------------------------------

	function repay(uint256 assets) public onlyOwner returns (uint256 assetsRepaid, uint256 sharesRepaid) {
		loan.transferFrom(msg.sender, address(this), assets); // needs allowance
		return _repay(assets);
	}

	function _repay(uint256 assets) internal returns (uint256 assetsRepaid, uint256 sharesRepaid) {
		loan.approve(address(morpho), assets);
		(assetsRepaid, sharesRepaid) = morpho.repay(market, assets, 0, address(this), new bytes(0));
	}

	// ---------------------------------------------------------------------------------------

	function encodePath(address[] memory tokens, uint24[] memory fees) public pure returns (bytes memory) {
		if (tokens.length < 2 || tokens.length - 1 != fees.length) revert WrongEncodePathInputs();

		bytes memory path = new bytes(0);
		for (uint256 i = 0; i < fees.length; i++) {
			path = abi.encodePacked(path, tokens[i], fees[i]);
		}

		return abi.encodePacked(path, tokens[tokens.length - 1]);
	}

	// ---------------------------------------------------------------------------------------

	function increase(
		uint256 walletLoan, // add additional loan tkn
		uint256 walletColl, // add additional collateral tkn
		uint256 assets, // flashloan amount loan tkn
		address[] memory tokens,
		uint24[] memory fees,
		uint256 amountOutMinimum
	) external onlyOwner {
		// path encoding checks
		if (tokens.length < 2) revert WrongEncodePathInputs();
		if (tokens[0] != address(loan)) revert WrongInputToken(tokens[0], address(loan));
		if (tokens[tokens.length - 1] != address(collateral))
			revert WrongOutputToken(tokens[tokens.length - 1], address(collateral));

		// add additional funds
		if (walletLoan > 0) {
			loan.transferFrom(msg.sender, address(this), walletLoan); // needs allowance (loan tkn)
		}
		if (walletColl > 0) {
			collateral.transferFrom(msg.sender, address(this), walletColl); // needs allowance (coll tkn)
		}

		// perform flashloan with data
		bytes memory data = abi.encode(INCREASE_LEVERAGE, encodePath(tokens, fees), amountOutMinimum);
		morpho.flashLoan(address(loan), assets, data);
	}

	// ---------------------------------------------------------------------------------------

	function decrease(
		uint256 walletLoan, // add additional loan tkn
		uint256 walletColl, // add additional collateral tkn
		uint256 assets, // flashloan amount loan tkn
		address[] memory tokens,
		uint24[] memory fees,
		uint256 amountOutMinimum
	) external onlyOwner {
		// path encoding checks
		if (tokens.length < 2) revert WrongEncodePathInputs();
		if (tokens[0] != address(collateral)) revert WrongInputToken(tokens[0], address(collateral));
		if (tokens[tokens.length - 1] != address(loan))
			revert WrongOutputToken(tokens[tokens.length - 1], address(loan));

		// add additional funds
		if (walletLoan > 0) {
			loan.transferFrom(msg.sender, address(this), walletLoan); // needs allowance (loan tkn)
		}
		if (walletColl > 0) {
			collateral.transferFrom(msg.sender, address(this), walletColl); // needs allowance (coll tkn)
		}

		// perform flashloan with data
		bytes memory data = abi.encode(DECREASE_LEVERAGE, encodePath(tokens, fees), amountOutMinimum);
		morpho.flashLoan(address(loan), assets, data);
	}

	// ---------------------------------------------------------------------------------------

	function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {
		if (msg.sender != address(morpho)) revert NotMorpho();

		// make available for event
		uint256 amountOut;

		// decode
		(uint8 opcode, bytes memory path, uint256 amountOutMinimum) = abi.decode(data, (uint8, bytes, uint256));

		if (opcode == INCREASE_LEVERAGE) {
			// swap flashloan loan --> collateral
			uint256 amountIn = loan.balanceOf(address(this));
			ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
				path: path,
				recipient: address(this),
				deadline: block.timestamp + 600,
				amountIn: amountIn,
				amountOutMinimum: amountOutMinimum
			});

			// approve and execute swap
			loan.approve(address(uniswap), amountIn);
			amountOut = uniswap.exactInput(params);

			// supply collateral - includes any ERC20 Transfers from before
			uint256 collateralAmount = collateral.balanceOf(address(this));
			_supplyCollateral(collateralAmount);

			// borrow for flashloan repayment
			_borrow(assets, false);

			// flashloan token is loan token
			loan.approve(address(morpho), assets);

			emit Executed(INCREASE_LEVERAGE, assets, amountIn, amountOut, collateralAmount);
		} else if (opcode == DECREASE_LEVERAGE) {
			// swap flashloan collateral --> loan
			uint256 amountIn = collateral.balanceOf(address(this));
			ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
				path: path,
				recipient: address(this),
				deadline: block.timestamp + 600,
				amountIn: amountIn,
				amountOutMinimum: amountOutMinimum
			});

			// approve and execute swap
			collateral.approve(address(uniswap), amountIn);
			amountOut = uniswap.exactInput(params);

			// repay loan - includes any ERC20 Transfers from before
			uint256 repayAmount = loan.balanceOf(address(this));
			_repay(repayAmount);

			// withdraw collateral for flashloan repayment
			_withdrawCollateral(assets, false);

			// flashloan token is collateral token
			collateral.approve(address(morpho), assets);

			emit Executed(DECREASE_LEVERAGE, assets, amountIn, amountOut, repayAmount);
		} else revert InvalidOpcode(opcode);
	}
}
