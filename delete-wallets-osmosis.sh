#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

osmosisd config node https://osmosis-rpc.publicnode.com:443
osmosisd config chain-id osmosis-1

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loops through each element in the array
for ((i=0; i<$num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"
    printf "\e[34m$username\e[0m"
    echo
    echo "y" | osmosisd keys delete "$username"
    echo
done
printf "\e[32mDone! Deleted all wallets!\e[0m"
