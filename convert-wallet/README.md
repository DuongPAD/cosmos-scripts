# Install Stars Binary

## 1. Script preparation

Create new folder on desktop, open Terminal at folder

```
git clone https://github.com/public-awesome/stargaze
cd stargaze
git checkout v13.0.1
git clone https://github.com/cosmos/ibc-go/
git checkout v7.3.2
cd ibc-go
make install
make build
cd ..
make install
make build
```

## 2. Get the latest cosmos-scripts

Go to folder cosmos-scripts, open Terminal at folder:

```
git checkout . && git pull
```

## 3. Convert Cosmos Wallet Address to Stars Wallet Address

From Terminal at cosmos-scripts folder:

```
cd buy-nft
npm install
node convertWallet.js
```

## 4. Add Wallets

From Terminal at cosmos-scripts folder:

```
chmod +x add-wallets-starsd.sh
./add-wallets-starsd.sh
```

## 5. Send Stars

From Terminal at cosmos-scripts folder:

```
chmod +x send-stars.sh
./send-stars.sh
```

## 6. Buy NFT

From Terminal at cosmos-scripts folder:

```
chmod +x buy-nft.sh
./buy-nft.sh
```
