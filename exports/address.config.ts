import { mainnet, polygon } from 'viem/chains';
import { Address, zeroAddress } from 'viem';

export interface ChainAddress {
	leverageMorphoFactory: Address;
}

export const ADDRESS: Record<number, ChainAddress> = {
	[mainnet.id]: {
		leverageMorphoFactory: '0xf58938ffB91301c1d34c5Aab76054f152fFD608c',
	},
};
