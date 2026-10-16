# Day 29: Makefiles

## 1. What Is Make?

`make` is a build automation tool that manages dependencies and runs commands in the correct order. It rebuilds targets when their dependencies change.

Without Make:

```bash
iverilog -o sim_output/counter.out rtl/counter.v testbench/tb_counter.v
vvp sim_output/counter.out
```

With Make:

```bash
make sim MODULE=counter
```

## 2. Makefile Structure

The default filename is `Makefile`.

```makefile
target: dependencies
	command
```

- **Target:** What you want to build or execute.
- **Dependencies:** Files or targets required first.
- **Commands:** Instructions to execute.

**Important:** Commands must begin with a TAB character, not spaces.

Example:

```makefile
all: compile simulate

compile: rtl/counter.v testbench/tb_counter.v
	iverilog -o sim.out rtl/counter.v testbench/tb_counter.v

simulate: compile
	vvp sim.out
```

## 3. Makefile Variables

```makefile
CC = iverilog
SIM = vvp

FLAGS = -g2012
FLAGS += -Wall

MODULE ?= counter

SRC_FILES := $(wildcard rtl/*.v)
```

- `=` assigns a recursively expanded variable.
- `:=` evaluates the value immediately.
- `?=` assigns only if the variable is not already defined.
- `+=` appends to a variable.
- `$(VAR)` accesses a variable.

Override a variable from the terminal:

```bash
make sim MODULE=alu
```

## 4. Automatic Variables

Make provides special variables for dependency rules.

| Variable | Meaning |
|---|---|
| `$@` | Target filename |
| `$<` | First dependency |
| `$^` | All dependencies |
| `$*` | Pattern rule's matched stem |

Example:

```makefile
sim_output/%.out: rtl/%.v testbench/tb_%.v
	iverilog -o $@ $^
```

For `counter`, Make substitutes the pattern and builds `sim_output/counter.out` from the matching RTL and testbench files.

## 5. Pattern Rules

Pattern rules let you compile multiple modules without writing a separate rule for each one.

```makefile
sim_output/%.out: rtl/%.v testbench/tb_%.v
	mkdir -p sim_output
	iverilog -g2012 -o $@ $^
```

The `%` matches a module name, such as `counter` or `alu`.

## 6. Dependencies and Rebuilding

Make compares the modification times of targets and their dependencies.

```makefile
sim_output/counter.out: rtl/counter.v testbench/tb_counter.v
	iverilog -g2012 -o $@ $^
```

- If the output does not exist, Make builds it.
- If a dependency is newer than the output, Make rebuilds it.
- If the output is newer than all dependencies, Make skips that build recipe.

Example:

```bash
make sim MODULE=counter
make sim MODULE=counter
touch rtl/counter.v
make sim MODULE=counter
```

The second invocation may skip recompilation. The third recompiles because `counter.v` has a newer timestamp.

**Important:** Make only tracks dependencies you declare. It does not automatically understand every relationship in your RTL design.

## 7. Phony Targets

Phony targets represent actions rather than actual output files.

```makefile
.PHONY: all clean help

all: help

help:
	@echo "Available targets: compile sim clean"

clean:
	rm -f sim_output/*.out sim_output/*.vcd
```

- `.PHONY` prevents a same-named file from making the target appear up to date.
- `@` hides the command itself while displaying its output.
- `-command` tells Make to ignore that command's failure, so use it carefully.

Common targets include `all`, `compile`, `sim`, `clean`, and `help`.

## 8. Useful Make Functions

```makefile
ALL_RTL := $(wildcard rtl/*.v)
```

Finds files matching the pattern.

```makefile
MODULE := $(basename rtl/counter.v)
```

Returns `rtl/counter`.

```makefile
DATE := $(shell date +%Y%m%d)
```

Runs a shell command and captures its output when the variable is evaluated.

## 9. Conditional Logic

Check whether a tool exists:

```makefile
ifeq ($(shell command -v iverilog 2>/dev/null),)
$(error iverilog not found)
endif
```

Change flags depending on a variable:

```makefile
ifeq ($(DEBUG),1)
FLAGS += -g2012 -DDEBUG
else
FLAGS += -g2012
endif
```

Use `include` to split a large Makefile into separate configuration and rules files:

```makefile
include config.mk
include rules.mk
```

## 10. Useful Commands

```bash
make help
make compile MODULE=counter
make sim MODULE=counter
make sim MODULE=alu
make clean
make -n sim MODULE=counter
```

`make -n` displays the commands Make would execute without running them.

## 11. Applying Make to VLSI

A simple RTL build flow looks like this:

```text
RTL + Testbench
      ↓
   Compile
  (iverilog)
      ↓
   Simulation
     (vvp)
      ↓
 Waveform / Logs
   (GTKWave)
```

Make can automate each stage and connect them through dependencies.

Other useful targets include:

- `lint`: Check RTL for syntax problems.
- `stats`: Count RTL lines and modules.
- `report`: Generate a project summary.
- `flow`: Run checks, compilation, and simulation in sequence.
- `synth`: Run synthesis using Yosys.

For example, `iverilog -tnull` can perform a syntax-oriented compilation check without generating an output executable, provided the required source files and dependencies are supplied.

## Quick Reference

```makefile
VAR = value
VAR := value
VAR ?= value
VAR += value

$(VAR)             # Variable expansion
$@                 # Target
$<                 # First dependency
$^                 # All dependencies

.PHONY: clean      # Non-file target
@command           # Hide command echo
$(wildcard *.v)    # Match files
$(shell command)   # Capture shell output
```

## Core Idea

A Makefile describes **what depends on what and how to build it**. Make uses those relationships and file timestamps to decide which commands need to run.

For VLSI projects, this means repeatable builds, less manual typing, and fewer opportunities for human error. Your future self will appreciate not having to remember a twelve-command synthesis sequence.
