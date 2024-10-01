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
inux_validator_address="cosmosvaloper1zgqal5almcs35eftsgtmls3ahakej6jmnn2wfj"

# Loop through each element in the array
# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m | "
    address=$(echo "$json_data" | jq -r ".[$i].address")

    # balance_json=$(gaiad query account $address)
    balance_json=$(gaiad q bank balances $address --output json)
    echo "address: $address"
    echo "balance_json: $balance_json"

    # Extract the balance for uatom denom
    balance=$(echo "$balance_json" | jq -r '.balances[] | select(.denom=="uatom") | .amount')

    # If no uatom balance is found, set balance to 0
    balance=${balance:-0}
    echo "balance: $balance"
    
    balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)
    echo "balance_in_millions: $balance_in_millions"

    # Check if amount is less than 0.1
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        printf "\e[31mBalance: $balance_in_millions\e[0m\n"
        printf "\e[31mBalance is less than 0.1ATOM. Skipping stake.\e[0m\n"
    else
        echo "Balance: $balance_in_millions ATOM"
        stake_amount="$((balance - 80000))uatom"
        echo "Stake amount: $stake_amount"
        echo "y" | gaiad tx staking delegate "$inux_validator_address" $stake_amount --from="$username" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.8 --gas auto --gas-prices 0.038uatom
    fi
    sleep 1  # Sleep 1 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! Staked all wallets!\e[0m\n"