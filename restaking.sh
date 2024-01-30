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
#stake_amount="25000000uatom"
# stake_amount="100000uatom"
inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"
pryzm_validator_address="cosmosvaloper1hmd535f69t3x262m6s9wc6jd0dmel2zevhyuhm"

random_sleep=$(( (RANDOM % 53) + 8 ))

# Loop through each element in the array
for ((i=19; i< 30; i++)); do
    # Get phrase and username
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo

    staking_json=$(gaiad query staking delegations $address -o json);
    staked_amount=$(echo "$staking_json" | jq -r --arg validator_address "$pryzm_validator_address" '.delegation_responses[] | select(.delegation.validator_address == $validator_address) | .delegation.shares | tonumber | floor')

    echo "Staked Amount for PRYZM: $staked_amount"l
    
    echo "y" | gaiad tx staking redelegate $pryzm_validator_address $inux_validator_address "25000000uatom" --from="$username" --gas="auto" --gas-adjustment="1.5" --gas-prices="0.04uatom"
    echo
    # sleep $random_sleep  # Sleep 8 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! Restaked all wallets!\e[0m"
echo
