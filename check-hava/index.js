const fs = require('fs');
const axios = require('axios');

async function checkAirdropHavaCoin() {
  try {
    const jsonData = fs.readFileSync('../oliver.json', 'utf8');
    const data = JSON.parse(jsonData);
    let csvContent = "address,balance\n";
    console.log('data.length: ', data.length);

    for (let i = 0; i < data.length; i++) {
      console.log('i: ', i);
      const address = data[i].address;

      const url = "https://havacoin.xyz/api/balance";
      const payload = { address };

      const response = await axios.post(url, payload);
      console.log('response.data: ', response.data);

      if (response && response.data?.success) {
        csvContent += `${address},${response.data?.item?.total_balance}\n`;

        fs.appendFileSync('check-havacoin.csv', `${address},${response.data?.item?.total_balance ? response.data?.item?.total_balance : 0}\n`);
      } else {
        console.error(`Error: Unable to fetch balance for address ${address}`);
      }
    }
    console.log("CSV file created successfully!");
  } catch (error) {
    console.error("An error occurred:", error);
  }
}

checkAirdropHavaCoin();
