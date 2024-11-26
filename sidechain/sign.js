const fs = require('fs');
const path = require('path');
const { DirectSecp256k1HdWallet } = require('@cosmjs/proto-signing');
const { sha256 } = require('@cosmjs/crypto');

async function signMessagesFromFile(filePath, message) {
  try {
    const fileData = fs.readFileSync(filePath, 'utf8');
    const wallets = JSON.parse(fileData);

    if (!Array.isArray(wallets)) {
      throw new Error('File does not contain an array of wallets.');
    }

    const signatures = [];
    for (const wallet of wallets) {
      const seedPhrase = wallet.phrase;

      if (!seedPhrase) {
        console.warn(`Skipping wallet with missing phrase: ${wallet.address}`);
        continue;
      }

      console.log(`Processing wallet for address: ${wallet.address}`);

      const cosmosWallet = await DirectSecp256k1HdWallet.fromMnemonic(seedPhrase, {
        prefix: 'cosmos',
      });

      const [account] = await cosmosWallet.getAccounts();
      console.log('Signer address:', account.address);

      const hashedMessage = sha256(new TextEncoder().encode(message));

      const signature = await cosmosWallet.signDirect(account.address, {
        bodyBytes: hashedMessage,
        authInfoBytes: new Uint8Array(),
        chainId: '',
        accountNumber: 0,
      });

      const signedData = {
        address: wallet.address,
        signature: Buffer.from(signature.signature.signature, 'base64').toString('hex'),
      };

      console.log(`Signature for ${wallet.address}:`, signedData.signature);

      signatures.push(signedData);
    }

    const outputFilePath = path.join(path.dirname(filePath), 'signed_messages.json');
    fs.writeFileSync(outputFilePath, JSON.stringify(signatures, null, 2));

    console.log(`All signatures saved to: ${outputFilePath}`);
  } catch (error) {
    console.error('Error signing messages:', error.message);
  }
}

const filePath = path.join(__dirname, '..', 'oliver_new.json');

const message = 'I am verifying my ownership of this address.';

signMessagesFromFile(filePath, message);