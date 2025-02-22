import { Address } from 'viem';

export type DeploymentParams = {
	zchf: Address;
	savings: Address;
	name: string;
	symbol: string;
};

export const params: DeploymentParams = {
	zchf: '0xB58E61C3098d85632Df34EecfB899A1Ed80921cB',
	savings: '0x3BF301B0e2003E75A3e86AB82bD1EFF6A9dFB2aE',
	name: 'Savings Token for Frankencoin ZCHF',
	symbol: 'stZCHF',
};

export type ConstructorArgs = [Address, Address, string, string];

export const args: ConstructorArgs = [params.zchf, params.savings, params.name, params.symbol];
