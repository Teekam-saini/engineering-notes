# DAY 1: Verilog Fundamentals

## What is Verilog?
Verilog is a Hardware Description Language (HDL), not a programming language. Key difference: a programming language executes instructions sequentially on a processor; an HDL describes hardware structure and behavior that gets converted (synthesized) into physical circuits. Statements in Verilog that appear "sequential" in always blocks actually describe parallel hardware, not step-by-step execution.

## Module Structure
A module is the basic building block — equivalent to a "component" or "chip." It has:
* A name
* A port list (inputs/outputs — the interface to the outside world)
* Internal logic (the implementation)

Modern Verilog (2001+) uses ANSI-style port declarations, meaning direction and type are declared directly in the port list rather than separately below it. This is cleaner and is the industry-preferred style.

## Continuous Assignment (`assign`)
Used for combinational logic only. It describes a signal that is continuously driven by an expression — any time an input changes, the output updates immediately (no clock involved). Conceptually this represents wires connected through gates, not something that "runs" — it's always active.

## Bitwise Operators
`&` (AND), `|` (OR), `^` (XOR), `~` (NOT) operate bit-by-bit on operands. These map directly to physical logic gates. Important to distinguish from logical operators (`&&`, `||`) which operate on entire expressions as true/false, not bit-by-bit.

## Testbench Structure
A testbench is not synthesizable hardware — it's a simulation-only environment used to verify a design (the DUT — Device Under Test).

* **`reg` type:** used for signals the testbench drives (inputs to DUT) — because they must hold a value between updates.
* **`wire` type:** used for signals the testbench observes (outputs from DUT) — because they're driven externally by the DUT.
* **`initial` block:** runs once at the start of simulation — used for stimulus generation and setup. Not synthesizable.

## System Tasks
These are simulation-control commands, not hardware:

* **`$dumpfile` / `$dumpvars`:** set up waveform recording to a `.vcd` (Value Change Dump) file.
* **`$display`:** prints once, like a single print statement.
* **`$monitor`:** prints automatically whenever any monitored signal changes — continuous logging.
* **`$finish`:** ends the simulation.

## Simulation Workflow (Conceptual)
1. **Compile:** Verilog source files (design + testbench) are parsed and elaborated into a simulation model.
2. **Run:** The simulator executes the testbench, driving the DUT and recording signal changes over time.
3. **View:** A waveform viewer displays the recorded value changes so you can visually verify correctness.

## Design Approach for Simple Gates
When designing a basic gate-level circuit:
1. Identify inputs and outputs.
2. Since it's pure combinational logic with no memory, use `assign` with a boolean expression matching the truth table.
3. In the testbench, declare `reg` for each input, `wire` for the output, instantiate the module, then apply all input combinations (often exhaustively, since input space is small) using timed delays (`#`) between changes, checking outputs via `$monitor`.
