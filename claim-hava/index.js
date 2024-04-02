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

      const url = "https://havacoin.xyz/api/v2/opt-in";
      const payload = { cosmos: address };

      const response = await axios.put(url, payload);
      console.log('response.data: ', response.data);

      if (response && response.status === 200) {
        console.log('done: ', address);
      } else {
        console.error(`Error: ${address}`);
      }
    }
    console.log("CSV file created successfully!");
  } catch (error) {
    console.error("An error occurred:", error);
  }
}

checkAirdropHavaCoin();
