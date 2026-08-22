#!/bin/bash
echo "design info script"
echo "===================="
module_name="counter"
designer="teekam"
bit_width=8
clock_freq=100

echo "desginer name : $designer"
echo "module name : $module_name"
echo "bit width : $bit_width"
echo "clock frequncy : $clock_freq"
echo "period in ns = $((1000/$clock_freq))"

