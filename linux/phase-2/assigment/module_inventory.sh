#!/bin/bash

module=(*.v)
width=(32 16 64 22 18 2 22)

for i in "${!module[@]}"; do
echo "module: ${module[$i]} , width : ${width[$i]} bits"
done

echo "total modules: ${#module[@]}"

