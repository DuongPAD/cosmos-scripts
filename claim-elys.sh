#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<num_elements; i++)); do
  address=$(echo "$json_data" | jq -r ".[$i].elys")
  username="oliver$(printf "%02d" $((i+1)))"

  printf "\e[34m$username\e[0m"
  echo

  gas_prices="0.045ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"

  echo "Claim Eden: $address"
  echo "y" | elysd tx commitment claim-airdrop --from $username --chain-id="elys-1" --node="https://rpc.elys.network:443" --gas-adjustment 1.8 --gas auto --gas-prices $gas_prices
  sleep 5

done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo