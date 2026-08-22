#!/bin/bash

rtl=(*.v)

for file in "${rtl[@]}"; do

    echo "Full path: $(realpath "$file")"
    echo "Filename only: $file"
    echo "Basename no extension: ${file%.v}"
    echo "Extension only: ${file##*.}"

done
