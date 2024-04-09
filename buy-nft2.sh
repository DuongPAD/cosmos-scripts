#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

starsd config node https://rpc.stargaze-apis.com:443
starsd config chain-id stargaze-1

# Read file JSON and save to array
json_data=$(cat stars.json)
# random_sleep=$(( (RANDOM % 53) + 8 ))

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

contract_nft="stars1kcp3lpuyney9d46znpqaw0xh54c2qevs2le8lavz7jukgnam9waqr49fyu"

# Loops through each element in the array
for ((i=50; i<100; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m"
    echo
    echo "y" | starsd tx wasm execute "$contract_nft" '{"mint":{}}' --amount 399000000ustars --from="$username"  --gas="500000" --gas-adjustment="1.80" &
    echo "====================================================="
    echo
    sleep 0.5  # Sleep 1 second before continuing the loop
done
echo "Done! Buy Nft!"