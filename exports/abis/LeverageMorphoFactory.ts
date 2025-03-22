export const LeverageMorphoFactoryABI = [
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'instance',
				type: 'address',
			},
			{
				indexed: true,
				internalType: 'address',
				name: 'owner',
				type: 'address',
			},
			{
				indexed: true,
				internalType: 'Id',
				name: 'marketId',
				type: 'bytes32',
			},
		],
		name: 'Created',
		type: 'event',
	},
	{
		inputs: [],
		name: '_morpho',
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
		inputs: [],
		name: '_uniswap',
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
				name: '_owner',
				type: 'address',
			},
		],
		name: 'create',
		outputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address',
			},
		],
		stateMutability: 'nonpayable',
		type: 'function',
	},
] as const;
