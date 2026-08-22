#!/bin/bash

error=$(grep -i -E "error|warning" simulation.log | wc -l)

if [ $error -eq 0 ]; then
echo "healthy"
elif [[ $error -gt 0 && $error -lt 4 ]]; then
echo "degraded"
else
echo "critical"
fi

