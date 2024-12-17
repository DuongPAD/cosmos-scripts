const fs = require('fs');
const axios = require('axios');

async function checkAirdropElysCoin() {
  try {
    const jsonData = fs.readFileSync('../oliver.json', 'utf8');
    const data = JSON.parse(jsonData);
    let csvContent = "address,balance\n";
    console.log('data.length:', data.length);

    for (let i = 0; i < data.length; i++) {
      console.log('i:', i);
      const elys = data[i].elys;
      console.log('elys:', elys);

      const url = `https://airdrop-checker-44ov7.ondigitalocean.app/user/${elys}`;

      try {
        const response = await axios.get(url);

        if (response.data?.success) {
          console.log('response.data:', response.data);
          const address = data[i].address || elys;
          csvContent += `${address},${response.data.item?.total_balance || 0}\n`;
          fs.appendFileSync('check-elys.csv', `${address},${response.data.item?.total_balance || 0}\n`);
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
    }
    console.log("CSV file created successfully!");
  } catch (error) {
    console.error("An error occurred while reading the file or parsing JSON:", error);
  }
}

checkAirdropElysCoin();
