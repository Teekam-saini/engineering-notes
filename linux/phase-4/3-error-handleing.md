# Day 24: Exit Codes & Error Handling

## 1. Exit Codes

Every Linux command returns an exit code after running.

```text
0       = Success
1-255   = Failure
```

Examples:

```bash
ls existing_file.txt
echo $?

ls /nonexistent
echo $?
```

`$?` contains the exit code of the last command.

Important: `$?` changes after every command.

```bash
ls /nonexistent
echo "hello"
echo $?
```

The last `echo` returns `0`, so the original `ls` exit code is lost.

---

## 2. Using Exit Codes

Check whether a command succeeded:

```bash
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
```

Exit a script with a specific code:

```bash
exit 0    # Success
exit 1    # Failure
```

---

## 3. `&&` and `||`

### `&&`

Run the next command only if the previous command succeeds.

```bash
mkdir output && echo "Created"
```

Example:

```bash
iverilog -o sim.out design.v && vvp sim.out
```

### `||`

Run the next command only if the previous command fails.

```bash
mkdir output || echo "Failed"
```

They can be chained:

```bash
mkdir -p sim_output &&
iverilog -o sim_output/sim.out counter.v tb_counter.v &&
vvp sim_output/sim.out &&
echo "Pipeline complete!"
```

---

## 4. `set` Safety Options

These options make scripts safer.

```bash
set -e
```

Stop the script when a command fails.

```bash
set -u
```

Treat unset variables as errors.

```bash
set -o pipefail
```

Detect failures inside pipelines.

Recommended combination:

```bash
set -euo pipefail
```

Usually placed immediately after the shebang:

```bash
#!/bin/bash
set -euo pipefail
```

---

## 5. `trap`

`trap` runs a command or function when a specific event occurs.

Common signals:

```text
EXIT    Script exits
INT     Ctrl+C
TERM    Termination signal
ERR     Command failure
```

### Cleanup Example

```bash
cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT
```

The cleanup function runs automatically when the script exits.

### Ctrl+C

```bash
trap 'echo "Interrupted"; exit 1' INT
```

### Error Handling

```bash
on_error() {
    echo "Error at line $1"
}

trap 'on_error $LINENO' ERR
```

`$LINENO` gives the current line number.

---

## 6. Custom Exit Codes

Using different codes makes scripts easier to understand.

```bash
readonly E_SUCCESS=0
readonly E_NO_FILES=1
readonly E_COMPILE_FAIL=2
readonly E_SIM_FAIL=3
readonly E_MISSING_TOOL=4
```

Example:

```bash
if ! which iverilog > /dev/null 2>&1; then
    echo "iverilog not found"
    exit $E_MISSING_TOOL
fi
```

A script can therefore communicate exactly what went wrong.

---

## 7. Logging Errors

A simple logging function:

```bash
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')

    echo "[$timestamp] [$level] $message"
}
```

Usage:

```bash
log "INFO" "Build started"
log "ERROR" "Compilation failed"
```

Save errors to a file:

```bash
iverilog -o sim.out design.v 2>>build.log
```

`2>>` redirects stderr to the log file.

---

## 8. Professional Script Structure

A basic safe script structure:

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Cleaning up..."
}

trap cleanup EXIT
trap 'echo "Interrupted"; exit 1' INT

# Main script
```

---

## Key Concepts

```bash
$?                  # Exit code of last command

exit 0              # Success
exit 1              # Failure

command && next     # Run next if successful
command || next     # Run next if failed

set -e              # Exit on error
set -u              # Error on unset variables
set -o pipefail     # Detect pipeline failures
set -euo pipefail   # Combine all three

trap ... EXIT       # Run when script exits
trap ... ERR        # Run on command error
trap ... INT        # Handle Ctrl+C

$LINENO             # Current line number
```

## Core Idea

```text
Command
   ↓
Exit Code
   ↓
Success (0) or Failure (non-zero)
   ↓
Script decides what to do
   ↓
Handle error / cleanup / exit
```

