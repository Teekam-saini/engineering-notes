````md id="7v6m8p"

# Shell Script

# What is a Shell Script?

A shell script is a text file containing Linux commands that execute in sequence.

Instead of typing commands repeatedly, commands are written once and executed whenever required.

## VLSI Usage

- Automate compilation
- Run simulations
- Generate reports
- Manage RTL files
- Automate repetitive workflows


---

# Script Structure


## 1. Shebang

Defines which interpreter executes the script.

```bash
#!/bin/bash
````

Uses Bash shell.

Other examples:

```bash
#!/bin/sh
```

Uses default shell.

```bash
#!/usr/bin/env bash
```

Finds bash using PATH.

The shebang must be the first line of the script.

---

# 2. Comments

Comments explain code and are ignored by the shell.

```bash
# This is a comment

echo "Hello"   # Inline comment
```

---

# 3. Variables

Variables store data for later use.

## Creating Variables

Syntax:

```bash
variable=value
```

Example:

```bash
name="teekam"
project="riscv_cpu"
count=32
```

Rules:

* No spaces around `=`
* Use `$` to access variables
* Use meaningful names

Wrong:

```bash
name = "teekam"
```

Correct:

```bash
name="teekam"
```

---

# Using Variables

```bash
echo "Name: $name"

echo "Project: $project"

echo "Count: $count"
```

---

# Command Substitution

Stores command output inside a variable.

Syntax:

```bash
variable=$(command)
```

Example:

```bash
files=$(ls *.v | wc -l)

echo "Verilog files: $files"
```

Common uses:

* Counting files
* Getting dates
* Storing command results

---

# Variable Naming Rules

Good:

```bash
module_name="alu"

rtl_file_count=10
```

Constants:

```bash
MAX_WIDTH=64
```

Rules:

* Use lowercase with underscores
* Use descriptive names
* Use uppercase for constants

---

# Built-in Shell Variables

| Variable | Meaning           |
| -------- | ----------------- |
| `$USER`  | Current username  |
| `$HOME`  | Home directory    |
| `$SHELL` | Current shell     |
| `$PWD`   | Current directory |
| `$0`     | Script name       |

Example:

```bash
echo "User: $USER"

echo "Home: $HOME"

echo "Directory: $PWD"
```

---

# echo Command

Used to print output.

Basic:

```bash
echo "Hello"
```

Print variable:

```bash
echo "User: $USER"
```

Arithmetic:

```bash
echo "$((5+3))"
```

No newline:

```bash
echo -n "Hello"
```

Escape characters:

```bash
echo -e "Line1\nLine2"
```

---

# Making Scripts Executable

Give execute permission:

```bash
chmod +x script.sh
```

Run script:

```bash
./script.sh
```

Without execute permission:

```bash
./script.sh
```

Output:

```text
Permission denied
```

---

# Bash Arithmetic

Preferred method:

```bash
a=10
b=5

sum=$((a+b))

echo $sum
```

Operations:

```text
+   Addition
-   Subtraction
*   Multiplication
/   Division
%   Modulus
```

Example:

```bash
period=$((1000 / frequency))
```

---

# expr Command

Old arithmetic method:

```bash
expr 10 + 5
```

Preferred:

```bash
$(( ))
```

---

# Useful Script Patterns

## Store Date

```bash
timestamp=$(date)
```

## Count Files

```bash
count=$(ls *.v 2>/dev/null | wc -l)
```

## Combine Variables

```bash
module="alu"

file="${module}.v"
```

Output:

```text
alu.v
```

---

# VLSI Automation Examples

## Run Simulation

```bash
./run_sim.sh
```

## Count RTL Files

```bash
rtl_count=$(ls rtl/*.v | wc -l)
```

## Generate Report

```bash
echo "Simulation completed at $(date)"
```

---

# Command Summary

| Command            | Purpose                |
| ------------------ | ---------------------- |
| `chmod +x file.sh` | Make script executable |
| `./script.sh`      | Run script             |
| `echo`             | Print output           |
| `$(command)`       | Store command output   |
| `$variable`        | Access variable        |
| `$(( ))`           | Arithmetic calculation |
| `date`             | Get current date/time  |

---

# Questions and Answers

## 1. What is the purpose of `#!/bin/bash`?

Answer:

It tells Linux to execute the script using the Bash interpreter.

It must be placed on the first line of the script.

---

## 2. Why does Bash not allow spaces around `=` during variable assignment?

Answer:

Because Bash interprets spaces as command separators.

Example:

Wrong:

```bash
name = "teekam"
```

Bash thinks `name` is a command.

Correct:

```bash
name="teekam"
```

---

## 3. Difference between `$name` and `${name}`?

Answer:

`$name` is used for normal variable access.

Example:

```bash
echo $name
```

`${name}` is used when combining variables with other text.

Example:

```bash
filename="${name}_project"
```

It prevents confusion between variable names and surrounding characters.

---

## 4. How do you store output of a Linux command inside a variable?

Answer:

Use command substitution:

```bash
files=$(ls)
```

The command output is stored inside the variable.

---

## 5. Why is `chmod +x` required before running `./script.sh`?

Answer:

Linux requires execute permission to run a file as a program.

Command:

```bash
chmod +x script.sh
```

adds execute permission.

---

## 6. Difference between normal variable and environment variable?

Answer:

Normal variable:

* Exists only inside the current shell/script.
* Not available to child processes.

Example:

```bash
name="teekam"
```

Environment variable:

* Available to child processes.
* Exported using `export`.

Example:

```bash
export PATH
```

---

## 7. Calculate period of a 200 MHz clock in Bash.

Formula:

```text
Period(ns) = 1000 / Frequency(MHz)
```

Bash:

```bash
frequency=200

period=$((1000 / frequency))

echo $period
```

Output:

```text
5
```

---

## 8. Why are shell scripts useful in VLSI workflows?

Answer:

Shell scripts automate repetitive tasks such as:

* Running simulations
* Compiling RTL files
* Organizing project files
* Generating reports
* Running synthesis flows

They reduce manual errors and make workflows repeatable.

```
```
I will format future Linux notes as clean Markdown only, without practice setup, assignments, or emojis. I’ll keep commands, concepts, examples, and normal questions with answers at the end. Here is the rewritten Day 9:

````md
### User Input & Command-Line Arguments

## Goal

Learn how shell scripts accept input from users and process values passed during execution.

Two ways to get input:

1. Interactive Input (`read`)
2. Command-Line Arguments (`$1`, `$2`, `$@`)

---

# 1. Interactive Input Using read

`read` pauses the script and waits for user input.

## Basic Syntax

```bash
read variable_name
````

Example:

```bash
read name
echo "Hello $name"
```

---

## read With Prompt

```bash
read -p "Enter name: " name
echo "Name: $name"
```

`-p` displays a message before taking input.

---

## Silent Input

Used for passwords.

```bash
read -s password
```

Input will not be displayed on the terminal.

---

## Multiple Inputs

```bash
read module designer

echo "Module: $module"
echo "Designer: $designer"
```

Example input:

```text
alu teekam
```

Output:

```text
Module: alu
Designer: teekam
```

---

# 2. Command-Line Arguments

Arguments are values passed while running a script.

Example:

```bash
./script.sh value1 value2
```

Special variables:

| Variable | Meaning                     |
| -------- | --------------------------- |
| `$0`     | Script name                 |
| `$1`     | First argument              |
| `$2`     | Second argument             |
| `$3`     | Third argument              |
| `$#`     | Number of arguments         |
| `$@`     | All arguments separately    |
| `$*`     | All arguments as one string |

---

## Basic Argument Example

Script:

```bash
#!/bin/bash

echo "Script: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total arguments: $#"
```

Run:

```bash
./script.sh alu.v tb_alu.v
```

Output:

```text
Script: ./script.sh
First argument: alu.v
Second argument: tb_alu.v
Total arguments: 2
```

---

# Processing Multiple Arguments Using $@

Example:

```bash
#!/bin/bash

for file in "$@"
do
    echo "Processing: $file"
done
```

Run:

```bash
./script.sh alu.v cpu.v regfile.v
```

Output:

```text
Processing: alu.v
Processing: cpu.v
Processing: regfile.v
```

---

# Combining read and Arguments

A script can use arguments if provided, otherwise ask the user.

Example:

```bash
#!/bin/bash

if [ $# -eq 2 ]
then
    design=$1
    testbench=$2
else
    read -p "Design file: " design
    read -p "Testbench file: " testbench
fi

echo "Design: $design"
echo "Testbench: $testbench"
```

Usage:

With arguments:

```bash
./compile.sh alu.v tb_alu.v
```

Without arguments:

```bash
./compile.sh
```

The script asks for input.

---

# Default Values

Syntax:

```bash
variable=${1:-"default"}
```

Meaning:

Use `$1` if available, otherwise use `"default"`.

Example:

```bash
designer=${1:-"unknown"}

echo "Designer: $designer"
```

Run:

```bash
./script.sh
```

Output:

```text
Designer: unknown
```

Run:

```bash
./script.sh teekam
```

Output:

```text
Designer: teekam
```

---

# Checking Arguments

Check if no arguments are provided:

```bash
if [ $# -eq 0 ]
then
    echo "No arguments"
fi
```

Common checks:

```bash
[ $# -eq 0 ]   # No arguments
[ $# -eq 2 ]   # Exactly two arguments
[ $# -gt 2 ]   # More than two arguments
```

---

# VLSI Automation Examples

## Compile Script Pattern

```bash
#!/bin/bash

design=$1
testbench=$2

iverilog -o sim.out $design $testbench
vvp sim.out
```

Run:

```bash
./compile.sh alu.v tb_alu.v
```

---

## Batch Processing Pattern

Process multiple files:

```bash
#!/bin/bash

for file in "$@"
do
    echo "Processing $file"
done
```

Example:

```bash
./process.sh alu.v cpu.v memory.v
```

---

## Interactive Configuration Pattern

```bash
#!/bin/bash

read -p "Clock frequency: " freq
read -p "Data width: " width

period=$((1000 / freq))

echo "Clock: $freq MHz"
echo "Width: $width bits"
echo "Period: $period ns"
```

---

# Important Bash Rules

## Variable Assignment

Correct:

```bash
name="teekam"
```

Wrong:

```bash
name = "teekam"
```

Spaces around `=` are not allowed.

---

## Variable Access

```bash
$name
```

Example:

```bash
echo $name
```

---

## Command Substitution

Store command output:

```bash
files=$(ls *.v | wc -l)

echo $files
```

---

# Difference Between $name and ${name}

`$name`

Simple variable expansion.

Example:

```bash
echo $name
```

`${name}`

Used when adding text directly after variable.

Example:

```bash
file="alu"

echo "${file}_test.v"
```

Output:

```text
alu_test.v
```

Without braces:

```bash
echo "$file_test.v"
```

Bash searches for variable `file_test`, not `file`.

---

# Key Concepts Summary

| Concept         | Command                   |
| --------------- | ------------------------- |
| User input      | `read variable`           |
| Prompt input    | `read -p "text" variable` |
| First argument  | `$1`                      |
| Second argument | `$2`                      |
| Argument count  | `$#`                      |
| All arguments   | `$@`                      |
| Default value   | `${var:-default}`         |
| Command output  | `$(command)`              |

---

# Questions and Answers

## 1. What is the purpose of `read`?

`read` takes input from the user while the script is running and stores it in a variable.

Example:

```bash
read name
```

---

## 2. What does `$1` represent?

`$1` represents the first command-line argument passed to the script.

Example:

```bash
./script.sh alu.v
```

Inside script:

```bash
echo $1
```

Output:

```text
alu.v
```

---

## 3. Difference between `$@` and `$*`?

`$@` treats each argument separately.

Example:

```bash
"$@"
```

Arguments:

```text
alu.v cpu.v
```

remain:

```text
alu.v
cpu.v
```

`$*` combines all arguments into one string.

---

## 4. How do you check the number of arguments?

Use:

```bash
$#
```

Example:

```bash
if [ $# -eq 2 ]
then
    echo "Two arguments received"
fi
```

---

## 5. How do you provide a default value if an argument is missing?

Use:

```bash
variable=${1:-"default"}
```

Example:

```bash
project=${1:-"test_project"}
```

If no argument is provided:

```text
test_project
```

is used.

---

## 6. Why are command-line arguments useful in VLSI workflows?

They allow automation scripts to work with different files without editing the script every time.

Example:

```bash
./compile.sh alu.v tb_alu.v
./compile.sh cpu.v tb_cpu.v
```

The same script can compile different designs.

```
```

````md
### Conditionals (if/else, test, comparisons)

## Goal

Learn how to make shell scripts take decisions based on conditions.

Conditionals allow scripts to:

- Check if files exist before processing
- Validate user input
- Detect simulation failures
- Handle errors automatically
- Make build and verification scripts smarter

---

# Basic if/else Syntax

```bash
if [ condition ]; then
    # commands when condition is true
elif [ condition ]; then
    # commands when another condition is true
else
    # commands when all conditions are false
fi
````

Important rules:

```bash
[ condition ]
```

Correct:

```bash
if [ $value -eq 10 ]; then
```

Wrong:

```bash
if [$value -eq 10]; then
```

Rules:

* Spaces are required inside `[ ]`
* Every `if` must end with `fi`
* `then` starts the command block

---

# Numeric Comparisons

Used for numbers.

| Operator | Meaning               |
| -------- | --------------------- |
| `-eq`    | Equal                 |
| `-ne`    | Not equal             |
| `-lt`    | Less than             |
| `-gt`    | Greater than          |
| `-le`    | Less than or equal    |
| `-ge`    | Greater than or equal |

Examples:

```bash
if [ $a -eq $b ]; then
    echo "Equal"
fi
```

```bash
if [ $count -gt 10 ]; then
    echo "Large value"
fi
```

---

# String Comparisons

Used for text.

```bash
[ "$a" = "$b" ]
```

Strings are equal.

```bash
[ "$a" != "$b" ]
```

Strings are different.

Check empty string:

```bash
[ -z "$value" ]
```

String is empty.

Check non-empty string:

```bash
[ -n "$value" ]
```

String contains something.

Example:

```bash
if [ "$status" = "PASS" ]; then
    echo "Simulation passed"
fi
```

---

# File Checks

| Command | Meaning                      |
| ------- | ---------------------------- |
| `-f`    | File exists                  |
| `-d`    | Directory exists             |
| `-r`    | File is readable             |
| `-w`    | File is writable             |
| `-x`    | File is executable           |
| `-s`    | File exists and is not empty |

Examples:

Check file:

```bash
if [ -f "alu.v" ]; then
    echo "File exists"
fi
```

Check directory:

```bash
if [ -d "rtl" ]; then
    echo "RTL directory found"
fi
```

---

# `[ ]` vs `[[ ]]`

## Single Brackets

POSIX compatible:

```bash
if [ "$name" = "teekam" ]; then
```

## Double Brackets

Bash specific and more powerful:

```bash
if [[ $name == "teekam" ]]; then
```

Advantages:

```bash
[[ $name == tee* ]]
```

Supports wildcard matching.

Logical operators:

```bash
[[ $a -gt 5 && $b -lt 10 ]]
```

Recommended for Bash scripts:

```bash
[[ ]]
```

---

# Logical Operators

## AND

Both conditions must be true.

```bash
if [ $a -gt 0 ] && [ $b -gt 0 ]; then
    echo "Both positive"
fi
```

---

## OR

At least one condition must be true.

```bash
if [ $a -gt 0 ] || [ $b -gt 0 ]; then
    echo "One is positive"
fi
```

---

## NOT

Reverse condition.

```bash
if [ ! -f "file.v" ]; then
    echo "File missing"
fi
```

---

# Example: File Validation

```bash
#!/bin/bash

file=$1

if [ -f "$file" ]; then
    echo "File exists"
else
    echo "File not found"
fi
```

Run:

```bash
./check.sh alu.v
```

---

# Example: Error Checking

```bash
#!/bin/bash

errors=$(grep -c "ERROR" simulation.log)

if [ $errors -eq 0 ]; then
    echo "PASSED"
elif [ $errors -le 3 ]; then
    echo "WARNING"
else
    echo "FAILED"
fi
```

---

# Example: Argument Validation

```bash
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "File does not exist"
    exit 1
fi

echo "File ready"
```

---

# Example: VLSI Timing Check

```bash
#!/bin/bash

read -p "Enter slack: " slack
read -p "Enter errors: " errors

if [ $slack -ge 0 ]; then
    echo "Timing PASS"
else
    echo "Timing FAIL"
fi


if [ $errors -eq 0 ]; then
    echo "No errors"
else
    echo "Errors found"
fi
```

---

# Exit Codes

Every Linux command returns a status code.

```text
0 = Success
non-zero = Failure
```

Check last command status:

```bash
echo $?
```

Example:

```bash
grep "ERROR" sim.log

echo $?
```

Output:

```text
0
```

means pattern found.

Output:

```text
1
```

means not found.

---

# exit Command

Return status from script.

Success:

```bash
exit 0
```

Failure:

```bash
exit 1
```

Example:

```bash
if [ $errors -gt 0 ]; then
    echo "Build failed"
    exit 1
fi
```

---

# Common VLSI Script Patterns

## Check Arguments

```bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 design testbench"
    exit 1
fi
```

---

## Check File Exists

```bash
if [ ! -f "$file" ]; then
    echo "File missing"
    exit 1
fi
```

---

## Check Command Success

```bash
command

if [ $? -ne 0 ]; then
    echo "Command failed"
    exit 1
fi
```

---

# Key Concepts Summary

| Concept             | Syntax                   |
| ------------------- | ------------------------ |
| if statement        | `if [ condition ]; then` |
| else                | `else`                   |
| multiple conditions | `elif`                   |
| close if            | `fi`                     |
| number comparison   | `-eq -lt -gt`            |
| string comparison   | `= !=`                   |
| file check          | `-f -d -r -x`            |
| exit status         | `$?`                     |
| exit script         | `exit code`              |

---

# Questions and Answers

## 1. Why are spaces required inside `[ ]`?

`[ ]` is actually a command called `test`.

Correct:

```bash
[ $a -eq 5 ]
```

The shell sees:

```text
test $a -eq 5
```

Without spaces:

```bash
[$a -eq 5]
```

The shell treats it as one invalid command.

---

## 2. Difference between `-eq` and `=`?

`-eq` compares numbers.

Example:

```bash
[ 10 -eq 10 ]
```

`=` compares strings.

Example:

```bash
[ "PASS" = "PASS" ]
```

---

## 3. What does `$?` store?

It stores the exit code of the last executed command.

Example:

```bash
ls file.txt

echo $?
```

Output:

```text
0
```

means success.

---

## 4. Difference between `exit 0` and `exit 1`?

`exit 0`:

* Script completed successfully

`exit 1`:

* Script failed or encountered an error

Used by automation tools to detect failures.

---

## 5. Why use conditionals in VLSI automation?

Conditionals prevent scripts from blindly running incorrect operations.

Examples:

* Stop compilation if RTL files are missing
* Detect failed simulations
* Check timing violations
* Generate reports only after successful runs

```
```
## Functions (Definition, Arguments, Return Values, Scope)

## Goal

* Understand functions in Bash
* Write reusable code blocks
* Pass arguments to functions
* Handle return values
* Understand local and global variables
* Organize VLSI automation scripts properly

---

# Why Functions Matter

Without functions:

* Code gets repeated
* Fixing bugs becomes difficult
* Scripts become large and messy

With functions:

* Write logic once and reuse it
* Easier debugging
* Better script organization
* Create reusable VLSI automation tools

Examples in VLSI:

* File validation functions
* Compilation checks
* Report generation
* Timing analysis helpers

---

# Basic Function Syntax

Method 1:

```bash
function_name() {
    commands
}
```

Method 2:

```bash
function function_name {
    commands
}
```

Calling a function:

```bash
function_name
```

Functions are called by their name without parentheses.

---

# Simple Function Example

```bash
#!/bin/bash

greet() {
    echo "Hello from function"
}

echo "Before function"

greet

echo "After function"
```

Output:

```text
Before function
Hello from function
After function
```

---

# Passing Arguments to Functions

Functions have their own arguments.

Special variables:

```bash
$1    First argument
$2    Second argument
$3    Third argument
$@    All arguments
$#    Number of arguments
```

Example:

```bash
#!/bin/bash

print_module_info() {

    module_name=$1
    width=$2

    echo "Module: $module_name"
    echo "Width: $width bits"
}

print_module_info counter 8
print_module_info alu 32
```

Output:

```text
Module: counter
Width: 8 bits

Module: alu
Width: 32 bits
```

---

# Return Values in Bash

Bash functions return values in two ways.

---

# Method 1: return

`return` is used for status codes.

Range:

```text
0 - 255
```

Usually:

```text
0 = success
1 = failure
```

Example:

```bash
check_even() {

    num=$1

    if [ $((num % 2)) -eq 0 ]; then
        return 0
    else
        return 1
    fi
}


check_even 10

if [ $? -eq 0 ]; then
    echo "Even number"
fi
```

---

# Method 2: Using echo as Return Value

For returning actual data:

```bash
calculate_period() {

    freq=$1

    period=$((1000 / freq))

    echo $period
}


result=$(calculate_period 100)

echo "Period: $result ns"
```

Output:

```text
Period: 10 ns
```

---

# Local and Global Variables

By default, Bash variables inside functions are global.

Example:

```bash
counter=10

change_value(){

    counter=100

}

echo $counter

change_value

echo $counter
```

Output:

```text
10
100
```

The function modified the original variable.

---

# Using local Variables

Use `local` to keep variables inside functions.

Example:

```bash
counter=10

change_value(){

    local counter=100

    echo $counter
}


echo $counter

change_value

echo $counter
```

Output:

```text
10
100
10
```

Rule:

Use `local` inside functions unless you intentionally want to modify a global variable.

---

# VLSI Example: Validation Functions

```bash
check_file_exists(){

    local file=$1

    if [ -f "$file" ]; then
        echo "PASS: File exists"
        return 0
    else
        echo "FAIL: File missing"
        return 1
    fi

}


calculate_period(){

    local freq=$1

    echo $((1000 / freq))

}
```

Usage:

```bash
check_file_exists alu.v

period=$(calculate_period 200)

echo "Clock period: $period ns"
```

---

# Functions Calling Other Functions

Functions can call other functions.

Example:

```bash
is_valid(){

    local file=$1

    [ -f "$file" ] && [ -s "$file" ]

}


process_file(){

    local file=$1

    if is_valid "$file"; then
        echo "Processing $file"
    else
        echo "Invalid file"
    fi

}
```

This helps create modular scripts.

---

# Handling Multiple Arguments

Using `$@`:

```bash
process_files(){

    for file in "$@"
    do
        echo "Processing $file"
    done

}


process_files alu.v counter.v regfile.v
```

Output:

```text
Processing alu.v
Processing counter.v
Processing regfile.v
```

---

# Function Design Rules

Good Bash functions should:

* Have one clear purpose
* Use local variables
* Accept arguments instead of depending on global variables
* Return useful status codes
* Avoid unnecessary repeated code

---

# VLSI Automation Usage

Functions are useful for:

## Compilation

```bash
compile_design()
```

Runs synthesis or simulation commands.

## Validation

```bash
check_rtl()
```

Checks Verilog files.

## Reports

```bash
generate_report()
```

Creates timing or area reports.

## Testing

```bash
run_test()
```

Automates verification.

---

# Key Patterns To Remember

Function with arguments:

```bash
my_function(){

    local value=$1

    echo $value

}
```

Capture output:

```bash
result=$(my_function data)
```

Return status:

```bash
check(){

    return 0

}


if check; then
    echo "Success"
fi
```

Multiple arguments:

```bash
for arg in "$@"
do
    echo $arg
done
```

---

# Questions

## 1. How do you define a function in Bash?

Answer:

A function is defined using:

```bash
function_name(){

    commands

}
```

Example:

```bash
hello(){

echo "Hello"

}
```

---

## 2. How are function arguments different from script arguments?

Answer:

Both use `$1`, `$2`, etc., but their scope is different.

Script arguments:

```bash
./script.sh file.v
```

`$1` represents the script argument.

Function arguments:

```bash
my_function file.v
```

Inside the function, `$1` represents the function argument.

---

## 3. What is the difference between return and echo in functions?

Answer:

`return` sends an exit status:

```bash
return 0
```

Used for success/failure checking.

`echo` sends actual data:

```bash
echo "result"
```

Used when returning values like numbers or strings.

---

## 4. Why should we use local variables inside functions?

Answer:

Without `local`, variables modify global variables and may create unexpected bugs.

Example:

```bash
local count=10
```

keeps the variable limited to that function.

---

## 5. What does `$@` represent?

Answer:

`$@` represents all function or script arguments separately.

Example:

```bash
for file in "$@"
do
    echo $file
done
```

Processes every argument individually.

---

## 6. What happens if a function does not use local variables?

Answer:

Variables created inside the function become global and can affect the rest of the script.

This can cause difficult debugging problems.

---

## 7. How do you capture the output of a function?

Answer:

Using command substitution:

```bash
result=$(function_name)
```

Example:

```bash
period=$(calculate_period 100)
```

---

## 8. What is the maximum value that can be returned using return?

Answer:

Bash return values are exit codes and can only be between:

```text
0-255
```

For larger values or strings, use `echo` and capture the output.
````
````
# Arrays & String Manipulation

## Goal

* Understand Bash arrays
* Store and process multiple values
* Loop through collections of data
* Manipulate strings and filenames
* Build dynamic names and paths
* Prepare for VLSI automation scripts

---

# Why Arrays and String Manipulation Matter for VLSI

Arrays are useful for storing:

* Module names
* Verilog file lists
* Test cases
* Simulation configurations

String manipulation is useful for:

* Extracting module names from filenames
* Changing file versions
* Creating dynamic paths
* Parsing reports and logs

Examples:

```text
counter_8bit_v1.v

counter     -> module name
8bit        -> width information
v1          -> version
.v          -> extension
````

---

# Arrays in Bash

Arrays store multiple values in one variable.

---

# Creating Arrays

## Method 1: Direct Assignment

```bash
modules=("alu" "counter" "regfile" "decoder")
```

---

## Method 2: Using declare

```bash
declare -a files

files=("a.v" "b.v" "c.v")
```

---

## Method 3: Index Assignment

```bash
arr[0]="first"
arr[1]="second"
```

Array indexing starts from:

```text
0
```

---

# Accessing Array Elements

Example:

```bash
modules=("alu" "counter" "regfile" "decoder")

echo ${modules[0]}
echo ${modules[1]}
```

Output:

```text
alu
counter
```

---

# Important Array Syntax

| Syntax         | Meaning            |
| -------------- | ------------------ |
| `${array[0]}`  | First element      |
| `${array[@]}`  | All elements       |
| `${#array[@]}` | Number of elements |
| `${array[-1]}` | Last element       |

Example:

```bash
echo "Modules: ${modules[@]}"

echo "Count: ${#modules[@]}"
```

---

# Looping Through Arrays

## Loop Through Values

```bash
for module in "${modules[@]}"
do
    echo "Module: $module"
done
```

Output:

```text
Module: alu
Module: counter
Module: regfile
```

---

## Loop Through Index

```bash
for i in "${!modules[@]}"
do
    echo "Index $i: ${modules[$i]}"
done
```

Output:

```text
Index 0: alu
Index 1: counter
```

---

# Adding and Removing Array Elements

Create array:

```bash
modules=("alu" "counter")
```

Add element:

```bash
modules+=("regfile")
```

Add multiple elements:

```bash
modules+=("decoder" "fifo")
```

Remove element:

```bash
unset modules[1]
```

---

# Creating Arrays From Commands

Example:

Get all Verilog files:

```bash
files=(rtl/*.v)
```

Now the array contains:

```text
rtl/alu.v
rtl/counter.v
rtl/register.v
```

Count files:

```bash
echo ${#files[@]}
```

---

# String Manipulation

Bash provides built-in string processing.

---

# String Length

Example:

```bash
name="counter_module"

echo ${#name}
```

Output:

```text
14
```

---

# Extracting Substrings

Syntax:

```bash
${variable:start:length}
```

Example:

```bash
name="counter_module"

echo ${name:0:7}
```

Output:

```text
counter
```

From position 8:

```bash
echo ${name:8}
```

Output:

```text
module
```

---

# Replace Text

## Replace First Match

```bash
filename="design_v1.v"

echo ${filename/v1/v2}
```

Output:

```text
design_v2.v
```

---

## Replace All Matches

```bash
text="error error error"

echo ${text//error/ERROR}
```

Output:

```text
ERROR ERROR ERROR
```

---

# Removing Prefix

Example:

```bash
path="/home/user/rtl/counter.v"
```

Remove shortest match:

```bash
echo ${path#*/}
```

Output:

```text
home/user/rtl/counter.v
```

Remove longest match:

```bash
echo ${path##*/}
```

Output:

```text
counter.v
```

---

# Removing Suffix

Example:

```bash
filename="design_v1.v"
```

Remove extension:

```bash
echo ${filename%.v}
```

Output:

```text
design_v1
```

Remove version:

```bash
echo ${filename%_*}
```

Output:

```text
design
```

---

# Case Conversion

Convert uppercase:

```bash
name="Counter_Module"

echo ${name^^}
```

Output:

```text
COUNTER_MODULE
```

Convert lowercase:

```bash
echo ${name,,}
```

Output:

```text
counter_module
```

---

# Extracting Filename Information

Example:

```bash
filepath="rtl/core/counter_8bit_v2.v"
```

Get filename:

```bash
filename=${filepath##*/}
```

Output:

```text
counter_8bit_v2.v
```

---

Get extension:

```bash
extension=${filename##*.}
```

Output:

```text
v
```

---

Remove extension:

```bash
basename=${filename%.*}
```

Output:

```text
counter_8bit_v2
```

---

Get directory:

```bash
directory=${filepath%/*}
```

Output:

```text
rtl/core
```

---

# Splitting Strings Into Arrays

Example:

```bash
ports="clk,rst,data_in,data_out"
```

Split using comma:

```bash
IFS=',' read -ra port_array <<< "$ports"
```

Now:

```text
port_array[0] = clk
port_array[1] = rst
port_array[2] = data_in
```

---

# IFS (Internal Field Separator)

IFS tells Bash how to split text.

Default:

```text
space
tab
newline
```

Example:

```bash
IFS=','
```

Now Bash splits using:

```text
,
```

---

# Combining Arrays and Strings

Example:

```bash
files=("alu_v1.v" "counter_v1.v")

for file in "${files[@]}"
do

    new_name=${file/v1/v2}

    echo "$file -> $new_name"

done
```

Output:

```text
alu_v1.v -> alu_v2.v
counter_v1.v -> counter_v2.v
```

---

# VLSI Usage Examples

## Batch Compilation

Store files:

```bash
rtl_files=("alu.v" "control.v" "regfile.v")
```

Compile each:

```bash
for file in "${rtl_files[@]}"
do
    iverilog $file
done
```

---

## Automatic Version Update

Before:

```text
cpu_v1.v
alu_v1.v
```

After:

```text
cpu_v2.v
alu_v2.v
```

Using:

```bash
${file/v1/v2}
```

---

## Report Processing

Extract:

```text
module name
file extension
version number
```

using string operations.

---

# Key Patterns To Remember

## Array Basics

```bash
arr=("a" "b" "c")

echo "${arr[@]}"
echo "${#arr[@]}"
```

---

## String Replacement

Replace first:

```bash
${var/old/new}
```

Replace all:

```bash
${var//old/new}
```

---

## Remove Prefix

Shortest:

```bash
${var#pattern}
```

Longest:

```bash
${var##pattern}
```

---

## Remove Suffix

Shortest:

```bash
${var%pattern}
```

Longest:

```bash
${var%%pattern}
```

---

## Split String

```bash
IFS=',' read -ra arr <<< "$string"
```

---

# Questions

## 1. What index does Bash array start from?

Answer:

Bash arrays start from index:

```text
0
```

Example:

```bash
arr=("a" "b")

echo ${arr[0]}
```

Output:

```text
a
```

---

## 2. How do you print all elements of an array?

Answer:

Use:

```bash
${array[@]}
```

Example:

```bash
echo "${modules[@]}"
```

---

## 3. What does `${#array[@]}` do?

Answer:

It returns the number of elements in an array.

Example:

```bash
modules=("alu" "cpu")

echo ${#modules[@]}
```

Output:

```text
2
```

---

## 4. What is the difference between `${var/old/new}` and `${var//old/new}`?

Answer:

`${var/old/new}` replaces only the first occurrence.

Example:

```bash
error error
```

becomes:

```text
ERROR error
```

`${var//old/new}` replaces all occurrences.

Result:

```text
ERROR ERROR
```

---

## 5. What does `${filename##*/}` do?

Answer:

It removes everything before the last `/`.

Example:

```bash
/home/user/test.v
```

becomes:

```text
test.v
```

It is commonly used to extract filenames from paths.

---

## 6. What does IFS mean?

Answer:

IFS means Internal Field Separator.

It tells Bash how to split strings into multiple fields.

Example:

```bash
IFS=','
```

splits comma-separated values.

---

## 7. How do you convert a string to uppercase in Bash?

Answer:

Use:

```bash
${variable^^}
```

Example:

```bash
name="alu"

echo ${name^^}
```

Output:

```text
ALU
```

---

## 8. Why are arrays useful in VLSI automation?

Answer:

Arrays allow scripts to process multiple files, modules, or test cases automatically instead of writing commands repeatedly.

Example:

```bash
rtl_files=("alu.v" "cpu.v" "memory.v")
```

A loop can then compile or analyze every file automatically.

```
```
