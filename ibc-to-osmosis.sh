#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# gaiad config chain-id cosmoshub-4
# gaiad config node https://cosmoshub.validator.network:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

for ((i=0; i<$num_elements; i++)); do
    # Get random number
    ibc_amount="60000uatom"
    # Get username
    username="oliver$(printf "%02d" $((i+1)))"
    osmosis_address=$(echo "$json_data" | jq -r ".[$i].osmosis")

    printf "\e[34m$username\e[0m"
    echo
    # Add key by phrase
    echo "y" | gaiad tx ibc-transfer transfer transfer channel-141 $osmosis_address $ibc_amount --from="$username" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.5 --gas auto --gas-prices 0.035uatom
    echo
    sleep 5  # Sleep 5 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! IBC to osmosis all wallets!\e[0m"
echo
