#!/bin/bash

read -p "How many modules do you want to compile: " number

rtl_dir="$HOME/rtl-desgin-verilog/rtl"
tb_dir="$HOME/rtl-desgin-verilog/tb"
sim_dir="$HOME/rtl-desgin-verilog/sim"

declare -a rtl_files
for ((i=1; i<=number; i++)); do
    read -p "Enter the RTL file name $i: " rtl_file
    rtl_files+=("$rtl_dir/$rtl_file")
done

read -p "Enter testbench file name: " tb_file
tb_path="$tb_dir/$tb_file"

read -p "Enter simulation output name: " sim_file
sim_path="$sim_dir/$sim_file"

# Compile with iverilog using the proper array expansion syntax
iverilog -o "$sim_path" "${rtl_files[@]}" "$tb_path"

if [ $? -eq 0 ]; then
    echo "Compiled successfully"
else
    echo "Error: Compilation failed"
    exit 1
fi

read -p "Do you wish to generate the simulation {y/n}: " input
if [[ "$input" == "y" || "$input" == "Y" ]]; then
    vvp "$sim_path"
    echo "Simulation generated"
else
    echo "No simulation generated"
fi

read -p "Do you wish to generate the waveform {y/n}: " input2
if [[ "$input2" == "y" || "$input2" == "Y" ]]; then
    gtkwave "$sim_dir/$sim_file.vcd" &
    echo "Waveform generated"
else
    echo "No waveform generated"
fi
