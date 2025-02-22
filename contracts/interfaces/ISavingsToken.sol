// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ISavings} from '../frankencoin/ISavings.sol';

interface ISavingsToken is IERC20 {
	// View functions
	function zchf() external view returns (IERC20);

	function savings() external view returns (ISavings);

	function totalClaimed() external view returns (uint256);

	function price() external view returns (uint256);

	function priceAdjusted() external view returns (uint256);

	function totalBalance() external view returns (uint256);

	function saverBalance(address account) external view returns (uint256);

	function isUnlocked() external view returns (bool);

	function untilUnlocked() external view returns (uint256);

	// State-changing functions
	function save(uint256 amount) external;

	function saveTo(address account, uint256 amount) external;

	function withdraw(uint256 amount) external;

	function withdrawTo(address target, uint256 amount) external;

	// Events
	event Saved(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 price);
	event Withdrawn(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 price);
}
