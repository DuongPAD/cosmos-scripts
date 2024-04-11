#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

osmosisd config node https://osmosis-rpc.publicnode.com:443
osmosisd config chain-id osmosis-1

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

total_all_wallets=0

# Print CSV header
csv_file="airdrop_hava.csv"
echo "Username,Address,Amount" > "$csv_file"

# Loop through each element in the array
for ((i=0; i<num_elements; i++)); do
    address=$(echo "$json_data" | jq -r ".[$i].osmosis")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    echo "$address"
   
    balance_json=$(osmosisd query bank balances $address --denom ibc/884EBC228DFCE8F1304D917A712AA9611427A6C1ECC3179B2E91D7468FB091A2 -o json)
    balance=$(echo "$balance_json" | jq -r '.amount')
    balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)

    # Check if amount is less than 1, print in red
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        printf  "\e[31mBalance: $balance_in_millions\e[0m\n"
    else
        echo "Balance: $balance_in_millions"
    fi

    total_all_wallets=$(echo "scale=6; $total_all_wallets + $balance_in_millions" | bc)

    # Print to csv file
    echo "$username,$address,$balance_in_millions" >> "$csv_file"

    echo
    echo "_____________________________"
    sleep 0.5  # Sleep 1 seconds before continuing the loop
done

# total_all_wallets_in_millions=$(echo "scale=6; $total_all_wallets / 1000000" | bc)
# printf "\e[32mTotal Amount of All Wallets: $total_all_wallets_in_millions\e[0m"

echo
echo "===================================================================================================="
printf "Done! Wallet information exported to $csv_file\n"