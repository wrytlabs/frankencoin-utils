import { Address } from 'viem';

export type DeploymentParams = {
	morpho: Address;
	uniswap: Address;
	zchf: Address;
	hubV2: Address;
	owner: Address;
};

export const params: DeploymentParams = {
	morpho: '0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb', // morpho
	uniswap: '0xE592427A0AEce92De3Edee1F18E0157C05861564', // uniswap router
	zchf: '0xB58E61C3098d85632Df34EecfB899A1Ed80921cB',
	hubV2: '0xDe12B620A8a714476A97EfD14E6F7180Ca653557',
	owner: '0xbfE145DcFac110Df1efD27B403Dd68fd2C61494e',
};

export type ConstructorArgs = [Address, Address, Address, Address, Address];

export const args: ConstructorArgs = [params.morpho, params.uniswap, params.zchf, params.hubV2, params.owner];
