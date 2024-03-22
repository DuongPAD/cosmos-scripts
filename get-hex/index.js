const bip39 = require('bip39')
const ecc = require('tiny-secp256k1')
const { BIP32Factory } = require('bip32')
const secp256k1 = require('secp256k1')
const fs = require('fs')

const generateWalletId = async () => {
  try {
    const jsonData = fs.readFileSync('../oliver.json', 'utf8')
    const data = JSON.parse(jsonData)

    const newData = []

    for (let i = 0; i < data.length; i++) {
      const { address, phrase } = data[i]
      const publicKey = generatePublicKeyFromMnemonic(phrase)
      newData.push({ address, hex: publicKey, name: i + 1 })
    }

    fs.writeFileSync('hex.json', JSON.stringify(newData, null, 2))
    console.log('✅ DONE!')
  } catch (error) {
    console.error('An error occurred:', error)
  }
}

const generatePublicKeyFromMnemonic = (
  mnemonic,
  path = `m/44'/118'/0'/0/0`,
  password = ''
) => {
  const seed = bip39.mnemonicToSeedSync(mnemonic, password)
  const bip32 = BIP32Factory(ecc)
  const masterSeed = bip32.fromSeed(seed)
  const hd = masterSeed.derivePath(path)
  const privateKey = hd.privateKey

  if (!privateKey) {
    throw new Error('null hd key')
  }

  const publicKey = secp256k1.publicKeyCreate(privateKey)
  return Buffer.from(publicKey).toString('hex')
}

generateWalletId()
