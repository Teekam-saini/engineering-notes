#!/bin/bash

for width in 8 16 32; do
for freq in 50 100 200; do
period=$((1000/freq))
echo "width: $width , frequncy: $freq , period: $period ns"
done
done

