# Day 30: Verilog Automation with Bash

## 1. What VLSI Engineers Automate

Bash scripts can automate repetitive RTL development tasks:

- Generate Verilog modules and matching testbenches.
- Check coding style and syntax.
- Extract module ports for documentation.
- Generate project statistics.
- Organize files and manage build workflows.
- Integrate automation scripts with Makefiles.

## 2. Module Generator

A module generator creates RTL and testbench templates automatically.

Example usage:

```bash
./scripts/new_module.sh fifo_controller 8
```

Here, `fifo_controller` is the module name and `8` is its data width.

### Validate Inputs

```bash
MODULE=${1:-""}
WIDTH=${2:-32}

if [ -z "$MODULE" ]; then
    echo "Usage: $0 <module_name> [width]"
    exit 1
fi

if ! echo "$MODULE" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*$'; then
    echo "ERROR: Invalid module name"
    exit 1
fi
```

- `$1` and `$2` represent command-line arguments.
- `${1:-""}` supplies a default when the first argument is unset or empty.
- Regular expressions validate the module identifier.

### Prevent Overwriting Existing Files

```bash
RTL_FILE="rtl/${MODULE}.v"

if [ -f "$RTL_FILE" ]; then
    echo "ERROR: File already exists"
    exit 1
fi
```

### Generate RTL from a Template

```bash
cat > "$RTL_FILE" << EOF
module ${MODULE} #(
    parameter DATA_WIDTH = ${WIDTH}
)(
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

always @(posedge clk or posedge rst) begin
    if (rst)
        data_out <= {DATA_WIDTH{1'b0}};
    else
        data_out <= data_in;
end

endmodule
EOF
```

The unquoted `EOF` allows Bash to expand variables inside the template.

The generator can also create a matching testbench with clock generation, reset logic, test cases, and `$dumpfile`/`$dumpvars` for waveform generation.

**Important:** A generated template is only a starting point. Its testbench must match the module's actual behavior, and passing syntax checks does not prove functional correctness.

## 3. RTL Linter

A linter checks source code for common problems before simulation or synthesis.

Typical checks include:

- Missing `module` or `endmodule`.
- Missing `` `timescale `` in testbenches.
- Suspicious blocking assignments in sequential logic.
- Missing header comments.
- Excessively long lines.
- Syntax errors.

### Useful Commands

```bash
grep -q "^module" file.v
grep -q "endmodule" file.v
grep -c "always" file.v
awk 'length > 100 {count++} END {print count+0}' file.v
iverilog -tnull file.v
```

`iverilog -tnull` performs a compilation check without producing a simulation executable.

### Functions and Counters

```bash
ERRORS=0
WARNINGS=0

error() {
    echo "[ERROR] $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "[WARN] $1"
    WARNINGS=$((WARNINGS + 1))
}
```

A linter can return a nonzero exit status when errors are found, allowing Make to stop a build.

**Limitation:** Simple grep-based checks are only heuristics. They can miss errors or flag valid code because they do not fully parse Verilog syntax.

## 4. Port List Extractor

A port extractor reads a Verilog file and summarizes its interface.

Example:

```verilog
module counter #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    output reg [WIDTH-1:0] count
);
endmodule
```

Useful commands:

```bash
grep -m1 "^module" file.v
grep -E "^[[:space:]]*input" file.v
grep -E "^[[:space:]]*output" file.v
grep -E "^[[:space:]]*parameter" file.v
wc -l < file.v
```

These commands help extract:

- Module name.
- Input and output declarations.
- Parameters.
- Total source lines.

A simple extractor works best with consistently formatted Verilog. ANSI-style port declarations, multiline declarations, comments, and SystemVerilog syntax can require more sophisticated parsing.

## 5. Project Statistics Generator

A statistics script summarizes project size and structure.

```bash
rtl_count=$(find "$PROJECT_ROOT/rtl" -name "*.v" | wc -l)
tb_count=$(find "$PROJECT_ROOT/testbench" -name "*.v" | wc -l)
script_count=$(find "$PROJECT_ROOT/scripts" -name "*.sh" | wc -l)

total_lines=$(cat "$PROJECT_ROOT"/rtl/*.v 2>/dev/null | wc -l)
total_modules=$(grep -rh "^module" "$PROJECT_ROOT"/rtl/*.v 2>/dev/null | wc -l)
total_always=$(grep -rh "always" "$PROJECT_ROOT"/rtl/*.v 2>/dev/null | wc -l)
```

Per-file breakdown:

```bash
for f in "$PROJECT_ROOT"/rtl/*.v; do
    name=$(basename "$f" .v)
    lines=$(wc -l < "$f")
    printf "%-20s %4d lines\n" "$name" "$lines"
done
```

Git information can also be included:

```bash
git -C "$PROJECT_ROOT" branch --show-current
git -C "$PROJECT_ROOT" log --oneline -1
```

These metrics are useful for tracking project growth, but line counts and `always` counts are not measures of design quality or hardware complexity.

## 6. Integrating Scripts with Make

Make can provide a single interface for all automation tools.

```makefile
.PHONY: new lint ports stats

new:
	@test -n "$(MODULE)" || (echo "Usage: make new MODULE=name"; exit 1)
	@./scripts/new_module.sh "$(MODULE)" "$(or $(WIDTH),32)"

lint:
	@if [ -n "$(MODULE)" ]; then \
		./scripts/lint_rtl.sh "rtl/$(MODULE).v"; \
	else \
		./scripts/lint_rtl.sh rtl/; \
	fi

ports:
	@test -n "$(MODULE)" || (echo "Usage: make ports MODULE=name"; exit 1)
	@./scripts/extract_ports.sh "rtl/$(MODULE).v"

stats:
	@./scripts/project_stats.sh
```

Example usage:

```bash
make new MODULE=uart_controller WIDTH=8
make lint MODULE=uart_controller
make ports MODULE=uart_controller
make stats
```

This creates a consistent command interface instead of requiring you to remember the path to every script.

## 7. Complete Automation Workflow

A typical workflow connects module generation, linting, documentation, statistics, and simulation.

```text
Generate RTL + Testbench
          ↓
      Lint Check
          ↓
    Extract Ports
          ↓
  Generate Statistics
          ↓
 Compile and Simulate
          ↓
 Inspect Logs / Waveforms
```

Example:

```bash
make new MODULE=decoder WIDTH=4
make lint MODULE=decoder
make ports MODULE=decoder
make stats
make sim MODULE=decoder
```

Simulation may fail if the generated testbench assumes behavior that the new module does not implement. Update the RTL or testbench according to the intended specification.

## 8. Key Bash Patterns

```bash
# Validate an identifier
grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*$'

# Generate a file from a template
cat > file.v << EOF
module $MODULE;
endmodule
EOF

# Check whether a file exists
[ -f "$FILE" ]

# Extract a module declaration
grep -m1 "^module" file.v

# Count matching lines
grep -c "^module" file.v

# Count file lines
wc -l < file.v

# Get filename without extension
basename file.v .v
```

## Core Idea

Bash automation turns repetitive RTL tasks into reusable tools. Combining shell scripts with Make creates a repeatable workflow for generating designs, checking source code, documenting interfaces, tracking project statistics, and running simulations.

The goal is not to automate everything blindly. It is to automate repetitive work while keeping design correctness and verification under your control.
