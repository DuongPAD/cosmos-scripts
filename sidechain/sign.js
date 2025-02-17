const fs = require('fs');
const path = require('path');
const { DirectSecp256k1HdWallet } = require('@cosmjs/proto-signing');
const { sha256 } = require('@cosmjs/crypto');

async function signMessagesFromFile(filePath) {
  try {
    // Bước 1: Đọc file JSON để lấy danh sách ví
    const fileData = fs.readFileSync(filePath, 'utf8');
    const wallets = JSON.parse(fileData);

    if (!Array.isArray(wallets)) {
      throw new Error('File does not contain an array of wallets.');
    }

    // Bước 2: Lặp qua từng ví và ký thông điệp
    const signatures = [];
    for (const wallet of wallets) {
      const seedPhrase = wallet.phrase;

      if (!seedPhrase) {
        console.warn(`Skipping wallet with missing phrase: ${wallet.address}`);
        continue;
      }

      console.log(`Processing wallet for address: ${wallet.address}`);

      // Tạo ví từ seed phrase
      const cosmosWallet = await DirectSecp256k1HdWallet.fromMnemonic(seedPhrase, {
        prefix: 'cosmos', // Prefix cho Cosmos
      });

      const [account] = await cosmosWallet.getAccounts();
      console.log('Signer address:', account.address);

      // Tạo dữ liệu thông điệp
      const messageData = {
        address: account.address, // Địa chỉ Cosmos
        receiverAddress: wallet.bitcoin?.segwit?.address || '', // Địa chỉ SegWit từ wallet
        timestamp: Date.now(), // Timestamp hiện tại
      };

      // Băm thông điệp
      const hashedMessage = sha256(new TextEncoder().encode(JSON.stringify(messageData)));

      // Ký thông điệp
      const signature = await cosmosWallet.signDirect(account.address, {
        bodyBytes: hashedMessage,
        authInfoBytes: new Uint8Array(),
        chainId: '',
        accountNumber: 0,
      });

      const signedData = {
        address: wallet.address,
        message: messageData,
        signature: Buffer.from(signature.signature.signature, 'base64').toString('hex'),
      };

      console.log(`Signature for ${wallet.address}:`, signedData.signature);

      signatures.push(signedData);
    }

    // Bước 3: Lưu chữ ký vào file mới
    const outputFilePath = path.join(path.dirname(filePath), 'signed_messages.json');
    fs.writeFileSync(outputFilePath, JSON.stringify(signatures, null, 2));

    console.log(`All signatures saved to: ${outputFilePath}`);
  } catch (error) {
    console.error('Error signing messages:', error.message);
  }
}

// Đường dẫn tới file JSON chứa seed phrases
const filePath = path.join(__dirname, '..', 'oliver_new.json');

// Ký thông điệp từ file
signMessagesFromFile(filePath);