const fs = require('fs');
const path = require('path');
const bip39 = require('bip39');
const bitcoin = require('bitcoinjs-lib');
const BIP32Factory = require('bip32').default;
const ecc = require('tiny-secp256k1');
const { ethers } = require('ethers');
const { Keypair } = require('@solana/web3.js');

bitcoin.initEccLib(ecc);
const bip32 = BIP32Factory(ecc);

function generateBitcoinWallet() {
  const mnemonic = bip39.generateMnemonic();
  const seed = bip39.mnemonicToSeedSync(mnemonic);
  const root = bip32.fromSeed(seed, bitcoin.networks.bitcoin);

  const segwitPath = "m/84'/0'/0'/0/0";
  const segwitChild = root.derivePath(segwitPath);
  const segwitAddress = bitcoin.payments.p2wpkh({
    pubkey: segwitChild.publicKey,
    network: bitcoin.networks.bitcoin,
  }).address;

  const taprootPath = "m/86'/0'/0'/0/0";
  const taprootChild = root.derivePath(taprootPath);
  const taprootAddress = bitcoin.payments.p2tr({
    internalPubkey: taprootChild.publicKey.slice(1, 33),
    network: bitcoin.networks.bitcoin,
  }).address;

  return {
    mnemonic,
    segwit: {
      path: segwitPath,
      address: segwitAddress,
      privateKey: segwitChild.toWIF(),
    },
    taproot: {
      path: taprootPath,
      address: taprootAddress,
      privateKey: taprootChild.toWIF(),
    },
  };
}

function addBitcoinInfoToWallets(filePath) {
  try {
    const walletsData = fs.readFileSync(filePath, 'utf8');
    const wallets = JSON.parse(walletsData);

    const updatedWallets = wallets.map((wallet) => {
      const bitcoinWallet = generateBitcoinWallet();

      const evmWallet = ethers.Wallet.createRandom();
      const evmMnemonic = evmWallet.mnemonic.phrase;
      const evmAddress = evmWallet.address;
      const evmPrivateKey = evmWallet.privateKey;

      const solanaKeypair = Keypair.generate();
      const solanaAddress = solanaKeypair.publicKey.toString();
      const solanaPrivateKey = Buffer.from(solanaKeypair.secretKey).toString('hex');

      return {
        ...wallet,
        bitcoin: bitcoinWallet,
        evm: {
          mnemonic: evmMnemonic,
          address: evmAddress,
          privateKey: evmPrivateKey,
        },
        solana: {
          address: solanaAddress,
          privateKey: solanaPrivateKey,
        },
      };
    });

    const outputFilePath = path.join(path.dirname(filePath), './oliver_new.json');
    fs.writeFileSync(outputFilePath, JSON.stringify(updatedWallets, null, 2));

    console.log(`Updated wallets saved to: ${outputFilePath}`);
  } catch (error) {
    console.error('Error updating wallets:', error.message);
  }
}

const walletsFilePath = path.join(__dirname, '../oliver.json');

addBitcoinInfoToWallets(walletsFilePath);