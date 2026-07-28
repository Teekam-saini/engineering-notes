#!/bin/bash
verilog_count=$(ls rtl/gates/*.v | wc -l)
log_count=$(ls day7/logs/*.log 2>/dev/null | wc -l)
total=$(($verilog_count + $log_count))

echo " counting total verilog files and log files "
echo "==========================================="
echo "total verilog files : $verilog_count"
echo "total log count files : $log_count"
echo "total files : $total"

