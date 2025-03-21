// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {IUniswapV2Router} from './interfaces/IUniswapV2Router.sol';

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
			0xE592427A0AEce92De3Edee1F18E0157C05861564, // uniswap
			msg.sender
		);
	}
}

contract LeverageMorpho is Ownable, IMorphoFlashLoanCallback {
	IMorpho private immutable morpho;
	IERC20 public immutable loan;
	IERC20 public immutable collateral;
	IUniswapV2Router public immutable uniswap;

	// opcodes
	uint8 private constant INCREASE_LEVERAGE = 0;
	uint8 private constant DECREASE_LEVERAGE = 1;

	// vars
	MarketParams public market;

	// events
	event Swapped(uint256 loanTknAmount, uint256 collTknAmount, bool direction, uint256 oraclePrice);

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
		uniswap = IUniswapV2Router(_uniswap);
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

	function repay(
		uint256 fromWallet,
		uint256 assets
	) public onlyOwner returns (uint256 assetsRepaid, uint256 sharesRepaid) {
		if (fromWallet > 0) loan.transferFrom(msg.sender, address(this), assets); // needs allowance
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
		uint256 fromWallet,
		uint256 assets,
		address[] calldata path,
		uint256 minAmountOut
	) external onlyOwner {
		// path encoding checks
		if (path.length < 2) revert WrongEncodePathInputs();
		if (path[0] != address(loan)) revert WrongInputToken(path[0], address(loan));
		if (path[path.length - 1] != address(collateral))
			revert WrongOutputToken(path[path.length - 1], address(collateral));

		// claim first additional buffer
		if (fromWallet > 0) {
			collateral.transferFrom(msg.sender, address(this), fromWallet); // needs allowance
		}

		// flashloan with data
		bytes memory data = abi.encode(INCREASE_LEVERAGE, path, minAmountOut);
		morpho.flashLoan(address(loan), assets, data);
	}

	// ---------------------------------------------------------------------------------------

	function decrease(
		uint256 fromWallet,
		uint256 assets,
		address[] calldata path,
		uint256 minAmountOut
	) external onlyOwner {
		// path encoding checks
		// if (path.length < 2) revert WrongEncodePathInputs();
		// if (path[0] != address(loan)) revert WrongInputToken(path[0], address(loan));
		// if (path[path.length - 1] != address(collateral))
		// 	revert WrongOutputToken(path[path.length - 1], address(collateral));
		// // claim first additional buffer
		// if (fromWallet > 0) {
		// 	collateral.transferFrom(msg.sender, address(this), fromWallet); // needs allowance
		// }
		// // flashloan with data
		// bytes memory data = abi.encode(INCREASE_LEVERAGE, path, minAmountOut);
		// morpho.flashLoan(address(loan), assets, data);
	}

	// ---------------------------------------------------------------------------------------

	function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {
		if (msg.sender != address(morpho)) revert NotMorpho();

		// make available for event
		uint[] memory amounts;

		// decode
		(uint8 opcode, address[] memory path, uint256 minAmountOut) = abi.decode(data, (uint8, address[], uint256));

		if (opcode == INCREASE_LEVERAGE) {
			// swap flashloan loan --> collateral
			amounts = uniswap.swapExactTokensForTokens(
				assets,
				minAmountOut,
				path,
				address(this),
				block.timestamp + 600
			);

			// supply
			// uint256 collateralAmount = amounts[amounts.length - 1];
			uint256 collateralAmount = collateral.balanceOf(address(this)); // includes ERC20 Transfers
			_supplyCollateral(collateralAmount);

			// borrow for flashloan repayment
			_borrow(assets, false);

			// flashloan token is loan token
			loan.approve(address(morpho), assets);
		} else if (opcode == DECREASE_LEVERAGE) {
			// swap flashloan collateral --> loan
			amounts = uniswap.swapExactTokensForTokens(
				assets,
				minAmountOut,
				path,
				address(this),
				block.timestamp + 600
			);

			// uint256 collateralAmount = amounts[amounts.length - 1];
			uint256 loanAmount = loan.balanceOf(address(this)); // includes ERC20 Transfers
			_repay(loanAmount);

			// borrow for flashloan repayment
			_withdrawCollateral(assets, false);

			// flashloan token is loan token
			collateral.approve(address(morpho), assets);
		} else revert InvalidOpcode(opcode);
	}
}
