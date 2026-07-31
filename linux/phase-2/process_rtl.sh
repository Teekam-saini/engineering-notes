#!/bin/bash

for file in *.v; do
echo "filename: $file line count: $(wc -l < "$file")"
done

