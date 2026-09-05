# Week 4: Day 22 — Environment Variables

## 1. What Are Environment Variables?

Environment variables are `key=value` settings available to the shell and programs.

```bash
HOME=/home/teekam
USER=teekam
SHELL=/bin/bash
PATH=/usr/bin:/bin
```

Use `$` to get the value:

```bash
echo "$HOME"
echo "$USER"
```

---

## 2. Viewing Variables

```bash
printenv              # All environment variables
printenv PATH         # Specific variable
echo "$PATH"          # Print variable
env                   # Environment variables
set                   # Shell variables + functions + environment
```

Important variables:

```bash
$HOME       # Home directory
$USER       # Username
$PATH       # Command search paths
$SHELL      # Login shell
$PWD        # Current directory
$OLDPWD     # Previous directory
$HOSTNAME   # Computer name
$EDITOR     # Default editor
$LANG       # Locale
```

---

## 3. Shell Variable vs Environment Variable

Normal variable:

```bash
PROJECT="riscv_cpu"
```

Only the current shell knows it.

Exported variable:

```bash
export PROJECT="riscv_cpu"
```

Child processes can now access it.

Example:

```bash
export MY_VAR="hello"
bash -c 'echo "$MY_VAR"'
```

Output:

```text
hello
```

Without `export`, the child normally sees nothing.

---

## 4. The PATH Variable

`PATH` tells the shell where to search for commands.

```bash
echo "$PATH"
```

Example:

```text
/usr/local/bin:/usr/bin:/bin
```

Directories are separated by `:`.

Add a directory temporarily:

```bash
export PATH="$PATH:$HOME/bin"
```

View PATH one directory per line:

```bash
echo "$PATH" | tr ':' '\n'
```

Find a command:

```bash
command -v iverilog
```

Never accidentally replace the whole PATH:

```bash
# BAD
export PATH="/home/teekam/bin"

# GOOD
export PATH="$PATH:/home/teekam/bin"
```

---

## 5. Permanent PATH

Add it to `~/.bashrc`:

```bash
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
```

Reload:

```bash
source ~/.bashrc
```

---

## 6. `export`, `unset`, `readonly`

```bash
export TOOL_VERSION="2.0"
```

Remove:

```bash
unset TOOL_VERSION
```

Read-only:

```bash
readonly MAX_WIDTH=64
```

View exported variables:

```bash
export -p
```

---

## 7. Default Values

Use a default if variable is missing:

```bash
echo "${PROJECT:-default_project}"
```

Use default and assign it:

```bash
echo "${PROJECT:=default_project}"
```

Require a variable:

```bash
echo "${PROJECT:?PROJECT must be set}"
```

Use alternate value if set:

```bash
echo "${PROJECT:+Project is set}"
```

---

## 8. `source` vs `./`

This is very important.

```bash
./setup.sh
```

Runs the script as a separate process.

```bash
source setup.sh
```

Runs it in the current shell, so exported variables remain available.

For environment setup scripts, use:

```bash
source setup.sh
```

---

# VLSI Example

Instead of hardcoding:

```bash
iverilog -o /home/teekam/project/sim.out \
         /home/teekam/project/rtl/counter.v \
         /home/teekam/project/testbench/tb_counter.v
```

use:

```bash
export PROJECT_ROOT="$HOME/project"
export RTL_DIR="$PROJECT_ROOT/rtl"
export TB_DIR="$PROJECT_ROOT/testbench"
export SIM_DIR="$PROJECT_ROOT/sim_output"

iverilog -o "$SIM_DIR/sim.out" \
         "$RTL_DIR/counter.v" \
         "$TB_DIR/tb_counter.v"
```

This makes the script easier to move between machines.

---

# Assignment 1 — Environment Explorer

Create `explore_env.sh`:

```bash
#!/bin/bash

echo "=== Environment Variables ==="
printenv | sort

echo ""
echo "=== Total Variables ==="
echo "Count: $(printenv | wc -l)"

echo ""
echo "=== PATH Directories ==="

while IFS= read -r dir
do
    if [ -d "$dir" ]; then
        echo "[EXISTS]    $dir"
    else
        echo "[NOT FOUND] $dir"
    fi
done < <(echo "$PATH" | tr ':' '\n')
```

Run:

```bash
chmod +x explore_env.sh
./explore_env.sh
```

---


