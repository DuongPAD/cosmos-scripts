#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# Read JSON files and save to arrays
json_data=$(cat oliver.json)
elys_data=$(cat elys.json)

# Extract addresses from elys.json into a Bash array
allowed_addresses=($(echo "$elys_data" | jq -r '.[].address'))

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in oliver.json
for ((i=0; i<num_elements; i++)); do
  address=$(echo "$json_data" | jq -r ".[$i].elys")
  username="oliver$(printf "%02d" $((i+1)))"

  # Check if address is in the allowed list
  if [[ " ${allowed_addresses[*]} " == *" $address "* ]]; then
    printf "\e[34m$username\e[0m"
    echo

    gas_prices="0.045ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"

    echo "Claim Eden: $address"
    echo "y" | elysd tx commitment claim-airdrop --from $username --chain-id="elys-1" --node="https://rpc.elys.network:443" --gas-adjustment 1.8 --gas auto --gas-prices $gas_prices
    sleep 5
  else
    echo "Address $address not found in allowed list. Skipping..."
  fi
done

echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo