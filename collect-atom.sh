#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# gaiad config set client chain-id cosmoshub-4
# gaiad config set client node https://cosmos-rpc.publicnode.com:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

# Get oliver01 address (destination wallet)
oliver01_address=$(gaiad keys show oliver01 -a)
echo "Destination wallet (oliver01): $oliver01_address"
echo

for ((i=0; i<$num_elements; i++)); do
  username="oliver$(printf "%02d" $((i+1)))"
  printf "\e[34m$username\e[0m | "
  address=$(echo "$json_data" | jq -r ".[$i].address")

    # Check if this is oliver01 (skip sending to itself)
  if [ "$address" == "$oliver01_address" ]; then
    echo "Skipping oliver01 (destination wallet)"
    echo
    continue
  fi

  # balance_json=$(gaiad query account $address)
  balance_json=$(gaiad q bank balances $address --output json --node="https://cosmos-rpc.publicnode.com:443")
  echo "$address"
  # Extract the balance for uatom denom
  balance=$(echo "$balance_json" | jq -r '.balances[] | select(.denom=="uatom") | .amount')

  # If no uatom balance is found, set balance to 0
  balance=${balance:-0}
  echo "balance: $balance"

  balance_in_millions=$(echo "scale=6; $balance / 1000000" | bc)
  echo "balance_in_millions: $balance_in_millions"

  # Check if amount is less than 0.1
  if (( $(echo "$balance_in_millions < 0.1" | bc -l) )); then
    printf "\e[31mBalance: $balance_in_millions\e[0m\n"
    printf "\e[31mBalance is less than 0.1ATOM. Skipping collect.\e[0m\n"
  else
    send_amount=$((balance - 10000))
    send_amount_atom=$(echo "scale=6; $send_amount / 1000000" | bc)
    
    echo "Sending $send_amount_atom ATOM to oliver01..."
    
    # Send all available balance minus fee
    echo "y" | gaiad tx bank send $username $oliver01_address ${send_amount}uatom \
        --from="$username" \
        --chain-id="cosmoshub-4"  \
        --node="https://cosmos-rpc.publicnode.com:443" \
        --gas-adjustment 1.8 \
        --gas auto \
        --gas-prices 0.005uatom
  fi
  sleep 1  # Sleep 1 second before continuing the loop
done

echo
echo "===================================================================================================="
printf "\e[32mCollection completed!\e[0m"
echo
echo
echo "Final oliver01 balance:"
final_balance_json=$(gaiad query bank balances $oliver01_address --denom uatom -o json)
final_balance=$(echo "$final_balance_json" | jq -r '.amount')
final_balance_atom=$(echo "scale=6; $final_balance / 1000000" | bc)
echo "Oliver01 total balance: $final_balance_atom ATOM"