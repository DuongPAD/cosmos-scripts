const { DirectSecp256k1HdWallet } = require("@cosmjs/proto-signing");
const fs = require("fs");

const generateKey = async () => {
  const data = [];

  for (let index = 1; index < 20; index++) {
    const wallet = await DirectSecp256k1HdWallet.generate(12);
    const accounts = await wallet.getAccounts();

    const entry = {
      address: accounts[0].address,
      phrase: wallet.mnemonic,
    };

    data.push(entry);

  }

  // Lưu dữ liệu vào file JSON
  fs.writeFileSync("oliver.json", JSON.stringify(data, null, 2));
}

generateKey();
