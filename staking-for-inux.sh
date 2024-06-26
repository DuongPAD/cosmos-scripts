#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmoshub.validator.network:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Declare validator address
inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    # Get random number
    numr=$((1 + RANDOM % 500))
    stake_amount="$(( RANDOM % (25050000 - 25000000 + 1) + 25000000 ))uatom"
    # stake_amount="$((150000 + RANDOM % 50001))uatom"
    # Get username
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    # Add key by phrase
    echo "y" | gaiad tx staking delegate "$inux_validator_address" $stake_amount --from="$username" --gas-adjustment 1.8 --gas auto --gas-prices 0.038uatom
    echo
    sleep 5  # Sleep 8 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! Staked all wallets!\e[0m"
echo
