#!/bin/bash

analyze_directory () {

local dirname="$1"

local total_files=$(find "$dirname" -type f | wc -l)
local verilog_files=$(find "$dirname" -type f -name "*.v" | wc -l)

total_lines=0

for file in "$dirname"/*; do
if [ -f "$file" ]; then
local line=$(wc -l <"$file")
local total_lines=$((total_lines + line))
fi
done

echo "===directory statistics===="
echo "directory : $dirname"
echo "total files : $total_files"
echo "verilog fles : $verilog_files"
echo "total lines : $total_lines"

}

analyze_directory "$1"
