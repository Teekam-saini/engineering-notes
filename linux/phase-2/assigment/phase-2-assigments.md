# Linux Shell Scripting Assignments for RTL/VLSI

A collection of Bash scripting exercises focused on Linux automation for RTL design and verification workflows. These assignments cover scripting fundamentals, file handling, loops, functions, arrays, and practical automation commonly used in digital design environments.

---

## Learning Objectives

By completing these assignments, you will learn how to:

- Write reusable Bash scripts
- Automate common RTL design tasks
- Process simulation log files
- Analyze Verilog source files
- Work with variables, loops, functions, and arrays
- Build simple automation pipelines similar to real VLSI workflows

---

# Project

## Simulation Log Analyzer

Create **`analyze_sim.sh`** that:

- Reads simulation log files
- Extracts errors, warnings, and timing violations
- Counts failures by type
- Generates a summary report
- Sets proper execution permissions
- Can run in the background for large log files

---

# Task 1 - Design Information Script

Create **`design_info.sh`** that:

- Stores the following variables:
  - `module_name="counter"`
  - `designer="teekam"`
  - `bit_width=8`
  - `clock_freq=100` (MHz)
- Prints a formatted report
- Calculates and prints the clock period:

```text
Period (ns) = 1000 / Frequency (MHz)
```

### Expected Output

```text
Module Design Information
=========================
Module: counter
Designer: teekam
Bit Width: 8
Clock: 100 MHz
Period: 10 ns
```

---

# Task 2 - File Counter Script

Create **`count_files.sh`** that:

- Counts all `.v` files in the current directory
- Counts all `.log` files
- Calculates the total number of both file types
- Prints a formatted summary

### Hint

```bash
ls *.v 2>/dev/null | wc -l
```

---

# Task 3 - Build Report Script

Create **`build_report.sh`** that stores:

- `project="VLSI_Project"`
- `build_time=$(date)`
- `modules_compiled=5`
- `errors=0`
- `warnings=2`

The script should:

- Print a formatted build report
- Display:

```
Build: SUCCESS
```

if there are no errors, otherwise print:

```
Build: FAILED
```

---

# Assignment 1 - Interactive Module Creator

Create **`create_module.sh`** that:

- Prompts for module name
- Prompts for input ports (comma-separated)
- Prompts for output ports (comma-separated)
- Prints a Verilog module template

---

# Assignment 2 - RTL File Analyzer

Create **`analyze_rtl.sh filename.v`**

The script should:

- Accept filename as `$1`
- Count total lines
- Count occurrences of `module`
- Count occurrences of `always`
- Print a summary report

---

# Assignment 3 - Smart Simulator

Create **`run_sim.sh`**

Behavior:

- If two arguments are provided:
  - Use them as design file and testbench
- If no arguments are provided:
  - Prompt the user interactively
- Automatically generate the output filename from the design name
- Print the simulation command

---

# Assignment 4 - Smart Compile Script

Create **`smart_compile.sh`**

Requirements:

- Accept design file as `$1`
- Accept testbench as `$2`
- Verify exactly two arguments are supplied
- Verify both files exist
- Display usage information if arguments are incorrect
- Print the compile command when validation succeeds

---

# Assignment 5 - Simulation Health Checker

Create **`sim_health.sh`**

The script should analyze:

```
logs/sim.log
```

Count:

- ERRORs
- WARNINGs

Health status:

| Errors | Status |
|---------|---------|
| 0 | HEALTHY |
| 1–3 | DEGRADED |
| 4+ | CRITICAL |

Warnings:

- 0 → Clean
- 1 or more → Has warnings

---

# Assignment 6 - RTL File Validator

Create **`validate_rtl.sh filename.v`**

Validate:

- File exists
- File is readable
- File is not empty
- File contains the word `module`

Print **PASS** or **FAIL** for each check.

---

# Assignment 7 - Batch RTL Processor

Create **`process_rtl.sh`**

The script should:

- Loop through every `.v` file inside `rtl/`
- Count lines using `wc -l`
- Print filename and line count
- Print the total line count across all files

---

# Assignment 8 - Retry Mechanism

Create **`retry_sim.sh`**

Requirements:

- Retry up to 5 times
- Print:

```
Attempt N
```

- Stop when attempt number equals 3
- If no success occurs, print:

```
All attempts failed
```

---

# Assignment 9 - Multi-Seed Test Runner

Create **`run_tests.sh`**

The script should:

- Iterate through seeds **1–10**
- Skip seeds divisible by **3**
- Print:

```
Running test with seed: X
```

- Count only executed tests
- Print the final count

---

# Assignment 10 - Configuration Sweep

Create **`config_sweep.sh`**

Nested loops:

### Widths

- 8
- 16
- 32

### Frequencies

- 50 MHz
- 100 MHz
- 200 MHz

For each combination:

- Calculate:

```
Period = 1000 / Frequency
```

Print:

```
Width: X, Freq: Y MHz, Period: Z ns
```

---

# Assignment 11 - Function Library

Create **`lib_functions.sh`**

Implement:

### `check_module(filename)`

- Return `0` if file contains `module`
- Otherwise return `1`

### `get_line_count(filename)`

- Print number of lines

### `format_size(bytes)`

- Convert bytes into KB

Test every function using sample files.

---

# Assignment 12 - Build Pipeline Functions

Create **`build_pipeline.sh`**

Implement:

### `log_step(message)`

Print:

```text
[HH:MM:SS] message
```

### `run_check(name, result)`

If result is 0:

```
✓ PASSED
```

Otherwise:

```
✗ FAILED
```

Use these functions to simulate:

- Three pipeline steps
- Two validation checks

---

# Assignment 13 - Directory Statistics

Create **`dir_stats.sh`**

Implement:

```bash
analyze_directory(dirname)
```

The function should:

- Count total files
- Count `.v` files
- Count total lines across all files
- Print a formatted summary

Call the function for:

```
rtl/
```

---

# Assignment 14 - Mini Test Framework

Create **`test_framework.sh`**

Implement:

### `assert_equals(actual, expected, test_name)`

Requirements:

- Use local variables
- Print PASS/FAIL
- Maintain global:
  - `pass_count`
  - `fail_count`

Execute at least **5 assertions**.

Print:

```
X/Y tests passed
```

---

# Assignment 15 - Module Inventory

Create **`module_inventory.sh`**

Requirements:

- Array of five module names
- Parallel array containing bit widths
- Print:

```
Module: X, Width: Y bits
```

Finally print total module count.

---

# Assignment 16 - RTL Filename Parser

Create **`parse_rtl_files.sh`**

The script should:

- Load all `.v` files inside `rtl/` into an array

For every file print:

- Full path
- Filename
- Basename (without extension)
- Extension

---

# Assignment 17 - Port List Processor

Create **`process_ports.sh`**

Input:

```text
clk,reset,enable,data_in,data_out
```

The script should:

- Split using `IFS`
- Print every port name in uppercase
- Print total number of ports
- Identify ports containing `"data"`

---

# Assignment 18 - Version Bumper (Challenge)

Create **`version_bump.sh`**

Starting filenames:

```text
design_v1.v
testbench_v1.v
wrapper_v1.v
```

For every file:

- Replace `v1` with `v2`
- Print:

```

---

