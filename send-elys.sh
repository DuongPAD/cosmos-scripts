#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# Read file JSON and save to array
json_data=$(cat elys.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<num_elements; i++)); do
  address=$(echo "$json_data" | jq -r ".[$i].address")
  username="oliver01"

  printf "\e[34m$username\e[0m"
  echo

  send_amount="50000ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"
  gas_prices="0.045ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"

  echo "send money to $address"
  echo "y" | elysd tx bank send oliver01 $address $send_amount --from="oliver01" --chain-id="elys-1" --node="https://rpc.elys.network:443" --gas-adjustment 1.8 --gas auto --gas-prices $gas_prices
  sleep 16

done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo