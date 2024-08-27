#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmos-rpc.publicnode.com:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    echo "send money to $address"

    # stake_amount=$((RANDOM % 400001 + 25100000))"uatom"
    send_amount="25200000uatom"

    balance_json=$(gaiad query bank balances $address --denom uatom -o json)
    balance=$(echo "$balance_json" | jq -r '.amount')
    balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)
    echo "Balance: $balance_in_millions"
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        echo "send money to $address"
        echo "y" | gaiad tx bank send oliver01 $address $send_amount --from="oliver01"  --chain-id="cosmoshub-4" --gas-adjustment 1.8 --gas auto --gas-prices 0.005uatom
        echo "done"
        sleep 24
    else
        echo "balance is greater than 0.1"
        sleep 5
    fi
    # Send money to wallet
    echo
    sleep 3  # Sleep 24 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo