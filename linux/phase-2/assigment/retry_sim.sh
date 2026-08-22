#!/bin/bash

count=1
while [ $count -lt 6 ]; do
echo "attempt: $count"
if [ $count -eq 3 ]; then
echo "simulating succes"
break
fi
count=$((count+1))
done

if [ $count -gt 5 ]; then
echo "all attempts failed"
fi
