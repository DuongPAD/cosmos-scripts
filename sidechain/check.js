const fs = require('fs');
const axios = require('axios');
const path = require('path');

async function checkEligibility(filePath) {
  try {
    const walletsData = fs.readFileSync(filePath, 'utf8');
    const wallets = JSON.parse(walletsData);

    const concurrencyLimit = 50;
    const results = [];

    for (let i = 0; i < wallets.length; i += concurrencyLimit) {
      const batch = wallets.slice(i, i + concurrencyLimit);

      const batchResults = await Promise.all(
        batch.map(async (wallet) => {
          const address = wallet.address;

          try {
            const response = await axios.get(
              `https://airdrop-api.side.one/airdrop/login/checkEligibility?address=${address}`
            );

            const data = response.data;

            // Thêm trạng thái eligibility vào ví
            if (data && data.hasEligibility) {
              return {
                ...wallet,
                eligibility: {
                  eligible: true,
                  totalAmount: data.totalAmount,
                },
              };
            } else {
              return {
                ...wallet,
                eligibility: {
                  eligible: false,
                  totalAmount: 0,
                },
              };
            }
          } catch (error) {
            return {
              ...wallet,
              eligibility: {
                eligible: false,
                totalAmount: 0,
                error: error.message,
              },
            };
          }
        })
      );

      results.push(...batchResults);
      console.log(`Processed batch ${i / concurrencyLimit + 1}`);
    }

    const outputFilePath = path.join(path.dirname(filePath), 'wallets_with_eligibility.json');
    fs.writeFileSync(outputFilePath, JSON.stringify(results, null, 2));

    console.log(`Updated wallets with eligibility saved to: ${outputFilePath}`);
  } catch (error) {
    console.error('Error checking eligibility:', error.message);
  }
}

const walletsFilePath = path.join(__dirname, 'wallets.json');

checkEligibility(walletsFilePath);