const fs = require('fs');
const axios = require('axios');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function checkAirdropElysCoin() {
  try {
    const jsonData = fs.readFileSync('../oliver.json', 'utf8');
    const data = JSON.parse(jsonData);
    let totalAmount = 0;
    let totalWallet = 0
    const csvRows = [];
    csvRows.push("Name,Atom Address,Elys Address,Amount");
    const elysWallets = [];

    for (let i = 0; i < data.length; i++) {
      const atom = data[i].address;
      const elys = data[i].elys;

      const url = `https://rest.elys.network/chain`;
      try {
        const response = await axios.post(url, {
          type: "module",
          module: "elys.commitment.airDrop",
          data: {
            address: elys,
          }
        });

        if (response.data) {
          const item = response.data || {};
          const atomStaking = parseFloat(item.atomStaking || "0") / 1_000_000;
          const cadet = parseFloat(item.cadet || "0") / 1_000_000;
          const nftHolder = parseFloat(item.nftHolder || "0") / 1_000_000;
          const governor = parseFloat(item.governor || "0") / 1_000_000;

          const totalForUser = atomStaking + cadet + nftHolder + governor;
          totalAmount += totalForUser;
          if (totalForUser > 0) {
            totalWallet = totalWallet + 1;
            elysWallets.push({ address: elys });
          }
          csvRows.push(`Oliver ${i+1},${atom},${elys},${totalForUser.toFixed(2)}`);
          console.log(`Oliver ${i+1}: ${elys}, Total for user: ${totalForUser.toFixed(2)}`);
        } else {
          console.error(`Error: Unable to fetch balance for elys ${elys}`);
        }
      } catch (error) {
        if (error.response && error.response.status === 404) {
          console.error(`User not found for elys: ${elys}`);
        } else {
          console.error(`Error fetching data for elys ${elys}:`, error.message);
        }
      }
      await sleep(300);
    }
    csvRows.push(`Total,,,${totalAmount.toFixed(2)} Elys`);
    csvRows.push(`Total Wallets,,,${totalWallet}`);

    const csvContent = csvRows.join("\n");
    fs.writeFileSync('check-elys.csv', csvContent);
    fs.writeFileSync('../elys.json', JSON.stringify(elysWallets, null, 2));

    console.log("CSV file created successfully!");
    console.log(`Total Wallet: ${totalWallet}`);
    console.log(`Total Airdrop Amount: ${totalAmount.toFixed(2)}`);
  } catch (error) {
    console.error("An error occurred while reading the file or parsing JSON:", error);
  }
}

checkAirdropElysCoin();
