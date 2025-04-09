// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IPositionV2.sol';

interface IPositionRoller {
	event Roll(address source, uint256 collWithdraw, uint256 repay, address target, uint256 collDeposit, uint256 mint);

	function rollFully(IPositionV2 source, IPositionV2 target) external;

	function rollFullyWithExpiration(IPositionV2 source, IPositionV2 target, uint40 expiration) external;

	function findRepaymentAmount(IPositionV2 pos) external view returns (uint256);

	function roll(
		IPositionV2 source,
		uint256 repay,
		uint256 collWithdraw,
		IPositionV2 target,
		uint256 mint,
		uint256 collDeposit,
		uint40 expiration
	) external;
}
