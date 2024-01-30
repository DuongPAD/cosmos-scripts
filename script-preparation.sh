#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmoshub.validator.network:443

chmod +x add-wallets.sh
chmod +x staking-for-inux.sh
chmod +x claim-rewards.sh
chmod +x delete-wallets.sh
chmod +x vote.sh
chmod +x send-atom.sh
chmod +x check-balance.sh
