#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmos-rpc.publicnode.com:443

# Read file JSON and save to array
json_data=$(cat oliver.json)

# Get array length
num_elements=$(echo "$json_data" | jq '. | length')

echo "Nhập ID của proposal:"
read vote_id

echo "Chọn một trong các trường hợp sau:"
echo "A. Yes"
echo "B. No"
echo "C. No with Veto"
echo "D. Abstain"

read vote
case $vote in
  A|a)
    vote_type="yes"
    echo "Bạn đã chọn Yes"
    ;;
  B|b)
    vote_type="no"
    echo "Bạn đã chọn No"
    ;;
  C|c)
    vote_type="NoWithVeto"
    echo "Bạn đã chọn No with Veto"
    ;;
  D|d)
    vote_type="abstain"
    echo "Bạn đã chọn Abstain"
    ;;
  *)
    echo "Lựa chọn không hợp lệ. Vui lòng chọn lại."
    ;;
esac

echo vote

random_sleep=$(( (RANDOM % 53) + 8 ))

# Loop through each element in the array
for ((i=0; i<$num_elements; i++)); do
    username="oliver$(printf "%02d" $((i+1)))"

    printf "\e[34m$username\e[0m"
    echo
    # Add key by phrase
    gaiad tx gov vote $vote_id $vote_type --from="$username" --chain-id="cosmoshub-4" --gas-adjustment 1.8 --gas auto --gas-prices 0.028uatom -y
    printf "\e[32mDone! $username voted $vote_type for proposal $vote_id!\e[0m"
    echo
    sleep 1  # Sleep 1 second before continuing the loop
done
echo
echo "===================================================================================================="
printf "\e[32mDone! All wallets voted for proposal $vote_id!\e[0m"
echo
