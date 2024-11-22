#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# gaiad config set client chain-id cosmoshub-4
# gaiad config node https://cosmoshub.validator.network:443

# Read file JSON and save to array
json_data=$(cat oliver.json)
# random_sleep=$(( (RANDOM % 53) + 8 ))

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"
mantra_validator_address="cosmosvaloper103agss48504gkk3la5xcg5kxplaf6ttnuv234h"

# Loops through each element in the array
for ((i=0; i<$num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m"
    echo
    echo "y" | gaiad tx distribution withdraw-rewards "$mantra_validator_address" --from="$username" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.8 --gas auto --gas-prices 0.017uatom
    echo "====================================================="
    echo
    sleep 12 
    echo "y" | gaiad tx distribution withdraw-rewards "$inux_validator_address" --from="$username" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.8 --gas auto --gas-prices 0.017uatom
    sleep 1
done
echo "Done! Claimed all rewards!"