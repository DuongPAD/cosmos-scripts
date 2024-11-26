const fs = require('fs');
const axios = require('axios');
const path = require('path');

async function claimRewards(filePath) {
  try {
    const walletsData = fs.readFileSync(filePath, 'utf8');
    const wallets = JSON.parse(walletsData);

    const concurrencyLimit = 50;
    const results = [];

    for (let i = 0; i < wallets.length; i += concurrencyLimit) {
      const batch = wallets.slice(i, i + concurrencyLimit);

      const batchResults = await Promise.all(
        batch.map(async (wallet) => {
          const payload = {
            address: wallet.evm.address,
          };

          try {
            const response = await axios.post(
              'https://airdrop-api.side.one/airdrop/claim',
              payload,
              { headers: { 'Content-Type': 'application/json' } }
            );

            if (response.data) {
              return {
                ...wallet,
                claim: {
                  success: true,
                },
              };
            } else {
              return {
                ...wallet,
                claim: {
                  success: false,
                },
              };
            }
          } catch (error) {
            return {
              ...wallet,
              claim: {
                success: false,
                error: error.message,
              },
            };
          }
        })
      );

      results.push(...batchResults);
      console.log(`Processed batch ${i / concurrencyLimit + 1}`);
    }

    const outputFilePath = path.join(path.dirname(filePath), 'wallets_with_register.json');
    fs.writeFileSync(outputFilePath, JSON.stringify(results, null, 2));

    console.log(`Updated wallets with claims saved to: ${outputFilePath}`);
  } catch (error) {
    console.error('Error claiming rewards:', error.message);
  }
}

const walletsFilePath = path.join(__dirname, 'wallets.json');

claimRewards(walletsFilePath);