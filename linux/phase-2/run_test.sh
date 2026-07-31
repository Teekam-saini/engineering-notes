#!/bin/bash

for seed in {1..10}; do
if [ $((seed % 3)) -eq 0 ]; then
continue
else
echo "$seed"
fi
done
