import fs from 'fs'
import chalk from 'chalk'
import { request, gql } from 'graphql-request'
import { SigningCosmWasmClient } from '@cosmjs/cosmwasm-stargate'
import { toUtf8 } from '@cosmjs/encoding'
import { GasPrice } from '@cosmjs/stargate'
import { DirectSecp256k1HdWallet } from '@cosmjs/proto-signing'
import { MsgExecuteContract } from 'cosmjs-types/cosmwasm/wasm/v1/tx.js'

const GRAPHQL_ENDPOINT = 'https://graphql.mainnet.stargaze-apis.com/graphql'
const COLLECTION_ADDRESS =
  'stars1pwrxf78ehup5t7javknkgavm27mxyar0mnv98pjf8ew94uzz5eyq8e9uk8'
const MARKETPLACE_ADDRESS =
  'stars1fvhcnyddukcqfnt7nlwv3thm5we22lyxyxylr9h77cvgkcn43xfsvgv0pl'
const gasPrice = GasPrice.fromString('1ustars')

const legendaryIds = [368, 1030, 2105]
const divineIds = [
  69, 243, 416, 501, 674, 758, 772, 820, 885, 954, 1070, 1095, 1223, 1344, 1394,
  1401, 1410, 1492, 1527, 1690, 1701, 2187, 2461, 2680, 2716, 2779, 2854, 2909,
  3010, 3216
]
const floorPrices = {
  groovy: 700,
  divine: 50000,
  legendary: 100000
}

function sleep(ms) {
  console.log(`Sleep for ${Math.floor(ms / (60 * 1000))} minutes`)
  return new Promise(resolve => setTimeout(resolve, ms))
}

function getExpiresTime() {
  const now = new Date()
  now.setDate(now.getDate() + 14)
  const expires = (now.getTime() * 1_000_000).toString()
  return expires
}

async function getClient(mnemonic) {
  const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {
    prefix: 'stars'
  })

  const address = (await wallet.getAccounts())[0].address

  return {
    address,
    client: await SigningCosmWasmClient.connectWithSigner(
      'https://rpc.stargaze-apis.com/',
      wallet,
      {
        gasPrice
      }
    )
  }
}

async function getBalanceWithDelay(client, address, asset, delay) {
  await new Promise(resolve => setTimeout(resolve, delay))
  return client.getBalance(address, asset)
}

async function checkBalance() {
  const jsonData = fs.readFileSync('../stars.json')
  const data = JSON.parse(jsonData)

  const promises = data.map(async (wallet, index) => {
    const { client } = await getClient(wallet.phrase)
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

async function getOwnedTokens(address) {
  const query = gql`
      query OwnedTokens {
        tokens(
          ownerAddrOrName: "${address}"
          filterForSale: UNLISTED
          filterByCollectionAddrs: "${COLLECTION_ADDRESS}"
          sortBy: RARITY_DESC
        ) {
          tokens {
            id
            tokenId
            name
            rarityOrder
            rarityScore
            mintedAt
            saleType
          }
        }
      }
    `

  try {
    const data = await request(GRAPHQL_ENDPOINT, query)
    return data.tokens.tokens
  } catch (error) {
    console.error('Error fetching NFT list:', error)
    return []
  }
}

async function getRandomPrice(rarity) {
  const floorPrice = floorPrices[rarity]
  const range = floorPrice * (Math.random() * 0.05 + 0.1)
  let newPrice = floorPrice + Math.random() * (2 * range) - range

  newPrice = Math.round(newPrice / 10) * 10
  return newPrice
}

function isAddressInLog(address) {
  let logArray = []

  if (fs.existsSync('log.json')) {
    const existingLog = fs.readFileSync('log.json', 'utf-8')
    logArray = JSON.parse(existingLog)
  }

  return logArray.some(entry => entry.wallet === address)
}

function getLog() {
  let existingLog = []

  if (fs.existsSync('log.json')) {
    const existingLogContent = fs.readFileSync('log.json', 'utf-8')
    existingLog = JSON.parse(existingLogContent)
  }

  return existingLog
}

function appendToLog(logEntry) {
  let logArray = []

  if (fs.existsSync('log.json')) {
    const existingLog = fs.readFileSync('log.json', 'utf-8')
    logArray = JSON.parse(existingLog)
  }

  logArray.push(logEntry)

  fs.writeFileSync('log.json', JSON.stringify(logArray, null, 2))
}

async function sellNFT(index, address, tokenId, price, rarity) {
  const logEntry = {
    index: index + 1,
    wallet: address,
    success: true,
    tokenId,
    price,
    txHash: ''
  }
  let error = null

  console.log(
    chalk.blue(
      `Selling NFT with tokenId ${tokenId} at price ${price} STARS (${rarity})`
    )
  )

  const expires = getExpiresTime()

  const approveMsg = {
    approve: {
      spender: MARKETPLACE_ADDRESS,
      token_id: tokenId.toString(),
      expires: {
        at_time: expires
      }
    }
  }

  const setAskMsg = {
    set_ask: {
      collection: COLLECTION_ADDRESS,
      expires,
      sale_type: 'fixed_price',
      reserve_for: null,
      funds_recipient: address,
      price: {
        amount: (price * 1_000_000).toString(),
        denom: 'ustars'
      },
      token_id: tokenId
    }
  }

  const messages = [
    {
      typeUrl: '/cosmwasm.wasm.v1.MsgExecuteContract',
      value: MsgExecuteContract.fromPartial({
        sender: address,
        contract: COLLECTION_ADDRESS,
        msg: toUtf8(JSON.stringify(approveMsg)),
        funds: []
      })
    },
    {
      typeUrl: '/cosmwasm.wasm.v1.MsgExecuteContract',
      value: MsgExecuteContract.fromPartial({
        sender: address,
        contract: MARKETPLACE_ADDRESS,
        funds: [
          {
            amount: '500000',
            denom: 'ustars'
          }
        ],
        msg: toUtf8(JSON.stringify(setAskMsg))
      })
    }
  ]

  try {
    // const result = await client.signAndBroadcast(address, messages, 'auto')
    // assertIsDeliverTxSuccess(result)
    // console.log(chalk.green(`✅ Success! Tx hash: ${result.transactionHash}`))
    // logEntry.txHash = result.transactionHash
    if (!isAddressInLog(address)) {
      appendToLog(logEntry)
    }
  } catch (error) {
    console.log(chalk.red(`❌ Failed! Please check the log file`))
  } finally {
    if (error !== null) {
      logEntry.success = false
      logEntry.error = error
    }

    let existingLog = getLog()

    const existingEntryIndex = existingLog.findIndex(
      entry => entry.wallet === address
    )

    if (existingEntryIndex !== -1) {
      existingLog[existingEntryIndex] = logEntry
    } else {
      existingLog.push(logEntry)
    }

    fs.writeFileSync('log.json', JSON.stringify(existingLog, null, 2))
  }
}

async function sellStrategy() {
  const jsonData = fs.readFileSync('../stars.json')
  const data = JSON.parse(jsonData)

  //   const maxDelay = 30 * 60 * 1000
  //   const minDelay = 2 * 60 * 1000
  const maxDelay = 6 * 1000
  const minDelay = 2 * 1000

  for (let i = 0; i < data.length; i++) {
    const wallet = data[i]
    console.log('------------------------')
    console.log(chalk.blue(`Wallet ${wallet.address}`))

    const nfts = await getOwnedTokens(wallet.address)

    if (nfts.length) {
      for (const nft of nfts) {
        const tokenId = Number(nft.tokenId)
        let rarity = 'groovy'

        if (legendaryIds.includes(tokenId)) {
          rarity = 'legendary'
        } else if (divineIds.includes(tokenId)) {
          rarity = 'divine'
        }

        const price = await getRandomPrice(rarity)

        await sellNFT(i, wallet.address, tokenId, price, rarity)
      }

      const randomDelay = Math.floor(
        Math.random() * (maxDelay - minDelay) + minDelay
      )
      await sleep(randomDelay)
    } else {
      console.log(chalk.gray('Skipped'))
    }
  }
}

async function main() {
  //   console.log(chalk.gray('Checking balance...'))
  //   const { balances, hasBalancesBelowOne } = await checkBalance()

  //   if (hasBalancesBelowOne) {
  //     console.log(chalk.red('Warning: Some wallets have a balance less than 1.'))

  //     balances.forEach((balance, index) => {
  //       if (balance.value < 1) {
  //         console.log(
  //           `Wallet ${index + 1}: ${balance.wallet}: ${balance.value} STARS`
  //         )
  //       }
  //     })
  //   } else {
  //     console.log(chalk.green('✅'))

  //     await sellStrategy()
  //   }

  await sellStrategy()
}

main()
