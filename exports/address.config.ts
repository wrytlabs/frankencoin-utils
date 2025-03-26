import { mainnet, polygon } from 'viem/chains';
import { Address, zeroAddress } from 'viem';

export interface ChainAddress {
	leverageMorphoFactory: Address;
}

export const ADDRESS: Record<number, ChainAddress> = {
	[mainnet.id]: {
		leverageMorphoFactory: '0x33dD53A0d5bb2E754e32d034F434bE85250a957D',
	},
};
