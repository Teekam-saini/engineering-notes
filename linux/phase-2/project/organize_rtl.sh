#!/bin/bash

# =================================
# Verilog Project Organizer
# =================================

# ---------- Functions ----------

is_testbench() {
    local filename=$1

    [[ "$filename" == tb_* ]]
}

get_basename() {
    local filename=$1

    echo "${filename%.v}"
}

validate_file() {
    local filename=$1

    # Check if file is not empty
    if [ ! -s "$filename" ]; then
        return 1
    fi

    # Check if file contains "module"
    if ! grep -q "module" "$filename"; then
        return 1
    fi

    return 0
}


# ---------- Discovery ----------

all_files=(*.v)

rtl_files=()
testbench_files=()
valid_files=()
invalid_files=()


# ---------- Classification + Validation ----------

for file in "${all_files[@]}"; do

    # Validate file
    if validate_file "$file"; then
        valid_files+=("$file")

        # Classify valid files
        if is_testbench "$file"; then
            testbench_files+=("$file")
        else
            rtl_files+=("$file")
        fi

    else
        invalid_files+=("$file")
    fi

done


# ---------- Report ----------

echo "================================="
echo "VERILOG PROJECT ORGANIZER REPORT"
echo "================================="

echo "Total files scanned: ${#all_files[@]}"
echo

echo "RTL Modules (${#rtl_files[@]}):"

for file in "${rtl_files[@]}"; do
    echo "  - $file"
done

echo

echo "Testbenches (${#testbench_files[@]}):"

for file in "${testbench_files[@]}"; do
    echo "  - $file"
done

echo

echo "INVALID FILES (${#invalid_files[@]}):"

for file in "${invalid_files[@]}"; do

    if [ ! -s "$file" ]; then
        echo "  - $file (empty file)"
    else
        echo "  - $file (no module keyword)"
    fi

done

echo

echo "Validation Summary:"
echo "  Valid: ${#valid_files[@]}"
echo "  Invalid: ${#invalid_files[@]}"

echo "================================="


# ---------- Organization ----------

mkdir -p rtl testbench

echo
read -p "Move files into organized folders? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then

    for file in "${rtl_files[@]}"; do
        mv "$file" rtl/
    done

    for file in "${testbench_files[@]}"; do
        mv "$file" testbench/
    done

    echo
    echo "Files organized successfully."

else

    echo
    echo "No files were moved."
    echo "Invalid files remain in the current directory for manual review."

fi
