import { toHex, fromBech32, toBech32, fromHex } from "@cosmjs/encoding";
import fs from "fs";

const convertWallet = async () => {
    const jsonData = fs.readFileSync('../oliver.json');
    const data = JSON.parse(jsonData);

    for (let index = 0; index < data.length; index++) {
        const element = data[index];
        const cosmosWallet = element.address;

        const hex = toHex(fromBech32(cosmosWallet).data);
        const neutronWallet = toBech32("neutron", fromHex(hex));

        element.neutron = neutronWallet;

        console.log('wallet', index + 1);
        console.log('cosmos_wallet', element.address);
        console.log('osmosis_wallet', element.osmosis);
        console.log('neutron_wallet', neutronWallet);
        console.log('==================================================');

        fs.writeFileSync('../oliver.json', JSON.stringify(data, null, 2));
    }
};

convertWallet()