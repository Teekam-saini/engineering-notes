#!/bin/bash

arr="clk,reset,enable,data_in,data_out"

IFS=',' read -ra new_arr <<< "$arr"

for port in "${new_arr[@]}"; do
    echo "Port name in upper case: ${port^^}"
done

echo "Total port count: ${#new_arr[@]}"

echo "Ports containing 'data':"
for port in "${new_arr[@]}"; do
    if [[ "$port" == *data* ]]; then
        echo "$port"
    fi
done
