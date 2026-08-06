#!/bin/bash

# Global counters
pass_count=0
fail_count=0

assert_equals() {
    local actual="$1"
    local expected="$2"
    local test_name="$3"

    if [ "$actual" = "$expected" ]; then
        echo " PASS: $test_name"
        pass_count=$((pass_count + 1))
    else
        echo " FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        fail_count=$((fail_count + 1))
    fi
}

# ---------- Tests ----------
assert_equals "8" "8" "ALU Width"
assert_equals "16" "8" "Register Width"
assert_equals "module" "module" "Module Keyword"
assert_equals "PASS" "PASS" "Compilation"
assert_equals "FAILED" "PASS" "Simulation"

# ---------- Summary ----------
total=$((pass_count + fail_count))

echo
echo "===== Test Summary ====="
echo "$pass_count/$total tests passed"
echo "Passed : $pass_count"
echo "Failed : $fail_count"
