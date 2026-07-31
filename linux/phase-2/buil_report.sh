#!/bin/bash
project="vlsi project"
build_time=$(date "+%y-%m%d %h:%m")
modules_compiled=5
errors=0
warnings=2
echo "build report"
echo "==============="
echo "project name: $project " 
echo "build time : $build_time"
echo "modules compiled : $modules_compiled"

if (($errors == 0)) then
echo "build: success"
else
echo "failure detected"
fi
