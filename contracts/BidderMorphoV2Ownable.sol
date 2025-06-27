// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

import {IMorpho} from './morpho/IMorpho.sol';
import {IMorphoFlashLoanCallback} from './morpho/IMorphoCallbacks.sol';

import {IFrankencoin} from './frankencoin/IFrankencoin.sol';
import {IMintingHubV2Bidder} from './frankencoin/IMintingHubV2Bidder.sol';
import {IPositionV2} from './frankencoin/IPositionV2.sol';

/// @title BidderMorphoV2 - Ownable
/// @author @samclassix <samclassix@proton.me> @wrytlabs <wrytlabs@proton.me>
/// @notice Bidder contract for MintingHub V2 that uses Morpho flashloan to borrow assets,
/// performs arbitrage or liquidation via Uniswap, and captures profit from the spread.
contract BidderMorphoV2Ownable is Ownable, IMorphoFlashLoanCallback {
	using Math for uint256;
	using SafeERC20 for IERC20;

	// immutables
	IMorpho private immutable morpho;
	ISwapRouter private immutable uniswap;
	IERC20 private immutable zchf;
	IMintingHubV2Bidder private immutable hub;

	// private
	uint32 private _index;
	address private _collateral;
	uint256 private _size;
	bytes private _path;

	// events
	event Executed(address indexed collateral, uint256 flashBid, uint256 swapIn, uint256 swapOut);

	// errors
	error NotMorpho();
	error NoCollateral();
	error NoPrice();
	error WrongEncodePathInputs();

	// ---------------------------------------------------------------------------------------

	constructor(address _morpho, address _uniswap, address _zchf, address _hubV2, address _owner) Ownable(_owner) {
		morpho = IMorpho(_morpho);
		uniswap = ISwapRouter(_uniswap);
		zchf = IERC20(_zchf);
		hub = IMintingHubV2Bidder(_hubV2);
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
	// @dev: Path encoding should be performed off-chain.
	// The smart contract doesn't perform path validation checks,
	// as invalid paths will cause the transaction to revert anyway.

	function executeRaw(uint32 index, uint256 amount, address[] memory tokens, uint24[] memory fees) external {
		_path = encodePath(tokens, fees);
		_execute(index, amount);
	}

	function execute(uint32 index, uint256 amount, bytes memory path) external {
		_path = path;
		_execute(index, amount);
	}

	function _execute(uint32 index, uint256 amount) internal {
		// get challenge data
		(, , IPositionV2 position, uint256 size) = hub.challenges(index);
		if (size == 0) revert NoCollateral();

		// get auction price
		uint256 price = hub.price(index);
		if (price == 0) revert NoPrice();

		// conditional overwrite of coll. size
		if (amount > 0 && amount < size) size = amount;

		// calc flash amount
		uint256 assets = (size * price) / 1 ether;

		// store data
		_index = index;
		_collateral = address(position.collateral());
		_size = size;

		// flashLoan callback uses internal state; no data encoding needed
		bytes memory emptyData = new bytes(0);

		// execute zchf flash loan action
		morpho.flashLoan(address(zchf), assets, emptyData);

		// clear data
		delete _index;
		delete _collateral;
		delete _size;
		delete _path;
	}

	// ---------------------------------------------------------------------------------------

	function onMorphoFlashLoan(uint256 assets, bytes calldata /* data */) external {
		if (msg.sender != address(morpho)) revert NotMorpho();

		// take bid (loan --> collateral)
		hub.bid(_index, _size, false);

		// swap flashloan collateral --> loan
		ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
			path: _path,
			recipient: address(this),
			deadline: block.timestamp + 600,
			amountIn: _size,
			amountOutMinimum: assets // min. flashloan repayment
		});

		// forceApprove and execute swap
		IERC20(_collateral).forceApprove(address(uniswap), _size);
		uint256 amountOut = uniswap.exactInput(params);

		// transfer profit
		zchf.transfer(owner(), amountOut - assets);

		// forceApprove for flashloan repayment
		zchf.forceApprove(address(morpho), assets);

		// emits event
		emit Executed(_collateral, assets, _size, amountOut);
	}
}
