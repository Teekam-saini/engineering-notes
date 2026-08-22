#!/bin/bash
log_step() {
local message="$1"
echo "[$(date +%H:%M:%S)] $message"
}

run_check() {

local name="$1"
local result="$2"

if [ $result -eq 0 ]; then
echo "$name passed"
else
echo "$name failed"
fi
}

log_step "starting build"
sleep 1
log_step "compiling rtl"
sleep 1
log_step "running simulation"

run_check "compilation" 0
run_check "simulation" 1
