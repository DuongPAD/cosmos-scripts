#!/bin/bash

GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

gaiad config chain-id cosmoshub-4
gaiad config node https://cosmoshub.validator.network:443

gaiad tx ibc-transfer transfer transfer channel-141 osmo184zleex484jr6gk38jrvs5avv0g0dkv2m6ktz3 10000uatom --from="oliver01" --gas-adjustment 1.5 --gas auto --gas-prices 0.035uatom