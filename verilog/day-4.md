# DAY 4: Finite State Machines (FSM)

## What Problem Does an FSM Solve?
An FSM formalizes decision-making logic that depends on history, not just current inputs[cite: 1]. Unlike pure combinational logic (output depends only on current inputs), an FSM's output/behavior depends on what has happened before — represented compactly by a finite set of named "states" rather than needing to remember the entire input history[cite: 1]. This is the theoretical bridge between simple sequential elements (flip-flops/registers, which store raw data) and complex control logic (which stores meaning — "where are we in a process")[cite: 1].

## The Five Formal Components of Any FSM
* **States:** the finite set of distinct conditions the system can be in[cite: 1].
* **Inputs:** external signals that can influence transitions[cite: 1].
* **Outputs:** signals produced, either from state alone (Moore) or state+input (Mealy)[cite: 1].
* **Transition function:** the rule set determining which state comes next, given current state and inputs[cite: 1].
* **Initial state:** the defined starting condition (critical — an FSM without a guaranteed, reachable initial state is not well-defined)[cite: 1].

## Moore Machine — Theoretical Properties
Output is a pure function of state only[cite: 1]. This has an important consequence: outputs are synchronized with the clock — they can only change immediately after a clock edge (when state updates), and remain perfectly stable between edges[cite: 1]. This guarantees glitch-free outputs, because there's no combinational path from a potentially-noisy/changing input directly to the output[cite: 1]. The tradeoff is that achieving certain behaviors may require introducing extra states purely to represent "the output should be different here," even if the underlying condition could otherwise be expressed via input+state[cite: 1].

## Mealy Machine — Theoretical Properties
Output is a function of both current state and current input[cite: 1]. This allows outputs to react within the same clock cycle the triggering input appears (via a purely combinational path), rather than waiting for the next state transition — enabling faster response and often fewer states[cite: 1]. The cost: because the output has a combinational dependency on the input, if the input is noisy/glitchy or changes multiple times between clock edges, the output can glitch too[cite: 1]. This makes Mealy outputs inherently harder to guarantee stable/clean, which is why safety-critical or protocol-level designs generally lean Moore[cite: 1].

## The 3-Block Coding Style — Theoretical Justification
Separating FSM description into exactly three always blocks is not arbitrary style preference — it directly reflects the three distinct types of logic present in any FSM[cite: 1]:
* **State register (sequential):** the only place actual storage/flip-flops are created[cite: 1]. Must use non-blocking assignment[cite: 1].
* **Next-state logic (combinational):** pure decision-making about transitions — no memory, so it must be re-evaluated any time state or inputs change (`@(*)`), and must use blocking assignment[cite: 1].
* **Output logic (combinational):** pure function generating outputs — same reasoning as above[cite: 1].

Mixing these into one block obscures which part is "memory" and which is "logic," makes it far easier to accidentally introduce simulation/synthesis mismatches or unintended latches, and is universally discouraged in real engineering practice[cite: 1].

## Latch Prevention Theory (Applies to Blocks 2 & 3)
A combinational always block must assign every output on every possible execution path, otherwise the synthesis tool is forced to infer memory (a latch) to "remember" the last value for the unassigned case — this is almost never the intended behavior in FSM logic[cite: 1]. Two standard defensive techniques[cite: 1]:
* Always include a default case in every case statement[cite: 1].
* Assign default values to every output before the case statement in the output-logic block, so every path is guaranteed at least one assignment even if the case doesn't explicitly override it[cite: 1].

## State Encoding — Theoretical Overview (Awareness Level)
The binary pattern chosen to represent each state is itself a design decision[cite: 1]:
* **Binary/sequential encoding:** minimum number of bits, but next-state decoding logic can become complex[cite: 1].
* **One-hot encoding:** one bit per state (only one bit ever high at a time) — uses more flip-flops but often results in simpler, faster decoding logic; commonly preferred in FPGA designs where flip-flops are abundant[cite: 1].
* **Gray code encoding:** consecutive states differ by only one bit — valuable in scenarios involving asynchronous observation of state (e.g., clock-domain-crossing) to avoid glitches during transitions[cite: 1].

## Sequence/Pattern Detection Theory
A sequence detector is a canonical FSM application demonstrating partial-match tracking — each state represents "how much of the target pattern have we matched so far, given the input seen up to now"[cite: 1]. The key theoretical subtlety is overlap handling: when a match completes, some suffix of the just-matched pattern may simultaneously be a valid prefix of a new potential match[cite: 1]. Correct overlapping detection requires transitioning not back to the initial "no progress" state, but to whichever state represents "how much of a new match is already implied by the tail of the pattern we just completed"[cite: 1]. Failing to account for this causes missed detections in cases where matches legitimately overlap in the input stream[cite: 1].

## Datapath + Control Integration (Vending Machine Theory)
Complex real-world FSMs often cannot be represented cleanly using state identity alone (e.g., "state = amount collected" doesn't scale if amounts can be arbitrary)[cite: 1]. The standard solution is to separate control and datapath[cite: 1]:
* **Control (FSM):** a small number of states representing broad phases of operation (e.g., "collecting money" vs "dispensing")[cite: 1].
* **Datapath (registers/arithmetic):** ordinary sequential logic (an accumulator/counter, in this case) tracks the actual numeric detail[cite: 1].

The FSM's transition/output decisions then read from and write to this datapath register, rather than trying to encode every possible numeric value as a distinct state[cite: 1]. This division — small control FSM + supporting data registers — is exactly how real processors, protocol controllers, and peripherals are built at a larger scale, making it one of the most transferable concepts in this entire curriculum[cite: 1].

## Design Approach for Any FSM
1. **Specify in words first:** list every distinct condition/state, every input that can cause a transition, and what output should occur in each state (or state+input, if Mealy)[cite: 1].
2. **Draw the state diagram** (even mentally/on paper) before writing code — this catches missing transitions early[cite: 1].
3. **Decide Moore or Mealy** based on whether glitch-free output or minimal-state/fast response matters more for this specific application[cite: 1].
4. **Encode states** with `localparam`, using descriptive names[cite: 1].
5. **Write exactly 3 blocks:** sequential state register (non-blocking), combinational next-state logic (blocking, with default case), combinational output logic (blocking, with defaults assigned before the case)[cite: 1].
6. **Integrate datapath if needed:** if the problem involves arbitrary numeric tracking (money, counts, addresses) rather than a small fixed set of conditions, introduce a datapath register alongside a small control FSM, rather than trying to create a unique state for every possible numeric value[cite: 1].
7. **Testbench approach:** test each transition path individually and explicitly labeled, always include a reset-during-operation test to confirm priority/async behavior, and for pattern detectors specifically, construct an input sequence that exercises the overlapping-match case to confirm it isn't missed[cite: 1].
