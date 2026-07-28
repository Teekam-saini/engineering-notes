#!/bin/bash

if [ $# -eq 2 ]; then
desgin=$1
testbench=$2
else
read -p "enter desgin file: " desgin
read -p "enter testbench file: " testbench

fi

output="simulation.out"
echo ""

echo "compilling........."
echo "desgin: $desgin"
echo "testbench: $testbench"
echo "output: $output"
echo "command : iverilog -o  $output $desgin $testbench"
iverilog -o $output $desgin $testbench
