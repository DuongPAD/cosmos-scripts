#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

for ((i=0; i<$num_elements; i++)); do
  username="oliver$(printf "%02d" $((i+1)))"
  printf "\e[34m$username\e[0m | "
  address=$(echo "$json_data" | jq -r ".[$i].address")

  # balance_json=$(gaiad query account $address)
  balance_json=$(gaiad q bank balances $address --output json)
  echo "$address"

  # Extract the balance for uatom denom
  balance=$(echo "$balance_json" | jq -r '.balances[] | select(.denom=="uatom") | .amount')

  # If no uatom balance is found, set balance to 0
  balance=${balance:-0}
  balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)
  echo "balance_in_millions: $balance_in_millions"
  neutron_address=$(echo "$json_data" | jq -r ".[$i].neutron")
  receiver="neutron16m3hjh7l04kap086jgwthduma0r5l0wh8kc6kaqk92ge9n5aqvys9q6lxr"

  # Check if amount is less than 0.1
  if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
    printf "\e[31mBalance: $balance_in_millions\e[0m\n"
    printf "\e[31mBalance is less than 0.1ATOM. Skipping IBC to drop.money\e[0m\n"
  else
    echo "Balance: $balance_in_millions ATOM"
    ibc_amount="$((balance - 80000))uatom"
    echo "IBC amount: $ibc_amount"

    memo_content="{\"wasm\":{\"contract\":\"neutron16m3hjh7l04kap086jgwthduma0r5l0wh8kc6kaqk92ge9n5aqvys9q6lxr\",\"msg\":{\"bond\":{\"receiver\":\"$neutron_address\",\"ref\":\"neutron184zleex484jr6gk38jrvs5avv0g0dkv2h7vewy\"}}}}"
    printf "\e[34m$neutron_address\e[0m"
    echo
    # Add key by phrase
    echo "y" | gaiad tx ibc-transfer transfer transfer channel-569 $receiver $ibc_amount --from="$username" --memo "$memo_content" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.5 --gas auto --gas-prices 0.05uatom
    echo
    sleep 2  # Sleep 8 second before continuing the loop
  fi
  sleep 1  # Sleep 1 second before continuing the loop

done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo
