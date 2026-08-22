# DAY 2: Sequential Logic Basics

## Wire vs Reg — The Real Distinction
This is one of the most misunderstood concepts. It is not about hardware type (wire vs storage) — it's purely a simulation/assignment-context rule:

* **`wire`**: must be driven by a continuous assignment (`assign`) or by a port connection. Cannot be assigned inside a procedural block (`always` or `initial`).
* **`reg`**: must be assigned inside a procedural block (`always` or `initial`). Despite the name, a `reg` does not necessarily synthesize to a physical register/flip-flop — it only becomes a flip-flop if the always block is edge-triggered (`@(posedge clk)`). If the always block is combinational (`@(*)`) and every path is fully assigned, it synthesizes to plain combinational logic, not storage.

## Always Blocks — Two Fundamentally Different Uses
* **Combinational:** `always @(*)` — sensitivity list automatically includes all signals read inside. Represents logic that continuously recalculates output from inputs. No memory.
* **Sequential:** `always @(posedge clk)` — logic executes only at the rising edge of the clock. This is what creates actual storage elements (flip-flops) in hardware.

The choice of sensitivity list is what tells the synthesis tool whether you intend combinational logic or a clocked storage element.

## Blocking (`=`) vs Non-Blocking (`<=`) Assignment
This is a simulation execution-order rule that has become a hardware design convention:

* **Blocking (`=`):** executes immediately, in order, like a normal statement — the next line sees the updated value. Used for combinational logic.
* **Non-blocking (`<=`):** all right-hand sides are evaluated first using old values, and all assignments happen simultaneously at the end of the time step. This matches how real flip-flops behave — they all sample their inputs on the same clock edge and update together. Used for sequential logic.

> **Rule of thumb (industry standard):** blocking in combinational always blocks, non-blocking in sequential (clocked) always blocks. Mixing them incorrectly is one of the most common sources of simulation-vs-hardware mismatches.

## Synchronous vs Asynchronous Behavior
* **Synchronous:** a control signal (like reset) only takes effect at a clock edge. Implemented by including the condition inside the always block body without adding it to the sensitivity list.
* **Asynchronous:** a control signal takes effect immediately, independent of the clock. Implemented by adding the signal to the sensitivity list itself (e.g., `@(posedge clk or posedge rst)`), so the block re-evaluates the instant that signal changes — not waiting for a clock edge.

**Priority principle:** whatever condition is checked first inside the `if-else` chain has the highest priority — this represents which signal "wins" if multiple conditions are true simultaneously. This is independent of the sensitivity list; the sensitivity list only controls when the block re-evaluates, the `if-else` order controls what happens once it does.

## Enable Signal Concept
An enable is a gating condition for whether a sequential element updates on a clock edge. When disabled, the design should explicitly hold its current value (self-assignment, `q <= q`), otherwise omitting an `else` branch creates unintended latches in combinational contexts, or leaves ambiguity in sequential contexts. In sequential logic specifically, omitting the `else` is actually safe and standard — Verilog automatically holds the previous value if no assignment happens in a given clock edge (see "Implicit Hold" below).

## Implicit Hold — Important Theoretical Point
In a clocked always block, if a `reg` is not assigned during a particular triggering edge, it automatically retains its previous value — this is a property of how registers work, not something you need to code explicitly. Writing `else q <= q;` is functionally redundant but sometimes used for clarity/documentation. This is different from combinational logic, where a missing assignment path creates a latch (unwanted memory), which is considered bad design practice.

## Counter Concept
A counter is built by combining sequential storage (flip-flops) with simple arithmetic (increment/decrement) feeding back into itself. 

* **Core theoretical idea:** `next_value = current_value + 1`, sampled on each clock edge. 
* **Overflow (wraparound):** happens naturally due to fixed-width binary arithmetic — when a value exceeds the maximum representable number for its bit-width, it wraps to zero automatically ($modulo\ 2^N$ behavior), without needing explicit wraparound logic for power-of-2-width counters.

## Design Approach for D Flip-Flop Variants
1. **Determine control behavior:** does the control (reset/enable) need to act synchronously or asynchronously? This decides the sensitivity list.
2. **Establish priority order:** reset (if async) always checked first, then enable, then default hold/increment behavior.
3. **Use assignments correctly:** use non-blocking assignment throughout since this is sequential logic.
4. **Testbench setup:** instantiate the DUT, generate a free-running clock using `forever #half_period clk = ~clk;`, then sequence through test scenarios — always test reset first, then normal operation, then edge cases (e.g., toggling enable mid-stream, asserting reset mid-operation).
