#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config set client chain-id cosmoshub-4
gaiad config set client node https://cosmos-rpc.publicnode.com:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

total_all_wallets=0

# Print CSV header
csv_file="wallets_info.csv"
echo "Username,Address,Amount,Staked Amount,Total Amount" > "$csv_file"

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


    # Check if amount is less than 1, print in red
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        printf  "\e[31mBalance: $balance_in_millions\e[0m\n"
    else
        echo "Balance: $balance_in_millions"
    fi

    staking_json=$(gaiad query staking delegations $address -o json);
    staked_amount=$(echo "$staking_json" | jq -r '.delegation_responses[].balance.amount | tonumber' | awk '{s+=$1} END {printf "%.6f\n", s}')
    staked_amount_in_millions=$(echo "scale=6; $staked_amount / 1000000" | bc)
    
    # Check if staked amount is less than 1, print in red
    if (( $(echo "$staked_amount_in_millions < 1" | bc -l) )); then
        printf  "\e[31mStaked Amount: $staked_amount_in_millions\e[0m\n"
    else
        echo "Staked Amount: $staked_amount_in_millions"
    fi
    
    # Total amount
    total_amount=$(echo "scale=6; $balance + $staked_amount" | bc)
    total_amount_in_millions=$(echo "scale=6; $total_amount / 1000000" | bc)
    printf "\e[32mTotal Amount: $total_amount_in_millions\e[0m"

    total_all_wallets=$(echo "scale=6; $total_all_wallets + $total_amount" | bc)

    # Print to csv file
    echo "$username,$address,$balance_in_millions,$staked_amount_in_millions,$total_amount_in_millions" >> "$csv_file"

    echo
    echo "_____________________________"
    sleep 1  # Sleep 1 seconds before continuing the loop
done

total_all_wallets_in_millions=$(echo "scale=6; $total_all_wallets / 1000000" | bc)
printf "\e[32mTotal Amount of All Wallets: $total_all_wallets_in_millions\e[0m"

echo
echo "===================================================================================================="
printf "Done! Wallet information exported to $csv_file\n"