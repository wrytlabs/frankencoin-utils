// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {IFrankencoin} from './frankencoin/IFrankencoin.sol';
import {IReserve} from './frankencoin/IReserve.sol';
import {ILeadrate} from './frankencoin/ILeadrate.sol';
import {ISavings} from './frankencoin/ISavings.sol';

contract SavingsToken is ERC20 {
	using Math for uint256;
	using SafeERC20 for IERC20;

	IERC20 public immutable zchf;
	ISavings public immutable savings;

	uint256 public totalSaved;
	uint256 public totalWithdrawn;
	uint256 public totalRewards;

	uint256 public refRatio = 1 ether;

	// ---------------------------------------------------------------------------------------

	event Saved(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 refRatio);
	event Withdrawn(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 refRatio);

	// ---------------------------------------------------------------------------------------
	// name: "Savings Token for Frankencoin ZCHF", symbol: "stZCHF"

	constructor(IERC20 _zchf, ISavings _savings, string memory name, string memory symbol) ERC20(name, symbol) {
		zchf = _zchf;
		savings = _savings;
	}

	// ---------------------------------------------------------------------------------------

	function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
		return interfaceId == type(ERC20).interfaceId;
	}

	// ---------------------------------------------------------------------------------------
	// input token is ZCHF, output token is stZCHF

	function save(uint256 amount) public {
		zchf.safeTransferFrom(msg.sender, address(this), amount);
		totalSaved += amount;

		uint256 interest = uint256(savings.accruedInterest(address(this)));
		totalRewards += interest;
		refRatio += (interest * 1 ether) / totalSupply();

		savings.save(uint192(amount));

		uint256 amountOut = (amount * 1 ether) / refRatio;
		_mint(msg.sender, amountOut);

		emit Saved(msg.sender, amount, amountOut, refRatio);
	}

	// ---------------------------------------------------------------------------------------
	// input token is stZCHF, output token is ZCHF

	function withdraw(uint256 amount) public {
		_burn(msg.sender, amount);
		totalWithdrawn += amount;

		uint256 interest = uint256(savings.accruedInterest(address(this)));
		totalRewards += interest;
		refRatio += (interest * 1 ether) / totalSupply();

		uint256 amountOut = amount * refRatio;
		savings.withdraw(msg.sender, uint192(amountOut));

		emit Withdrawn(msg.sender, amount, amountOut, refRatio);
	}
}

// contract stZCHF is SavingsToken {
// 	constructor()
// 		SavingsToken(
// 			IERC20(0x01a3F7FeC57F907cdaFc2be49D844a8259B066c0),
// 			ISavings(0x3E76D80f3531cfEb7C1b5F9a1A30Be6e9c182565),
// 			'Savings Token for Frankencoin ZCHF',
// 			'stZCHF'
// 		)
// 	{}
// }
