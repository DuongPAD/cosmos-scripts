import { SigningCosmWasmClient } from '@cosmjs/cosmwasm-stargate'
import { GasPrice } from '@cosmjs/stargate'
import { DirectSecp256k1HdWallet } from '@cosmjs/proto-signing'
import fs from 'fs'
import chalk from 'chalk'

const gasPrice = GasPrice.fromString('1ustars')

async function getClient(mnemonic) {
  const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {
    prefix: 'stars'
  })

  return await SigningCosmWasmClient.connectWithSigner(
    'https://rpc.stargaze-apis.com/',
    wallet,
    {
      gasPrice
    }
  )
}

async function getBalanceWithDelay(client, address, asset, delay) {
  await new Promise(resolve => setTimeout(resolve, delay))
  return client.getBalance(address, asset)
}

async function checkBalance() {
  const jsonData = fs.readFileSync('../stars.json')
  const data = JSON.parse(jsonData)

  const promises = data.map(async (wallet, index) => {
    const client = await getClient(wallet.phrase)
    const balance = await getBalanceWithDelay(
      client,
      wallet.address,
      'ustars',
      2000
    )

    return {
      index: index + 1,
      wallet: wallet.address,
      value: balance.amount / 1_000_000
    }
  })

  const balances = await Promise.all(promises)
  const hasBalancesBelowOne = balances.some(balance => balance.value < 1)

  return {
    balances,
    hasBalancesBelowOne
  }
}

async function main() {
  const { balances, hasBalancesBelowOne } = await checkBalance()

  if (hasBalancesBelowOne) {
    console.log(chalk.red('Warning: Some wallets have a balance less than 1.'))

    balances.forEach((balance, index) => {
      if (balance.value < 1) {
        console.log(
          `Wallet ${index + 1}: ${balance.wallet}: ${balance.value} STARS`
        )
      }
    })
  } else {
  }
}

main()
