// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPositionV2} from './IPositionV2.sol';

interface IMintingHubV2Bidder {
	struct Challenge {
		address challenger;
		uint40 start;
		IPositionV2 position;
		uint256 size;
	}

	function challenges(uint256 index) external view returns (address, uint64, IPositionV2, uint256);

	function pendingReturns(address collateral, address owner) external view returns (uint256);

	function challenge(
		address _positionAddr,
		uint256 _collateralAmount,
		uint256 minimumPrice
	) external returns (uint256);

	function bid(uint32 _challengeNumber, uint256 size, bool postponeCollateralReturn) external;

	function price(uint32 challengeNumber) external view returns (uint256);

	function returnPostponedCollateral(address collateral, address target) external;

	function expiredPurchasePrice(IPositionV2 pos) external view returns (uint256);

	function buyExpiredCollateral(IPositionV2 pos, uint256 upToAmount) external returns (uint256);
}
