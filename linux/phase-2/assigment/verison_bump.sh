#!/bin/bash

files=("design_v1.v" "testbench_v1.v" "wrapper_v1.v")

v2_files=()

for file in "${files[@]}"; do

    # Replace v1 with v2
    new_file="${file/v1/v2}"

    # Extract everything before _v1
    base_name="${file%_v1.v}"

    echo "Old name: $file → New name: $new_file"
    echo "Base module name: $base_name"
    echo ""

    # Add new name to v2 array
    v2_files+=("$new_file")
done

echo "V2 files:"
printf '%s\n' "${v2_files[@]}"
