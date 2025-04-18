// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';
import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {ISavings} from './frankencoin/ISavings.sol';

contract SavingsToken is ERC20 {
	using Math for uint256;
	using SafeERC20 for IERC20;

	IERC20 public immutable zchf;
	ISavings public immutable savings;

	uint256 public totalClaimed;
	uint256 public price = 1 ether;

	// ---------------------------------------------------------------------------------------

	event Saved(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 price);
	event Withdrawn(address indexed saver, uint256 amountIn, uint256 amountOut, uint256 price);

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
		saveTo(msg.sender, amount);
	}

	function saveTo(address account, uint256 amount) public {
		uint256 interest = uint256(savings.accruedInterest(address(this)));

		if (interest > 0 && totalSupply() > 0) {
			totalClaimed += interest;
			price += (interest * 1 ether) / totalSupply();
		} else {
			// to reset params to initial values
			totalClaimed = 0;
			price = 1 ether;
		}

		zchf.safeTransferFrom(msg.sender, address(this), amount);
		savings.save(uint192(amount));

		uint256 amountOut = (amount * 1 ether) / price;
		_mint(account, amountOut);

		emit Saved(account, amount, amountOut, price);
	}

	// ---------------------------------------------------------------------------------------
	// input token is stZCHF, output token is ZCHF

	function withdraw(uint256 amount) public {
		withdrawTo(msg.sender, amount);
	}

	function withdrawTo(address target, uint256 amount) public {
		uint256 interest = uint256(savings.accruedInterest(address(this)));

		if (interest > 0 && totalSupply() > 0) {
			totalClaimed += interest;
			price += (interest * 1 ether) / totalSupply();
		}

		_burn(msg.sender, amount);

		uint256 amountOut = (amount * price) / 1 ether;
		amountOut = savings.withdraw(target, totalSupply() == 0 ? type(uint192).max : uint192(amountOut));

		emit Withdrawn(target, amount, amountOut, price);
	}

	// ---------------------------------------------------------------------------------------
	// adjust by interests

	function priceAdjusted() public view returns (uint256) {
		uint256 totS = totalSupply();
		if (totS == 0) return price;
		uint256 interest = uint256(savings.accruedInterest(address(this)));
		return price + (interest * 1 ether) / totalSupply();
	}

	function totalBalance() public view returns (uint256) {
		return savings.savings(address(this)).saved + savings.accruedInterest(address(this));
	}

	function saverBalance(address account) public view returns (uint256) {
		uint256 totS = totalSupply();
		if (totS == 0) return 0;
		return (totalBalance() * balanceOf(account)) / totS;
	}

	function isUnlocked() public view returns (bool) {
		return savings.currentTicks() >= savings.savings(address(this)).ticks;
	}

	function untilUnlocked() public view returns (uint256) {
		if (isUnlocked()) return 0;
		uint256 diff = savings.savings(address(this)).ticks - savings.currentTicks();
		return (diff / savings.currentRatePPM());
	}
}
