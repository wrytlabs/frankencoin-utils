// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILeadrate {
	event RateProposed(address who, uint24 nextRate, uint40 nextChange);
	event RateChanged(uint24 newRate);

	function equity() external view returns (address);

	function currentRatePPM() external view returns (uint24);

	function nextRatePPM() external view returns (uint24);

	function nextChange() external view returns (uint40);

	function proposeChange(uint24 newRatePPM_, address[] calldata helpers) external;

	function applyChange() external;

	function currentTicks() external view returns (uint64);

	function ticks(uint256 timestamp) external view returns (uint64);
}
