#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

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
    # Add key by phrase
    echo "$phrase" | elysd keys add "$username" --recover
done

printf "\e[32mDone! Imported all wallets!\e[0m"