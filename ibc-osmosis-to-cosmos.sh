#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

osmosisd config node https://osmosis-rpc.publicnode.com:443
osmosisd config chain-id osmosis-1

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

for ((i=0; i<$num_elements; i++)); do
    # Get random number
    ibc_amount="90000ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2"
    # Get username
    username="oliver$(printf "%02d" $((i+1)))"
    cosmos_address=$(echo "$json_data" | jq -r ".[$i].address")

    printf "\e[34m$username\e[0m"
    echo
    # Add key by phrase
    echo "y" | osmosisd tx ibc-transfer transfer transfer channel-0 $cosmos_address $ibc_amount --from="$username" --gas-adjustment 1.5 --gas auto --gas-prices "0.045ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2"
    echo
    sleep 5  # Sleep 5 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! Staked all wallets!\e[0m"
echo
