// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPositionV2} from './IPositionV2.sol';
import {IFrankencoin} from './IFrankencoin.sol';
import {IPositionRoller} from './IPositionRoller.sol';

interface IMintingHubV2 {
	struct Challenge {
		address challenger;
		uint40 start;
		IPositionV2 position;
		uint256 size;
	}

	function zchf() external view returns (IFrankencoin);

	function roller() external view returns (IPositionRoller);

	function challenges(uint256 index) external view returns (Challenge memory);

	function pendingReturns(address collateral, address owner) external view returns (uint256);

	function openPosition(
		address _collateralAddress,
		uint256 _minCollateral,
		uint256 _initialCollateral,
		uint256 _mintingMaximum,
		uint40 _initPeriodSeconds,
		uint40 _expirationSeconds,
		uint40 _challengeSeconds,
		uint24 _riskPremium,
		uint256 _liqPrice,
		uint24 _reservePPM
	) external returns (address);

	function clone(
		address parent,
		uint256 _initialCollateral,
		uint256 _initialMint,
		uint40 expiration
	) external returns (address);

	function clone(
		address owner,
		address parent,
		uint256 _initialCollateral,
		uint256 _initialMint,
		uint40 expiration
	) external returns (address);

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
