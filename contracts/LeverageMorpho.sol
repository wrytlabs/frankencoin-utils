// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {IUniswapV2Router} from './interfaces/IUniswapV2Router.sol';

import {IMorpho, MarketParams} from './morpho/IMorpho.sol';
import {IMorphoFlashLoanCallback} from './morpho/IMorphoCallbacks.sol';

contract LeverageMorpho is Ownable, IMorphoFlashLoanCallback {
	using SafeERC20 for IERC20;

	IMorpho private immutable morpho;
	IERC20 public immutable loan;
	IERC20 public immutable collateral;
	IUniswapV2Router public immutable uniswap;

	// opcodes
	uint8 private constant INCREASE_LEVERAGE = 0;
	uint8 private constant DECREASE_LEVERAGE = 1;

	// vars
	MarketParams public market;

	// errors
	error NotMorpho();
	error Invalid();
	error InvalidOpcode(uint8 given);
	error WrongEncodePathInputs();
	error WrongInputToken(address input, address needed);
	error WrongOutputToken(address output, address needed);

	constructor(
		IMorpho _morpho,
		IERC20 _loan,
		IERC20 _collateral,
		IUniswapV2Router _uniswap,
		address _owner
	) Ownable(_owner) {
		morpho = _morpho;
		loan = _loan;
		collateral = _collateral;
		uniswap = _uniswap;
	}

	// ---------------------------------------------------------------------------------------

	function setMarketId(MarketParams memory marketParams) public onlyOwner {
		market = marketParams;
	}

	// ---------------------------------------------------------------------------------------

	function supply(uint256 assets) external onlyOwner returns (uint256 assetsSupplied, uint256 sharesSupplied) {
		collateral.transferFrom(msg.sender, address(this), assets); // needs allowance
		return _supply(assets);
	}

	function _supply(uint256 assets) internal returns (uint256 assetsSupplied, uint256 sharesSupplied) {
		collateral.approve(address(morpho), assets);
		(assetsSupplied, sharesSupplied) = morpho.supply(market, assets, 0, address(this), new bytes(0));
	}

	// ---------------------------------------------------------------------------------------

	function withdraw(
		uint256 assets,
		bool fromMarket,
		bool fromContract
	) external onlyOwner returns (uint256 assetsWithdrawn, uint256 sharesWithdrawn) {
		return _withdraw(assets, fromMarket, fromContract);
	}

	function _withdraw(
		uint256 assets,
		bool fromMarket,
		bool fromContract
	) internal returns (uint256 assetsWithdrawn, uint256 sharesWithdrawn) {
		if (fromMarket) {
			(assetsWithdrawn, sharesWithdrawn) = morpho.withdraw(market, assets, 0, address(this), msg.sender);
		}

		if (fromContract) {
			collateral.transfer(msg.sender, assets);
		}
	}

	// ---------------------------------------------------------------------------------------

	function borrow(uint256 assets) public onlyOwner returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		return _borrow(assets);
	}

	function _borrow(uint256 assets) internal returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		(assetsBorrowed, sharesBorrowed) = morpho.borrow(market, assets, 0, address(this), address(this));
	}

	// ---------------------------------------------------------------------------------------

	function repay(uint256 assets) public onlyOwner returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		return _repay(assets);
	}

	function _repay(uint256 assets) internal returns (uint256 assetsBorrowed, uint256 sharesBorrowed) {
		(assetsBorrowed, sharesBorrowed) = morpho.borrow(market, assets, 0, address(this), address(this));
	}

	// ---------------------------------------------------------------------------------------

	function increase(
		uint256 fromWallet,
		uint256 assets,
		address[] calldata path,
		uint256 minAmountOut
	) external onlyOwner {
		if (path.length < 2) revert WrongEncodePathInputs();
		if (path[0] != address(loan)) revert WrongInputToken(path[0], address(loan));
		if (path[path.length - 1] != address(collateral))
			revert WrongOutputToken(path[path.length - 1], address(collateral));

		// claim first additional buffer
		if (fromWallet > 0) {
			collateral.transferFrom(msg.sender, address(this), fromWallet); // needs allowance
		}

		bytes memory data = abi.encode(INCREASE_LEVERAGE, path, minAmountOut);
		morpho.flashLoan(address(loan), assets, data);
	}

	function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {
		if (msg.sender != address(morpho)) revert NotMorpho();

		// decode
		(uint8 opcode, address[] memory path, uint256 minAmountOut) = abi.decode(data, (uint8, address[], uint256));

		if (opcode == INCREASE_LEVERAGE) {
			// flashloan token is loan token
			loan.approve(address(uniswap), assets);

			// swap
			uint[] memory amounts = uniswap.swapExactTokensForTokens(
				assets,
				minAmountOut,
				path,
				address(this),
				block.timestamp + 30
			);

			// supply
			// uint256 collateralAmount = amounts[amounts.length - 1];
			uint256 collateralAmount = collateral.balanceOf(address(this)); // includes ERC20 Transfers
			_supply(collateralAmount);

			// borrow
		} else if (opcode == DECREASE_LEVERAGE) {} else revert InvalidOpcode(opcode);

		// IERC20(token).approve(address(morpho), assets);
	}
}
