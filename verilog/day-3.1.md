# DAY 3 — SESSION 1: JK and SR Flip-Flops

## JK Flip-Flop — Theoretical Role
* The JK flip-flop is historically significant as the "universal" flip-flop — capable of emulating hold, set, reset, and toggle behavior using two control inputs (J, K) instead of one.
* It resolves the "forbidden state" problem of the SR latch by defining the S=R=1-equivalent case as toggle instead of undefined.
* Conceptually: J acts like "set enable," K acts like "reset enable." When both are asserted simultaneously, instead of conflict, the design defines this specific combination as toggle — an intentional design decision, not an accident.

## SR Flip-Flop — Theoretical Role and the Forbidden State
* S (Set) and R (Reset) are two independent control inputs. 
* The forbidden state (S=R=1) exists because both inputs try to drive the output to contradictory values simultaneously. In real hardware (transistor-level cross-coupled gates), this causes an unstable condition:
    * **Metastability:** the output voltage settles at an indeterminate level between logic 0 and 1, violating basic digital assumptions.
    * **Race condition on recovery:** when both inputs are released simultaneously, whichever internal gate happens to resolve first (based on unpredictable propagation delay differences) determines the final state — meaning the outcome is not deterministic and cannot be predicted from the design alone.
* This is why S=R=1 is called "forbidden" — not because the circuit breaks, but because its behavior becomes unpredictable, which is unacceptable for reliable digital design.

## Unknown Value (`x`) — Theoretical Meaning
* In simulation, `x` represents "value cannot be determined." It exists purely as a simulation modeling tool (real hardware never truly has "unknown" — it has some real voltage, just not one you can predict without knowing exact analog behavior). 
* Causes of `x` appearing in simulation:
    * Uninitialized registers (Verilog default-initializes `reg` types to `x`).
    * Explicitly modeling a forbidden/undefined case (as in the SR flip-flop).
    * Incomplete case/if statements leaving some outputs unassigned.
    * Conflicting drivers on the same net.
* **Propagation property:** once a signal becomes `x`, any operation using that value as an input (including self-assignment, "hold") will also produce `x`, because the simulator cannot resolve an unknown into a known value through ordinary logic. Only an explicit forced assignment (like a reset condition) can pull a signal out of the unknown state.

## Master-Slave Concept (Historical Context)
* Early flip-flop designs used level-sensitive latches (transparent while clock is high/low) rather than true edge-triggered devices. If you built a JK flip-flop from a single level-sensitive latch, having J=K=1 held for an entire clock-high period would cause the output to toggle repeatedly during that period (uncontrolled oscillation) — a race condition.
* The master-slave architecture solved this historically by chaining two latches: one captures input while the clock is high, the second only releases that captured value while the clock is low — guaranteeing exactly one output change per clock cycle.
* **Why we don't code master-slave explicitly today:** describing sequential logic using `always @(posedge clk)` inherently instructs the synthesis tool to build a true edge-triggered flip-flop at the hardware/silicon level. The synthesizer handles the internal race-condition-free implementation automatically — modern designers describe behavior, not internal latch structure.

## Flip-Flop Conversion — Theoretical Basis
* Any flip-flop type can be built from any other by manipulating the input equations feeding it — this is a classic digital logic design exercise (excitation tables). 
* The general method:
    1. Write the truth table describing desired next-state behavior for the target flip-flop.
    2. Compare against the actual flip-flop's truth table.
    3. Derive boolean expressions for the actual flip-flop's inputs, in terms of the target flip-flop's inputs and current state, that produce equivalent behavior.
* This is largely an academic/interview exercise today — real RTL design simply describes the wanted behavior directly and lets synthesis map it to whatever flip-flop primitives are available in the target technology.

## Design Approach for JK/SR/Conversions
1. Build the truth table mentally (or on paper) first — know exactly what output should result for every input combination.
2. Encode inputs using a `case` statement on a concatenation of control signals — this maps cleanly to a truth table structure.
3. Priority: async reset first, then the case-based behavior.
4. For conversions (e.g., T from JK): identify which combination of the target device's inputs produces the desired subset of the source device's behavior, then simply wire the target inputs as continuous assignments (`assign`) feeding the instantiated source flip-flop.
5. **Testbench:** cover every mode explicitly with labeled test sections, and always include an async reset test partway through normal operation to verify priority.
