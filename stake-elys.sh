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
  amount=$(echo "$json_data" | jq -r ".[$i].amount")
  stake_amount=$(echo "$amount * 1000000" | bc)
  stake_amount_str=$(printf "%.0f" "$stake_amount")
  username="oliver$(printf "%02d" $((i+1)))"

  printf "\e[34m$username\e[0m"

  gas_prices="0.02ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"

  echo
  # echo $stake_amount_str
  echo "Stake Eden: $address"
  echo "y" | elysd tx commitment vest $stake_amount_str ueden --from $username --chain-id="elys-1" --node="https://rpc.elys.network:443" --gas-adjustment 1.5 --gas auto --gas-prices $gas_prices
  # sleep 5

done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo