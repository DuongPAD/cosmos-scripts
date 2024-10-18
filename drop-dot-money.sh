#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

for ((i=0; i<$num_elements; i++)); do
# for ((i=$index; i<=$index; i++)); do
  # Get random number
  ibc_amount="60000uatom"
  # Get username
  username="oliver$(printf "%02d" $((i+1)))"
  neutron_address=$(echo "$json_data" | jq -r ".[$i].neutron")
  receiver="neutron16m3hjh7l04kap086jgwthduma0r5l0wh8kc6kaqk92ge9n5aqvys9q6lxr"

  # Memo content
  memo_content="{\"wasm\":{\"contract\":\"neutron16m3hjh7l04kap086jgwthduma0r5l0wh8kc6kaqk92ge9n5aqvys9q6lxr\",\"msg\":{\"bond\":{\"receiver\":\"$neutron_address\",\"ref\":\"neutron184zleex484jr6gk38jrvs5avv0g0dkv2h7vewy\"}}}}"
  printf "\e[34m$neutron_address\e[0m"
  echo
  printf "\e[34m$username\e[0m"
  echo
  # Add key by phrase
  echo "y" | gaiad tx ibc-transfer transfer transfer channel-569 $receiver $ibc_amount --from="$username" --memo "$memo_content" --chain-id="cosmoshub-4" --node="https://cosmos-rpc.publicnode.com:443" --gas-adjustment 1.5 --gas auto --gas-prices 0.05uatom
  echo
  sleep 30  # Sleep 30 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone!\e[0m"
echo
