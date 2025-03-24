import { Address } from 'viem';

export type DeploymentParams = {
	morpho: Address;
	loan: Address;
	collateral: Address;
	oracle: Address;
	irm: Address;
	lltv: bigint;
	uniswap: Address;
	owner: Address;
};

export const params: DeploymentParams = {
	morpho: '0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb', // morpho
	loan: '0xdAC17F958D2ee523a2206206994597C13D831ec7', // loan USDT testing
	collateral: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // collateral WBTC
	oracle: '0x008bF4B1cDA0cc9f0e882E0697f036667652E1ef', // oracle
	irm: '0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC', // IRM
	lltv: BigInt(860000000000000000), // lltv
	uniswap: '0xE592427A0AEce92De3Edee1F18E0157C05861564', // uniswap router
	owner: '0x0170F42f224b99CcbbeE673093589c5f9691dd06',
};

export type ConstructorArgs = [Address, Address, Address, Address, Address, bigint, Address, Address];

export const args: ConstructorArgs = [
	params.morpho,
	params.loan,
	params.collateral,
	params.oracle,
	params.irm,
	params.lltv,
	params.uniswap,
	params.owner,
];
