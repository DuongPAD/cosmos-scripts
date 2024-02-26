#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmoshub.validator.network:443

# Read file JSON and save to array
json_data=$(cat oliver.json)
# random_sleep=$(( (RANDOM % 53) + 8 ))

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"
# pryzm_validator_address="cosmosvaloper1hmd535f69t3x262m6s9wc6jd0dmel2zevhyuhm"

# Loops through each element in the array
for ((i=0; i<$num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m"
    echo
    echo "y" | gaiad tx distribution withdraw-rewards "$inux_validator_address" --from="$username"  --gas-adjustment 1.5 --gas auto --gas-prices 0.015uatom
    echo "====================================================="
    echo
    sleep 6  # Sleep 6 second before continuing the loop
done
echo "Done! Claimed all rewards!"