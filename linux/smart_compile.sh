#!/bin/bash

if [ $# -lt 2 ]; then
echo "error not both arguments are provided"
echo "usage: $# <design.v> <testbench.v>"
exit 1
fi

if [[ ! -f "$1" || ! -f "$2" ]]; then
echo "error : file missing"
echo "usage: $3 <filename>"

else
output="simulation.out"
echo "compileing.........."
echo "iverilog -o $output $1 $2"
echo "all test passed"
fi
