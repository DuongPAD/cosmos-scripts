#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmoshub.validator.network:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    echo "send money to $address"

    stake_amount=$((RANDOM % 400001 + 25100000))"uatom"

    # Send money to wallet
    echo "y" | gaiad tx bank send oliver01 $address $stake_amount --from="oliver01"  --chain-id="cosmoshub-4" --gas-adjustment 1.5 --gas auto --gas-prices 0.005uatom
    echo
    sleep 15  # Sleep 15 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo
