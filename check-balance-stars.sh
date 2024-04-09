#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

starsd config node https://rpc.stargaze-apis.com:443
starsd config chain-id stargaze-1

# Read file JSON and save to array
json_data=$(cat stars.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

total_all_wallets=0

# Print CSV header
csv_file="stars_info.csv"
echo "Username,Address,Amount" > "$csv_file"

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    echo "$address"

    balance_json=$(starsd query bank balances $address --denom ustars -o json &)
    balance=$(echo "$balance_json" | jq -r '.amount')
    balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)

    # Check if amount is less than 1, print in red
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        printf  "\e[31mBalance: $balance_in_millions\e[0m\n"
    else
        echo "Balance: $balance_in_millions"
    fi

    # Print to csv file
    echo "$username,$address,$balance_in_millions" >> "$csv_file"

    echo
done

echo
echo "===================================================================================================="
printf "Done! Wallet information exported to $csv_file\n"
