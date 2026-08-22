### Verilog Simulation Semantics

## 5.1 Why This Module Changes Everything

This is the module that separates engineers who **truly understand Verilog** from those who just write it.

Every bug you've ever had where:
- Simulation gave wrong results
- Blocking vs non-blocking behaved unexpectedly
- Two always blocks seemed to "race" each other
- A signal had the wrong value "at the same time"

...has its root explanation here.

The Verilog simulator is not magic. It follows a **precise, documented algorithm** for deciding what executes when. Once you understand that algorithm, simulation behavior becomes completely predictable.

---

## 5.2 The Fundamental Problem

Hardware is **massively parallel**. In real silicon, at any moment:
- Thousands of gates are switching simultaneously
- Every flip-flop samples on the same clock edge
- Combinational logic propagates in all directions at once

Software is **sequential**. A simulator runs on a CPU that executes one instruction at a time.

**The challenge:** How do you simulate parallel hardware on sequential software — correctly and efficiently?

The answer is the **Event-Driven Simulation Model.**

---

## 5.3 Event-Driven Simulation — The Core Concept

Instead of simulating every gate at every nanosecond (which would be impossibly slow), Verilog uses a smarter approach:

> **Only simulate what changes, only when it changes.**

An **event** is any signal value change:
- `a` goes from `0` to `1` → event on `a`
- `clk` goes from `1` to `0` → event on `clk`
- `out` changes from `X` to `0` → event on `out`

The simulator maintains an **event queue** — a list of pending events sorted by simulation time:

```
Event Queue:
┌──────────┬────────────┬───────────┐
│  Time    │  Signal    │  Value    │
├──────────┼────────────┼───────────┤
│  t=0     │  clk       │  0→1      │
│  t=0     │  reset     │  0→1      │
│  t=10    │  clk       │  1→0      │
│  t=20    │  clk       │  0→1      │
│  t=20    │  data_in   │  0→1      │
└──────────┴────────────┴───────────┘
```

**The simulation loop:**

```
1. Pick the earliest event from the queue
2. Advance simulation time to that event's time
3. Process the event (update signal value)
4. Find everything that depends on this signal
5. Schedule new events for those dependents
6. Repeat until queue is empty
```

This is why it's "event-driven" — the simulation only moves forward when something changes.

---

## 5.4 Simulation Time vs Real Time

**Simulation time** is a dimensionless integer counter inside the simulator. It has no inherent relationship to real time.

```verilog
`timescale 1ns/1ps
```

This directive maps simulation time to real time:
- `1ns` — one time unit = 1 nanosecond
- `1ps` — simulation precision = 1 picosecond

```verilog
#10 clk = ~clk;  // advance simulation time by 10 units (= 10ns)
```

**Critical insight:** The simulator doesn't actually wait 10 nanoseconds. It just jumps the internal counter by 10. Simulation can run faster or slower than real time depending on design complexity.

```
Real time:        1 second of CPU time
Simulation time:  could represent 1ns OR 1ms OR 1year
                  depends entirely on your design and timescale
```

**Why does this matter?**
When you write testbenches with delays, you're controlling the **simulation time counter**, not actual time. The `timescale` directive is just a scaling factor for display and annotation purposes.

---

## 5.5 The Stratified Event Queue — The Heart of Verilog

This is the most important concept in this module. The Verilog IEEE standard defines a **stratified (layered) event queue** for each simulation time step.

At any given simulation time T, events are processed in distinct **regions** in a specific order:

```
┌─────────────────────────────────────────────┐
│          SIMULATION TIME T                   │
├─────────────────────────────────────────────┤
│  Region 1: ACTIVE EVENTS                     │
│  → Blocking assignments (=)                  │
│  → Continuous assignments (assign)           │
│  → Evaluate RHS of non-blocking (<=)         │
│  → $display execution                        │
│  → Primitive gate outputs                    │
├─────────────────────────────────────────────┤
│  Region 2: INACTIVE EVENTS                   │
│  → #0 delayed assignments                   │
├─────────────────────────────────────────────┤
│  Region 3: NBA (Non-Blocking Assignment)     │
│  → Update LHS of non-blocking (<=)          │
├─────────────────────────────────────────────┤
│  Region 4: MONITOR EVENTS                    │
│  → $monitor execution                        │
├─────────────────────────────────────────────┤
│  Region 5: FUTURE EVENTS                     │
│  → Events scheduled for time T+N            │
└─────────────────────────────────────────────┘
```

**This ordering is defined by the IEEE 1364 standard.** It's not arbitrary — it's designed to make blocking and non-blocking assignments simulate hardware correctly.

---

## 5.6 The Active Region — Where Most Things Happen

The active region processes events in a loop:

```
ACTIVE REGION LOOP:
┌─────────────────────────────────────┐
│  While active event queue not empty: │
│    1. Pick any active event          │
│    2. Process it                     │
│    3. This may generate MORE         │
│       active events                  │
│    4. Add them to active queue       │
│    5. Continue                       │
└─────────────────────────────────────┘
```

**"Pick any active event"** — this is the key phrase. Within the active region, the order of event processing is **non-deterministic** (not guaranteed by the standard).

This is the source of **race conditions** in Verilog simulation.

---

## 5.7 Delta Cycles — The Concept That Confuses Everyone

Within a single simulation time step, the simulator may need to iterate multiple times before reaching a stable state. Each iteration is called a **delta cycle**.

Delta cycles happen at the **same simulation time** — time does not advance between them.

**Example:**

```verilog
wire a, b, c;
assign b = ~a;   // b is inverse of a
assign c = ~b;   // c is inverse of b (so c = a)
```

When `a` changes from `0` to `1`:

```
Delta 0: a changes to 1
         → schedule event: b depends on a

Delta 1: evaluate b = ~a = ~1 = 0
         b changes from 1 to 0
         → schedule event: c depends on b

Delta 2: evaluate c = ~b = ~0 = 1
         c changes from 0 to 1
         → no more dependents

Stable! Time can advance.
```

All of this happens at the **same simulation time**. From outside, `a`, `b`, `c` all appear to change simultaneously.

```
Simulation Time: ──────────────────────T─────────────────────────T+1──
                                       │△0│△1│△2│
                 a: ───────────────────1─────────────────────────
                 b: ───────────────────────0─────────────────────
                 c: ─────────────────────────────1───────────────
                 (all appear at time T, but processed in delta sequence)
```

**Why do delta cycles exist?**

Because combinational logic in hardware propagates through multiple stages. The delta cycle mechanism models this propagation correctly without advancing simulation time (since in ideal combinational logic, propagation is assumed to complete before the next clock edge).

---

## 5.8 How Many Delta Cycles Can There Be?

Theoretically, each delta cycle can trigger more events. The simulator keeps iterating until no new events are generated — a **stable state**.

**What if it never stabilizes?**

```verilog
// Combinational loop — will oscillate forever!
assign a = ~a;  // a depends on itself!
```

This creates an infinite delta cycle loop:
```
a=0 → ~a=1 → a=1 → ~a=0 → a=0 → ... forever
```

The simulator detects this and stops with a **simulation time-out** or **delta cycle limit** error. In GTKWave, you'd see the signal oscillating at a single time point.

**This is why combinational loops are forbidden** — not just in hardware (where they cause oscillation) but in simulation (where they cause infinite loops).

---

## 5.9 The NBA Region — Why Non-Blocking Works

Now we get to the most important part. Let's trace exactly what happens with non-blocking assignments.

```verilog
always @(posedge clk) begin
    a <= b;   // non-blocking
    b <= a;   // non-blocking
end
```

This should swap `a` and `b` on every clock edge. Let's trace it through the event queue:

**At `posedge clk`:**

```
ACTIVE REGION:
  → Evaluate RHS of (a <= b): RHS = current value of b = 5
    Schedule NBA update: a will become 5
  → Evaluate RHS of (b <= a): RHS = current value of a = 3
    Schedule NBA update: b will become 3
  (Note: a and b have NOT changed yet in active region)

NBA REGION:
  → Update a = 5  (from scheduled NBA event)
  → Update b = 3  (from scheduled NBA event)

Result: a=5, b=3  ← CORRECT SWAP!
```

Now compare with **blocking assignments**:

```verilog
always @(posedge clk) begin
    a = b;   // blocking
    b = a;   // blocking
end
```

**At `posedge clk`:**

```
ACTIVE REGION:
  → Execute (a = b): a immediately becomes 5
  → Execute (b = a): b becomes current a = 5 (NOT old a!)

Result: a=5, b=5  ← WRONG! No swap happened!
```

**This is the fundamental difference:**
- Non-blocking: RHS evaluated NOW, LHS updated LATER (in NBA region)
- Blocking: RHS evaluated NOW, LHS updated NOW

The NBA region exists specifically to make non-blocking assignments simulate **register behavior** correctly — all registers sample their inputs simultaneously, then all update simultaneously, just like real flip-flops on a clock edge.

---

## 5.10 $display vs $monitor — The Region Difference

These two system tasks execute in different regions:

```verilog
$display("value = %b", out);  // executes in ACTIVE region
$monitor("value = %b", out);  // executes in MONITOR region
```

**`$display`** runs immediately when the statement is reached in the active region. If `out` changes later in the same time step (due to NBA updates), `$display` already printed the old value.

**`$monitor`** waits until ALL events at the current time step are processed (after NBA region), then prints. It always shows the **final settled value**.

```verilog
// This can print wrong values!
always @(posedge clk) begin
    q <= d;
    $display("q = %b", q);  // prints q BEFORE NBA update!
end

// This always prints correct final value
initial
    $monitor("q = %b", q);  // prints after everything settles
```

**This catches many beginners off guard.** A `$display` inside an `always @(posedge clk)` block with non-blocking assignments will print the value of `q` BEFORE the non-blocking update happens.

---

## 5.11 Race Conditions in Simulation

A race condition occurs when the result depends on the **non-deterministic ordering** within the active region.

```verilog
// Module 1
always @(posedge clk)
    a = b;   // blocking

// Module 2
always @(posedge clk)
    c = a;   // blocking — does this see old or new a?
```

At `posedge clk`, both always blocks are triggered simultaneously. They're both in the active region. The simulator picks one to execute first — **but the standard doesn't say which.**

```
Possibility 1: Block 1 runs first
  a = b (a updates to new value)
  c = a (c gets NEW value of a)

Possibility 2: Block 2 runs first
  c = a (c gets OLD value of a)
  a = b (a updates)
```

**Two valid simulation runs can give different results.** This is a race condition.

**The fix:**

```verilog
// Use non-blocking assignments
always @(posedge clk)
    a <= b;   // NBA: a updates after active region

always @(posedge clk)
    c <= a;   // sees OLD value of a (before NBA update)
              // regardless of execution order
```

Non-blocking assignments **eliminate this race condition** because both blocks read `a`'s old value in the active region, and both write their results in the NBA region — execution order doesn't matter.

---

## 5.12 Putting It All Together — Complete Trace

Let's trace a complete clock cycle for a simple pipeline:

```verilog
always @(posedge clk) begin
    b <= a;   // stage 1
    c <= b;   // stage 2
end
```

Initial state: `a=1, b=2, c=3`

```
posedge clk occurs:

ACTIVE REGION:
  Event: posedge clk detected
  → Evaluate RHS of (b <= a): RHS = 1 (current a)
    Schedule NBA: b ← 1
  → Evaluate RHS of (c <= b): RHS = 2 (current b, NOT updated yet)
    Schedule NBA: c ← 2
  Active region settles

NBA REGION:
  → b updates to 1
  → c updates to 2

Final state: a=1, b=1, c=2
```

**This is correct pipeline behavior** — each stage sees the value from the previous clock cycle, not the current one. This is exactly what hardware does.

---

## 5.13 Common Misconceptions

**Misconception 1:** "Delta cycles take real time"

No. Multiple delta cycles happen at the exact same simulation time. They're internal iterations, invisible to the waveform viewer except as simultaneous changes.

**Misconception 2:** "Non-blocking is slower than blocking"

In simulation, non-blocking has slightly more overhead (scheduling NBA events). In hardware, there's no difference — both produce flip-flops.

**Misconception 3:** "`$display` shows current values"

Not always. Inside procedural blocks with non-blocking assignments, `$display` runs in the active region before NBA updates. Use `$monitor` for final settled values.

**Misconception 4:** "The simulator processes always blocks in the order they're written"

The standard explicitly states this is **non-deterministic** within the active region. Never rely on execution order of multiple always blocks.

---

## Quiz — Module 5

**Q1.** What is an event in Verilog simulation? Give two examples of events that would be added to the event queue.

**Q2.** Trace through the delta cycles for this code when `a` changes from `1` to `0`:
```verilog
wire b, c, d;
assign b = ~a;
assign c = b & a;
assign d = b | c;
```
What are the final values of b, c, d?

**Q3.** Why does this code potentially give wrong results, and what is the fix:
```verilog
always @(posedge clk) begin
    x = y;
    z = x;
end
```

**Q4.** What is the difference between `$display` and `$monitor`? In which simulation region does each execute?

**Q5.** Consider:
```verilog
always @(posedge clk) begin
    a <= b;
    b <= a;
end
```
If initially `a=0, b=1`, what are the values after one clock edge? Trace through the active and NBA regions to explain.

**Q6. (Hard)** A combinational loop causes infinite delta cycles. But a **registered feedback loop** (output of flip-flop feeding back to its own input through logic) does NOT cause infinite delta cycles. Explain why — what breaks the cycle in the registered case?