const fs = require('fs');
const path = require('path');

function mergeWalletsWithOwner(folderPath) {
  try {
    const files = fs.readdirSync(folderPath);

    const mergedData = [];

    for (const file of files) {
      const filePath = path.join(folderPath, file);

      if (file.endsWith('.json')) {
        const fileData = fs.readFileSync(filePath, 'utf8');
        const jsonData = JSON.parse(fileData);

        const owner = path.basename(file, '.json');
        const updatedData = jsonData.map((item) => ({
          ...item,
          owner,
        }));

        mergedData.push(...updatedData);
      }
    }

    const outputPath = path.join(folderPath, 'merged_wallets_with_owner.json');
    fs.writeFileSync(outputPath, JSON.stringify(mergedData, null, 2));
    console.log(`Merged data with owner saved to: ${outputPath}`);
  } catch (error) {
    console.error('Error merging wallets:', error.message);
  }
}

const walletsFolderPath = path.join(__dirname, 'wallets');

mergeWalletsWithOwner(walletsFolderPath);