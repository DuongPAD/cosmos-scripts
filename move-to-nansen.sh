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
nansen_validator_address="cosmosvaloper1jlr62guqwrwkdt4m3y00zh2rrsamhjf9num5xr"
inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"

# Loop through each element in the array
for ((i=0; i<num_elements; i++)); do
    # Get phrase and username
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo

    staking_json=$(gaiad query staking delegations $address -o json);
    staked_amount=$(echo "$staking_json" | jq -r --arg validator_address "$inux_validator_address" '.delegation_responses[] | select(.delegation.validator_address == $validator_address) | .balance.amount | tonumber | floor')
    final_stake_amount="$((staked_amount))uatom"
    echo "y" | gaiad tx staking redelegate $inux_validator_address $nansen_validator_address $final_stake_amount --from="$username" --gas="auto" --gas-adjustment="1.5" --gas-prices="0.04uatom"
    echo
    echo "Sleeping for 3 seconds..."
    sleep 3
done
echo
echo "===================================================================================================="
printf "\e[32mChuyen nha xong roi nhe!\e[0m"
echo
