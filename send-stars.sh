#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

starsd config node https://rpc.stargaze-apis.com:443
starsd config chain-id stargaze-1

# Read file JSON and save to array
json_data=$(cat stars.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    address=$(echo "$json_data" | jq -r ".[$i].address")
    username="oliver$(printf "%02d" $((i+1)))"

    balance_main_account=$(starsd query bank balances stars184zleex484jr6gk38jrvs5avv0g0dkv28ajxlj --denom ustars -o json)
    echo "main account: $balance_main_account"

    printf "\e[34m$username\e[0m"
    echo
    echo "send money to $address"

    send_amount="400000000ustars"

    balance_json=$(starsd query bank balances $address --denom ustars -o json)
    balance=$(echo "$balance_json" | jq -r '.amount')
    balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)
    echo "Balance: $balance_in_millions"
    if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
        echo "send money to $address"
        echo "y" | starsd tx bank send oliver01 $address $send_amount --from="oliver01"  --chain-id="cosmoshub-4" --gas-adjustment 1.8 --gas auto --gas-prices 0.005uatom
        echo "done"
        # sleep 16
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