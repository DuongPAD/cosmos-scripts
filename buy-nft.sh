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

contract_nft="stars1655x90lju9nz2e685xkezdl6m8pacccpltfda84qnfgxz8yk8m7q0tvequ"

# Loops through each element in the array
for ((i=0; i<num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m"
    echo
    echo "y" | starsd tx wasm execute "$contract_nft" '{"mint":{}}' --amount 399000000ustars --from="$username"  --gas="1500000" --gas-adjustment="1.80" &
    echo "====================================================="
    echo
    sleep 0.5  # Sleep 1 second before continuing the loop
done
echo "Done! Buy Nft!"