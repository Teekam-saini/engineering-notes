# Day 32: GTKWave Automation & Waveform Handling

## 1. Why Waveforms Matter

Waveforms help debug RTL by showing signal values and timing relationships throughout simulation.

They help identify:
- Incorrect signal values and unexpected transitions.
- Reset assertion and deassertion timing.
- Clock-edge behavior and timing relationships.
- The point in time when a bug first appears.

## 2. GTKWave Basics

GTKWave displays VCD (Value Change Dump) files generated during simulation.

Main interface components:
- **Signal Tree:** Browse signals and module hierarchy.
- **Waveform View:** Inspect signal values over time.
- **Time Cursor:** Read signal values at a particular instant.
- **Markers:** Compare events at different times.

Useful shortcuts:

| Action | Shortcut |
|---|---|
| Zoom in/out | `+` / `-` |
| Fit the complete waveform | `Ctrl+A` in the waveform context |
| Go to simulation start/end | `Home` / `End` |
| Add signals | Drag from the signal tree |
| Remove selected signal | `Delete` |
| Change display format | Right-click signal |
| Move through time | Scroll or use the time controls |

Shortcuts can vary between GTKWave versions and keyboard configurations.

## 3. Generating VCD Files

Add waveform dumping to the testbench:

```verilog
initial begin
    $dumpfile("sim_output/design.vcd");
    $dumpvars(0, tb_design);
end
```

- `$dumpfile` sets the output file path.
- `$dumpvars(0, tb_design)` records signals throughout the selected hierarchy.
- `$dumpvars(1, tb_design)` records only signals in the selected scope.

Run the simulation and open the waveform:

```bash
vvp sim_output/design.out
gtkwave sim_output/design.vcd &
```

The VCD file must exist before GTKWave can display it.

## 4. GTKWave Save Files

A `.gtkw` file saves the waveform viewing configuration, including selected signals and their display arrangement.

**Create manually:**
1. Open the VCD file.
2. Add important signals to the waveform view.
3. Change signal formats, such as binary, decimal, or hexadecimal.
4. Save the configuration through GTKWave's File menu.

Reopen it later:

```bash
gtkwave sim_output/traffic_light.vcd \
    gtkwave_saves/traffic_light.gtkw &
```

This avoids rebuilding the same signal layout every time you debug a design.

## 5. Automating GTKWave Configuration

A Bash script can generate a save file for a known module and signal list.

Example usage:

```bash
./scripts/gen_gtkw.sh counter clk rst enable count overflow
```

The script can:
1. Accept the module name and signal names.
2. Create the save-file directory.
3. Write the VCD path and waveform settings.
4. Add the requested hierarchical signal names.
5. Print the command used to open GTKWave.

**Important:** GTKWave save-file syntax and hierarchical paths must match the actual VCD hierarchy. Generated files may need adjustment for the installed GTKWave version, so verify them rather than assuming every generated configuration is valid.

## 6. Analyzing VCD Files with Bash

VCD files can be inspected without opening GTKWave.

```bash
# File size
du -h sim_output/counter.vcd

# Timescale declaration
grep "timescale" sim_output/counter.vcd | head -1

# Final simulation timestamp
grep "^#" sim_output/counter.vcd | tail -1

# Variable declarations
grep -E '^\$var ' sim_output/counter.vcd

# Count value-change lines beginning with 0, 1, x, or z
grep -cE '^[01xXzZ]' sim_output/counter.vcd
```

A VCD contains:
- Header information, including timescale.
- Signal declarations and identifier codes.
- Timestamps beginning with `#`.
- Value changes associated with signal identifiers.

**Caution:** Simple `grep` commands provide rough statistics, not complete VCD parsing. They may miss vector transitions, miscount events, or confuse signal identifiers with values. Accurate per-signal analysis requires parsing the declarations and mapping each identifier to its signal.

Likewise, counting every line beginning with `1` does not reliably count clock rising edges. A proper checker must track the clock's previous value and detect an actual `0` to `1` transition.

## 7. Automated Waveform Checking

A basic script can display the first value-change events:

```bash
awk '
/^#[0-9]/ {time = substr($0, 2)}
/^[01xXzZ]/ {print "t=" time, "value=" $0}
' sim_output/counter.vcd | head -20
```

To build a reliable checker, it should:
- Parse the VCD header and timescale.
- Map signal identifiers to hierarchical names.
- Track each signal's transitions independently.
- Detect signals that never change.
- Identify signals with unknown (`X`) or high-impedance (`Z`) values.
- Convert timestamps using the declared timescale.

An `X` or `Z` value is not automatically a design bug. It can indicate an uninitialized register, an undriven signal, or intentional high-impedance behavior.

## 8. Makefile-Based Simulation Workflow

A Makefile can connect compilation, simulation, waveform viewing, analysis, and cleanup.

```makefile
CC      = iverilog
SIM     = vvp
WAVE    = gtkwave
MODULE ?= counter

RTL_DIR  = rtl
TB_DIR   = testbench
SIM_DIR  = sim_output
GTKW_DIR = gtkwave_saves

.PHONY: compile sim wave analyze clean

compile: $(SIM_DIR)/$(MODULE).out

$(SIM_DIR)/%.out: $(RTL_DIR)/%.v $(TB_DIR)/tb_%.v
	mkdir -p $(SIM_DIR)
	$(CC) -g2012 -Wall -o $@ $^

sim: compile
	$(SIM) $(SIM_DIR)/$(MODULE).out

wave: sim
	$(WAVE) $(SIM_DIR)/$(MODULE).vcd \
	    $(GTKW_DIR)/$(MODULE).gtkw &

analyze:
	./scripts/analyze_vcd.sh $(SIM_DIR)/$(MODULE).vcd

clean:
	rm -f $(SIM_DIR)/*.out $(SIM_DIR)/*.vcd
```

Common commands:

```bash
make sim MODULE=traffic_light
make wave MODULE=traffic_light
make analyze MODULE=traffic_light
make clean
```

The pattern rule assumes each design has a corresponding testbench named `tb_<module>.v`. The `wave` target also assumes a saved configuration exists. Add file-existence checks if the workflow must handle missing VCD or `.gtkw` files gracefully.

## 9. Complete Automated Flow

A full simulation script can combine the steps into one command:

```bash
./scripts/full_flow.sh traffic_light
```

Recommended sequence:

1. Validate the module argument and source files.
2. Compile RTL and testbench with `iverilog`.
3. Stop immediately if compilation fails.
4. Run the executable with `vvp`.
5. Verify the simulation result and generated VCD.
6. Analyze the waveform.
7. Generate the GTKWave save file.
8. Open GTKWave with the saved configuration.

Keep simulator output from the first run and inspect it for test results. Do not rerun the simulation merely to search for a pass message, since that wastes time and may produce confusing results.

## 10. Quick Reference

| Task | Command |
|---|---|
| Open waveform | `gtkwave file.vcd &` |
| Open with saved layout | `gtkwave file.vcd config.gtkw &` |
| Generate VCD | `$dumpfile()` and `$dumpvars()` |
| Read timescale | `grep "timescale" file.vcd` |
| Find final timestamp | `grep "^#" file.vcd \| tail -1` |
| List signal declarations | `grep -E '^\$var ' file.vcd` |
| Run complete simulation flow | `make sim MODULE=name` |
| Open waveform through Make | `make wave MODULE=name` |
| Analyze VCD | `make analyze MODULE=name` |

**Core takeaway:** GTKWave reveals when and how signals change. Automating VCD generation, signal layouts, analysis, and Makefile targets makes RTL debugging faster and more repeatable.
