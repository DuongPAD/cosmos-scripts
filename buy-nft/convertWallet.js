import { toHex, fromBech32, toBech32, fromHex } from "@cosmjs/encoding";
import fs from "fs";

const convertwallet = async () => {
    const jsonData = fs.readFileSync('../oliver.json')
    const data = JSON.parse(jsonData)
    const listStarsWallet = []
    for (let index = 0; index < data.length; index++) {
        const element = data[index];
        const cosmos_wallet = element.address
        const phrase = element.phrase
        const hex = toHex(fromBech32(cosmos_wallet).data);
        const stars_wallet = toBech32("stars", fromHex(hex))
        listStarsWallet.push({"address": stars_wallet, "phrase": phrase })
    }
    fs.writeFileSync('../stars.json', JSON.stringify(listStarsWallet, null, 2))
}

convertwallet()