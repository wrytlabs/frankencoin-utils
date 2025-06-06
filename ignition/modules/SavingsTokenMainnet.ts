import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { storeConstructorArgs } from '../../helper/store.args';
import { args, params } from '../params/SavingsTokenMainnet'; // <-- check for correct import

export const NAME: string = 'SavingsToken'; // <-- check for correct contract
export const MOD: string = NAME + 'Module';
console.log(NAME);

// params
console.log('Imported Params:');
console.log(params);

// export args
storeConstructorArgs(NAME, args); // <-- check for correct file name
console.log('Constructor Args');
console.log(args);

// fail safe
process.exit();

export default buildModule(MOD, (m) => {
	return {
		[NAME]: m.contract(NAME, args),
	};
});
