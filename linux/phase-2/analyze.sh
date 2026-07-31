#!/bin/bash
file_name=$1
count_lines=$(wc -l < $file_name)
count_module=$(grep "module" $file_name | wc -l)
count_always=$(grep "always" $file_name | wc -l)

echo "summary"
echo "file name : $file_name"
echo "count lines : $count_lines"
echo "count_module : $count_module"
echo "count always : $count_always"
