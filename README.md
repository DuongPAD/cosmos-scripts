# Raptor's Gang

## Script preparation

### Install Brew for macOS

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```
brew install wget git jq
```

___

### Install go

#### Mac M1

Download and install <https://go.dev/dl/go1.20.darwin-arm64.pkg>

#### Mac Intel

Download and install <https://go.dev/dl/go1.20.darwin-amd64.pkg>


#### Windows

Follow this link: <https://go.dev/doc/install>
Download go version v1.20 <https://go.dev/dl/>

___

### Install Gaiad

#### macOS

```
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zshrc
GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH
mkdir -p $HOME/raptor && cd $HOME/raptor
git clone https://github.com/cosmos/gaia
cd gaia && git checkout v14.1.0
make install
```

#### Windows

Follow this link <https://github.com/cosmos/gaia/releases/tag/v14.1.0>

___

### Run another script

#### Windows

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('<https://chocolatey.org/install.ps1>'))
```

```
choco install jq
```

## Step 0: clone folder

```
git clone https://github.com/DuongPAD/cosmos-scripts.git
```

___

## Step 1: run script-preparation script

```
chmod +x script-preparation.sh
```

```
./script-preparation.sh
```

### Windows

```
bash script-preparation.sh
```

___

## Step 2: add seed phrase to JSON

Create and edit file oliver.json, add address and seed phrase

___

## Step 3: run add-wallets

### macOS
```
./add-wallets.sh
```

### Windows

```
bash add-wallets.sh
```

___

## Step 4: run staking-for-inux script

Change the stake_amount for another staking.
stake_amount="25000000uatom" for 25 ATOM
stake_amount="100000uatom" for 0.1 ATOM

### macOS

```
./staking-for-inux.sh
```

### Windows

```
bash staking-for-inux.sh
```

___

## Optional: claim-rewards.sh

### macOS

```
./claim-rewards.sh
```

### Windows

```
bash claim-rewards.sh
```

___

## Optional: vote.sh

Change the vote_id and vote for another vote.
ex: vote_id=872
    vote="no"

### macOS

```
./vote.sh
```

### Windows

```
bash vote.sh
```

___

## Finally: run delete-wallets script

### macOS

```
./delete-wallets.sh
```

### Windows

```
bash delete-wallets.sh
```
