# Day 31: Icarus Verilog Workflow

## 1. Icarus Verilog Toolchain

The simulation workflow has three stages:

1. **Compile:** `iverilog` converts Verilog/SystemVerilog sources into a simulation executable.
2. **Simulate:** `vvp` runs the compiled simulation and produces terminal output or waveform files.
3. **View:** `gtkwave` displays VCD waveforms for signal-level debugging.

```bash
iverilog -g2012 -Wall -o sim.out rtl/design.v tb/tb_design.v
vvp sim.out
gtkwave sim_output/design.vcd &
```

## 2. Important Icarus Verilog Flags

| Flag | Purpose |
|---|---|
| `-o file` | Specify output filename |
| `-g2012` | Enable SystemVerilog 2012 support |
| `-g2005` | Select Verilog 2005 |
| `-Wall` | Enable supported warnings |
| `-I directory` | Add an include-file search path |
| `-D MACRO=value` | Define a preprocessor macro |
| `-tnull` | Check syntax without generating an output executable |
| `-v` | Display verbose compilation information |
| `-s module` | Specify the top-level module |

Compile multiple files:

```bash
iverilog -g2012 -Wall -o sim.out rtl/*.v tb/tb_top.v
```

For larger projects, use a file list:

```bash
iverilog -g2012 -o sim.out -f sim_files.f
```

## 3. Include Files and Preprocessor Defines

Header files (`.vh`) store shared macros and definitions.

```verilog
`define DATA_WIDTH 32
`define ADDR_WIDTH 16
```

Use a macro with a backtick:

```verilog
input wire [`DATA_WIDTH-1:0] data_in;
```

Add the header directory during compilation:

```bash
iverilog -g2012 -I include/ -o sim.out rtl/processor.v tb/tb_processor.v
```

Enable conditional compilation with `-D`:

```verilog
`ifdef DEBUG
    $display("Debug information");
`endif
```

```bash
iverilog -g2012 -D DEBUG -o sim.out rtl/design.v tb/tb_design.v
```

Without `-D DEBUG`, the debug-only code is excluded during preprocessing.

## 4. Runtime Plusargs

Plusargs pass configuration values to a simulation without recompiling the design.

```bash
vvp sim.out +cycles=100 +seed=42 +verbose=1
```

Read values inside Verilog using `$value$plusargs`:

```verilog
integer cycles;

initial begin
    if (!$value$plusargs("cycles=%d", cycles))
        cycles = 100;
end
```

- `%d` reads a decimal integer.
- The `if` condition handles missing arguments by assigning a default.
- Plusargs are useful for changing simulation length, random seeds, and debug settings.

**Important:** A seed variable has no effect unless the testbench actually uses it to control randomized behavior.

## 5. VCD Files and GTKWave

Generate a waveform from the testbench:

```verilog
initial begin
    $dumpfile("sim_output/design.vcd");
    $dumpvars(0, tb_design);
end
```

- `$dumpfile` specifies the output VCD filename.
- `$dumpvars(0, tb_design)` dumps signals throughout the testbench hierarchy.
- `$dumpvars(1, tb_design)` dumps only the selected top-level scope.

Open the waveform:

```bash
gtkwave sim_output/design.vcd &
```

Save a GTKWave signal configuration as a `.gtkw` file to reuse the same signal arrangement later.

## 6. Compilation Methods for Larger Projects

**Explicit source list:**

```bash
iverilog -g2012 -o sim.out \
    rtl/alu.v rtl/regfile.v rtl/controller.v \
    rtl/top.v tb/tb_top.v
```

**Wildcard:**

```bash
iverilog -g2012 -o sim.out rtl/*.v tb/tb_top.v
```

**File list (`sim_files.f`):**

```text
rtl/alu.v
rtl/regfile.v
rtl/controller.v
rtl/top.v
tb/tb_top.v
```

Compile it with:

```bash
iverilog -g2012 -o sim.out -f sim_files.f
```

**Makefile rule:**

```makefile
SRC = $(wildcard rtl/*.v)
TB  = tb/tb_top.v

sim.out: $(SRC) $(TB)
	iverilog -g2012 -Wall -o $@ $^
```

Here, `$@` means the target filename and `$^` means all prerequisites.

## 7. Debugging Common Errors

| Problem | Likely cause | Fix |
|---|---|---|
| Unknown module type | Missing source file | Include the module in compilation |
| Port-width warning | Connected signal has the wrong width | Check port declarations and expressions |
| Implicit wire warning | Undeclared signal | Explicitly declare the signal |
| Multiple drivers | Signal assigned by multiple processes | Review ownership and consolidate logic where appropriate |
| Syntax error | Missing `endmodule`, semicolon, or malformed statement | Inspect the reported line and nearby code |

Useful debugging sequence:

```bash
# 1. Check syntax
iverilog -tnull rtl/design.v tb/tb_design.v

# 2. Compile with warnings
iverilog -g2012 -Wall -v -o sim.out rtl/design.v tb/tb_design.v

# 3. Run simulation
vvp sim.out

# 4. Inspect signal behavior
gtkwave sim_output/design.vcd &
```

Use `$display` in the testbench to print signal values and timestamps:

```verilog
$display("[%0t] count = %0d", $time, count);
```

A blocking assignment (`=`) inside a clocked process is not automatically a syntax error, but nonblocking assignment (`<=`) is generally preferred for sequential RTL because it models register updates more reliably.

## 8. Simulation Wrapper Scripts

A Bash wrapper can automate syntax checking, compilation, simulation, and result reporting.

Typical workflow:

1. Validate the requested module name.
2. Check that the RTL and testbench files exist.
3. Run `iverilog -tnull` for syntax checking.
4. Compile using `-g2012` and `-Wall`.
5. Run the executable with `vvp`.
6. Check the simulation's exit status and testbench results.
7. Open the generated VCD when debugging is needed.

Use `set -euo pipefail` for stricter Bash error handling, but remember that error handling does not replace explicit checks.

**Important wrapper-script caveat:** Do not run the same simulation a second time merely to search its output for `ALL TESTS PASSED`. Capture the first run's output and inspect it. Also, the testbench must explicitly report failures or return a failure status; a successful simulator exit alone does not prove that every test passed.

## 9. Quick Reference

| Task | Command or construct |
|---|---|
| Syntax check | `iverilog -tnull rtl/design.v` |
| Compile | `iverilog -g2012 -Wall -o sim.out rtl.v tb.v` |
| Simulate | `vvp sim.out` |
| Runtime parameters | `vvp sim.out +cycles=100` |
| Include directory | `-I include/` |
| Debug macro | `-D DEBUG` |
| File list | `-f sim_files.f` |
| Generate waveform | `$dumpfile()` and `$dumpvars()` |
| View waveform | `gtkwave sim_output/design.vcd &` |
| Read a plusarg | `$value$plusargs("cycles=%d", cycles)` |

**Core takeaway:** `iverilog` compiles, `vvp` simulates, and GTKWave visualizes. Reliable RTL verification depends on correct source lists, explicit warnings, meaningful testbench checks, and waveform inspection.
