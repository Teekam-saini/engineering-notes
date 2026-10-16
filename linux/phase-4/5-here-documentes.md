# Day 26: Here Documents, Here Strings, Command Substitution, Subshells

## 1. Here Documents `<<EOF`

A here document sends multiple lines of text to a command through stdin.

```bash
command << EOF
line 1
line 2
line 3
EOF
```

`EOF` is only a delimiter. It can be any matching word.

### Creating Files

```bash
cat > counter.v << 'EOF'
module counter(input clk, output reg [7:0] count);
    always @(posedge clk)
        count <= count + 1;
endmodule
EOF
```

### Variable Expansion

Without quotes, variables and commands expand:

```bash
name="teekam"

cat << EOF
Hello $name
Today is $(date)
Home is $HOME
EOF
```

With quotes, everything remains literal:

```bash
cat << 'EOF'
Hello $name
Today is $(date)
Home is $HOME
EOF
```

### `<<-`

`<<-` removes leading **tabs**, which allows indentation:

```bash
cat <<- EOF
	Hello
	World
EOF
```

It removes tabs, not spaces.

### VLSI Use

Here documents are useful for generating Verilog templates automatically:

```bash
MODULE="register"
WIDTH=8

cat > "${MODULE}.v" << EOF
module $MODULE #(
    parameter WIDTH = $WIDTH
)(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);
endmodule
EOF
```

---

## 2. Here Strings `<<<`

A here string sends a **single string** to stdin.

```bash
command <<< "string"
```

Example:

```bash
grep "module" <<< "module counter(input clk);"
```

Using a variable:

```bash
line="PATH: cpu_to_mem slack: -2.5ns VIOLATED"

grep "VIOLATED" <<< "$line"
```

Useful with `read`:

```bash
read first second <<< "hello world"

echo "$first"     # hello
echo "$second"    # world
```

### Using IFS

```bash
IFS=',' read -ra ports <<< "clk,rst,data_in,data_out"

for port in "${ports[@]}"; do
    echo "Port: $port"
done
```

### Here Document vs Here String

```bash
# One line
grep "ERROR" <<< "$log_line"

# Multiple lines
grep "ERROR" << 'EOF'
[INFO] Starting
[ERROR] File not found
[INFO] Retrying
EOF
```

Think:

```text
<<<  → one string
<<   → multiple lines
```

---

## 3. Command Substitution `$()`

Command substitution captures command output and stores it as a value.

```bash
result=$(command)
```

Examples:

```bash
current_date=$(date +%Y-%m-%d)
file_count=$(ls rtl/*.v | wc -l)
git_branch=$(git branch --show-current)
username=$(whoami)

echo "Date: $current_date"
echo "Files: $file_count"
echo "Branch: $git_branch"
```

### Nested Command Substitution

```bash
latest_log=$(ls logs/timing_*.log | head -1)
worst_path=$(grep "VIOLATED" "$latest_log")
```

Command substitution can also be combined with arithmetic:

```bash
errors=$(grep -r "ERROR" logs/ | wc -l)
warnings=$(grep -r "WARNING" logs/ | wc -l)

total=$((errors + warnings))
```

### `$()` vs Backticks

Old style:

```bash
result=`command`
```

Preferred:

```bash
result=$(command)
```

`$()` is easier to read and much easier to nest.

Example:

```bash
result=$(echo $(date))
```

For complex commands:

```bash
result=$(
    grep "ERROR" logs/*.log |
    sort |
    uniq -c |
    sort -rn |
    head -5
)
```

---

## 4. Subshells

A subshell is a child shell that inherits the parent's environment but has its own execution context.

### Creating a Subshell

```bash
(commands)
```

Other common cases:

```bash
result=$(commands)
```

and pipeline components:

```bash
command1 | command2
```

### Subshell Isolation

Changes inside a subshell do not affect the parent shell:

```bash
x=10

(
    x=999
    echo "$x"
)

echo "$x"
```

Output:

```text
999
10
```

`cd` behaves the same way:

```bash
pwd

(cd /tmp && ls)

pwd
```

The parent remains in its original directory.

### Useful Pattern

Run commands in another directory without changing the current shell:

```bash
(cd ~/project && git log --oneline)
```

Group commands and redirect their combined output:

```bash
(
    echo "=== Header ==="
    cat rtl/counter.v
    echo "=== Footer ==="
) > combined_output.txt
```

---

## 5. Subshells for Parallel Execution

Subshells can run in the background:

```bash
(./simulate_test1.sh) &
(./simulate_test2.sh) &
(./simulate_test3.sh) &

wait
echo "All simulations complete"
```

`&` starts a background process.

`wait` waits for background jobs to finish.

This is useful for running independent RTL simulations simultaneously.

---

## 6. `source` vs Subshell vs `./script`

`source` runs a script in the **current shell**:

```bash
source setup_env.sh
echo "$PROJECT_ROOT"
```

Variables remain available.

A subshell isolates changes:

```bash
(source setup_env.sh)
echo "$PROJECT_ROOT"
```

The variable does not persist.

Executing a script normally also runs it in a separate process:

```bash
./setup_env.sh
echo "$PROJECT_ROOT"
```

The variable does not persist in the parent shell.

---

## 7. Combining Everything

These features become particularly useful in automation.

Example report generation:

```bash
PROJECT=$(basename "$(pwd)")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT="reports/report_${TIMESTAMP}.md"

mkdir -p reports

cat > "$REPORT" << EOF
# VLSI Project Report

**Project:** $PROJECT
**Generated:** $(date)
**User:** $USER
**Git Branch:** $(git branch --show-current 2>/dev/null || echo "not a git repo")

## RTL Statistics

- Total .v files: $(find rtl/ -name "*.v" 2>/dev/null | wc -l)
- Total lines: $(cat rtl/*.v 2>/dev/null | wc -l)
- Module count: $(grep -r "^module" rtl/ 2>/dev/null | wc -l)

## Recent Changes

$(git log --oneline -5 2>/dev/null || echo "No git history")

## File List

$(ls -lh rtl/*.v 2>/dev/null || echo "No RTL files found")
EOF
```

This combines:

```text
Here document       → generates the report
Command substitution → inserts dynamic information
Subshells            → isolate grouped operations when needed
```

## Quick Reference

```bash
# Here document
command << 'EOF'
multiple
lines
EOF

# Here document with expansion
command << EOF
Hello $USER
Today: $(date)
EOF

# Here string
command <<< "single line"

# Command substitution
result=$(command)

# Nested command substitution
result=$(cmd1 $(cmd2))

# Subshell
(commands)

# Isolated directory change
(cd /tmp && ls)

# Parallel subshells
(cmd1) &
(cmd2) &
wait
```

## Core Idea

```text
<<EOF   → feed multiple lines to a command
<<<     → feed one string to a command
$()     → capture command output as a value
(...)   → run commands in an isolated shell
&       → run in background
wait    → wait for background processes
```

These four features are the point where Bash starts becoming a real scripting language rather than a collection of commands humans type into a terminal and hope will behave.
