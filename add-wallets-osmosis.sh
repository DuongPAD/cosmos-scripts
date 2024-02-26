#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

osmosisd config node https://osmosis-rpc.publicnode.com:443
osmosisd config chain-id osmosis-1

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    phrase=$(echo "$json_data" | jq -r ".[$i].phrase")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    # Add key by phrase and capture the output (address)
    address=$(echo "$phrase" | osmosisd keys add "$username" --recover | grep 'address:' | awk '{print $3}')

    echo "$address"

    # Update the JSON data with the new address and write to file immediately
    updated_json_element=$(echo "$json_data" | jq --arg address "$address" ".[$i] | .osmosis = \$address")
    json_data=$(echo "$json_data" | jq ".[$i] = $updated_json_element")
    echo "$json_data" > oliver.json
    sleep 1
done

# Write the updated JSON array to the file
echo "$json_data" > oliver.json

printf "\e[32mDone! Imported all wallets and updated oliver.json\e[0m"
