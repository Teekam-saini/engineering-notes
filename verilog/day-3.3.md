# DAY 3 — SESSION 3: Shift Registers

## Core Theoretical Idea
A shift register chains flip-flops so that on each clock edge, data moves one position through the chain — implemented conceptually by concatenating "all bits except one edge" with "one new bit" and reassigning the whole register. This single idea (concatenation-based reassignment) is the basis for every shift register variant; only the choice of which end loses a bit and which end gains a new bit changes.

## Four Variants — Theoretical Purpose
* **SISO (Serial In, Serial Out):** acts purely as a delay line — data enters and exits one bit at a time, with a fixed delay equal to the register length in clock cycles. Only the boundary bit is externally visible at any time.
* **SIPO (Serial In, Parallel Out):** performs serial-to-parallel conversion — same shifting mechanism as SISO, but the entire internal register is exposed as output, so after loading is complete, all bits are available simultaneously. This is the core mechanism behind receiving serial communication (e.g., UART RX).
* **PISO (Parallel In, Serial Out):** performs parallel-to-serial conversion — instead of shifting in new external bits, the register is first loaded with an entire word in one clock cycle (parallel load), then subsequently shifted out to expose one bit per cycle. Core mechanism behind transmitting serial communication (e.g., UART TX).
* **Universal Shift Register:** combines all behaviors (hold, shift-left, shift-right, parallel load) into one component, selected via a mode-control signal. This models real hardware components (e.g., 74194 IC) and represents the general-purpose building block that specialized versions (SISO/SIPO/PISO) are special cases of.

## Direction Theory (Left vs Right Shift)
The "direction" is purely about which end of the concatenation the new bit enters and which end loses a bit — there is no inherent physical meaning, it's a naming convention tied to how we draw MSB/LSB. Left shift mathematically corresponds to multiplying by 2 (per shift); right shift corresponds to integer division by 2 — this is why shift operations are heavily used in arithmetic-optimized hardware (avoiding full multiplier/divider circuits when only power-of-2 scaling is needed).

## Design Approach for Shift Registers
1. Decide input style (serial vs parallel) and output style (serial vs parallel) — this determines which variant you're building.
2. Core update rule is always: `register <= {kept_bits, new_bit}` (or reversed order for the other direction).
3. For PISO: add a load control with priority above the shift operation, so parallel data can be captured in one cycle before shifting begins.
4. For universal design: encode all needed modes into a control signal, use `localparam` for each mode's meaning, and use a `case` statement to select the appropriate update rule per mode; always include a default (hold) case.
5. **Testbench:** for serial-in designs, apply one bit per clock cycle to visibly build up the pattern; for parallel-load designs, assert load for exactly one cycle then switch to shift mode; always verify the complete round trip (e.g., load a known pattern, shift it out entirely, confirm the output sequence matches the original pattern in the expected bit order).
