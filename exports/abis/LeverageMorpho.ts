export const LeverageMorphoABI = [
	{
		inputs: [
			{
				internalType: 'address',
				name: '_morpho',
				type: 'address',
			},
			{
				internalType: 'address',
				name: '_loan',
				type: 'address',
			},
			{
				internalType: 'address',
				name: '_collateral',
				type: 'address',
			},
			{
				internalType: 'address',
				name: '_oracle',
				type: 'address',
			},
			{
				internalType: 'address',
				name: '_irm',
				type: 'address',
			},
			{
				internalType: 'uint256',
				name: '_lltv',
				type: 'uint256',
			},
			{
				internalType: 'address',
				name: '_uniswap',
				type: 'address',
			},
			{
				internalType: 'address',
				name: '_owner',
				type: 'address',
			},
		],
		stateMutability: 'nonpayable',
		type: 'constructor',
	},
	{
		inputs: [],
		name: 'Invalid',
		type: 'error',
	},
	{
		inputs: [
			{
				internalType: 'uint8',
				name: 'given',
				type: 'uint8',
			},
		],
		name: 'InvalidOpcode',
		type: 'error',
	},
	{
		inputs: [],
		name: 'NotMorpho',
		type: 'error',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'owner',
				type: 'address',
			},
		],
		name: 'OwnableInvalidOwner',
		type: 'error',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'account',
				type: 'address',
			},
		],
		name: 'OwnableUnauthorizedAccount',
		type: 'error',
	},
	{
		inputs: [],
		name: 'WrongEncodePathInputs',
		type: 'error',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'input',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'needed',
				type: 'address',
			},
		],
		name: 'WrongInputToken',
		type: 'error',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'output',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'needed',
				type: 'address',
			},
		],
		name: 'WrongOutputToken',
		type: 'error',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: false,
				internalType: 'uint256',
				name: 'amount',
				type: 'uint256',
			},
			{
				indexed: false,
				internalType: 'bool',
				name: 'direction',
				type: 'bool',
			},
		],
		name: 'Collateral',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: false,
				internalType: 'uint8',
				name: 'opcode',
				type: 'uint8',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'flash',
				type: 'uint256',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'swapIn',
				type: 'uint256',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'swapOut',
				type: 'uint256',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'provided',
				type: 'uint256',
			},
		],
		name: 'Executed',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: false,
				internalType: 'uint256',
				name: 'amount',
				type: 'uint256',
			},
			{
				indexed: false,
				internalType: 'bool',
				name: 'direction',
				type: 'bool',
			},
		],
		name: 'Loan',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'previousOwner',
				type: 'address',
			},
			{
				indexed: true,
				internalType: 'address',
				name: 'newOwner',
				type: 'address',
			},
		],
		name: 'OwnershipTransferred',
		type: 'event',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
		],
		name: 'borrow',
		outputs: [
			{
				internalType: 'uint256',
				name: 'assetsBorrowed',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'sharesBorrowed',
				type: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address[]',
				name: 'tokens',
				type: 'address[]',
			},
			{
				internalType: 'uint24[]',
				name: 'fees',
				type: 'uint24[]',
			},
			{
				internalType: 'uint256',
				name: 'amountOutMinimum',
				type: 'uint256',
			},
		],
		name: 'close',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [],
		name: 'collateral',
		outputs: [
			{
				internalType: 'contract IERC20',
				name: '',
				type: 'address',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'walletLoan',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'walletColl',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
			{
				internalType: 'address[]',
				name: 'tokens',
				type: 'address[]',
			},
			{
				internalType: 'uint24[]',
				name: 'fees',
				type: 'uint24[]',
			},
			{
				internalType: 'uint256',
				name: 'amountOutMinimum',
				type: 'uint256',
			},
		],
		name: 'decrease',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address[]',
				name: 'tokens',
				type: 'address[]',
			},
			{
				internalType: 'uint24[]',
				name: 'fees',
				type: 'uint24[]',
			},
		],
		name: 'encodePath',
		outputs: [
			{
				internalType: 'bytes',
				name: '',
				type: 'bytes',
			},
		],
		stateMutability: 'pure',
		type: 'function',
	},
	{
		inputs: [
			{
				components: [
					{
						internalType: 'address',
						name: 'loanToken',
						type: 'address',
					},
					{
						internalType: 'address',
						name: 'collateralToken',
						type: 'address',
					},
					{
						internalType: 'address',
						name: 'oracle',
						type: 'address',
					},
					{
						internalType: 'address',
						name: 'irm',
						type: 'address',
					},
					{
						internalType: 'uint256',
						name: 'lltv',
						type: 'uint256',
					},
				],
				internalType: 'struct MarketParams',
				name: 'marketParams',
				type: 'tuple',
			},
		],
		name: 'getMarketId',
		outputs: [
			{
				internalType: 'bytes32',
				name: '',
				type: 'bytes32',
			},
		],
		stateMutability: 'pure',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'walletLoan',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'walletColl',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
			{
				internalType: 'address[]',
				name: 'tokens',
				type: 'address[]',
			},
			{
				internalType: 'uint24[]',
				name: 'fees',
				type: 'uint24[]',
			},
			{
				internalType: 'uint256',
				name: 'amountOutMinimum',
				type: 'uint256',
			},
		],
		name: 'increase',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [],
		name: 'loan',
		outputs: [
			{
				internalType: 'contract IERC20',
				name: '',
				type: 'address',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [],
		name: 'market',
		outputs: [
			{
				internalType: 'address',
				name: 'loanToken',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'collateralToken',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'oracle',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'irm',
				type: 'address',
			},
			{
				internalType: 'uint256',
				name: 'lltv',
				type: 'uint256',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
			{
				internalType: 'bytes',
				name: 'data',
				type: 'bytes',
			},
		],
		name: 'onMorphoFlashLoan',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [],
		name: 'owner',
		outputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'coin',
				type: 'address',
			},
			{
				internalType: 'address',
				name: 'target',
				type: 'address',
			},
			{
				internalType: 'uint256',
				name: 'amount',
				type: 'uint256',
			},
		],
		name: 'recover',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [],
		name: 'renounceOwnership',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
		],
		name: 'repay',
		outputs: [
			{
				internalType: 'uint256',
				name: 'assetsRepaid',
				type: 'uint256',
			},
			{
				internalType: 'uint256',
				name: 'sharesRepaid',
				type: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
		],
		name: 'supplyCollateral',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: 'newOwner',
				type: 'address',
			},
		],
		name: 'transferOwnership',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'assets',
				type: 'uint256',
			},
		],
		name: 'withdrawCollateral',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
] as const;
