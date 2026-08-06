#!/bin/bash

check_module() {
    local file="$1"

    if [[ -f "$file" ]] && grep -qi "module" "$file"; then
        return 0
    else
        return 1
    fi
}

get_line_count() {
    local line
    line=$(wc -l < "$1")
    echo "Total lines: $line"
}

format_size() {
    local bytes
    local kb

    bytes=$(stat -c%s "$1")
    kb=$((bytes / 1024))

    echo "$kb KB"
}

check_module "$1"
get_line_count "$1"
format_size "$1"

