#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config set client chain-id cosmoshub-4
gaiad config set client node https://cosmos-rpc.publicnode.com:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Declare validator address
mantra_validator_address="cosmosvaloper103agss48504gkk3la5xcg5kxplaf6ttnuv234h"
nansen_validator_address="cosmosvaloper1jlr62guqwrwkdt4m3y00zh2rrsamhjf9num5xr"

# Loop through each element in the array
for ((i=0; i<num_elements; i++)); do
    # Get phrase and username
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo

    staking_json=$(gaiad query staking delegations $address -o json);
    staked_amount=$(echo "$staking_json" | jq -r --arg validator_address "$mantra_validator_address" '.delegation_responses[] | select(.delegation.validator_address == $validator_address) | .balance.amount | tonumber | floor')
    if (( staked_amount > 1000 )); then
      final_stake_amount="$((staked_amount))uatom"
      echo "y" | gaiad tx staking redelegate $mantra_validator_address $nansen_validator_address $final_stake_amount --from="$username" --gas="auto" --gas-adjustment="1.5" --gas-prices="0.04uatom"
      echo
      sleep_time=$((RANDOM % 43 + 8))
      echo "Sleeping for $sleep_time seconds..."
      sleep $sleep_time
    else
      echo "Staked Amount is less than 0.001 ATOM, skipping action."
    fi
    sleep 2  # Sleep 2 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! Restaked all wallets!\e[0m"
echo
