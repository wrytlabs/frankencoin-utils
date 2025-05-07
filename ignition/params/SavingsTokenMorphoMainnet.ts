import { Address } from 'viem';

export type DeploymentParams = {
	morpho: Address;
	loan: Address;
	collateral: Address;
	oracle: Address;
	irm: Address;
	lltv: bigint;
	owner: Address;
};

export const params: DeploymentParams = {
	morpho: '0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb',
	loan: '0xB58E61C3098d85632Df34EecfB899A1Ed80921cB',
	collateral: '0x00e632728d5aB91fe8319760fFdD2D7362E28139',
	oracle: '0xf7418bC12c0A4Ed4d5D8697a269E9639247E17F9',
	irm: '0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC',
	lltv: BigInt(965000000000000000),
	owner: '0x0170F42f224b99CcbbeE673093589c5f9691dd06',
};

export type ConstructorArgs = [Address, Address, Address, Address, Address, bigint, Address];

export const args: ConstructorArgs = [
	params.morpho,
	params.loan,
	params.collateral,
	params.oracle,
	params.irm,
	params.lltv,
	params.owner,
];
