import { toHex, fromBech32, toBech32, fromHex } from "@cosmjs/encoding";
import fs from "fs";

const convertWallet = async () => {
    const jsonData = fs.readFileSync('../oliver.json');
    const data = JSON.parse(jsonData);

    for (let index = 0; index < data.length; index++) {
        const element = data[index];
        const cosmosWallet = element.address;

        const hex = toHex(fromBech32(cosmosWallet).data);
        const elysWallet = toBech32("elys", fromHex(hex));

        element.elys = elysWallet;

        console.log('wallet', index + 1);
        console.log('elys_wallet', elysWallet);
        console.log('==================================================');
        fs.writeFileSync('../oliver.json', JSON.stringify(data, null, 2));
    }
};

convertWallet()