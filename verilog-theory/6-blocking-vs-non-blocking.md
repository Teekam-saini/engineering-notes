# Module 6: Blocking vs Non-Blocking — Complete Theory

## 6.1 Why This Topic Deserves Its Own Module

Blocking vs non-blocking assignments are one of the most important concepts in Verilog because they determine how simulation represents hardware behavior.

The common rule is:

> Use `=` for combinational logic and `<=` for sequential logic.

That rule is useful, but incomplete. The real reason is that blocking and non-blocking assignments have fundamentally different simulation semantics.

The key idea is:

> **Non-blocking assignments allow Verilog simulation to model the parallel behavior of hardware registers.**

---

## 6.2 Two Assignment Mechanisms — Fundamentally Different

### Blocking assignment `=`

For a blocking assignment:

1. The RHS is evaluated immediately.
2. The LHS is updated immediately.
3. Execution continues to the next statement only after the assignment completes.

```verilog
a = b;
c = a;
```

If `b = 5`, then after the first statement `a = 5`, so the second statement sees `a = 5`.

Therefore:

> **Blocking assignments create sequential execution within the procedural block.**

### Non-blocking assignment `<=`

For a non-blocking assignment:

1. The RHS is evaluated immediately.
2. The resulting value is scheduled for a later update in the NBA region.
3. The next statement executes immediately.
4. The LHS is updated only when the NBA event is processed.

```verilog
a <= b;
c <= a;
```

If initially `a = 1` and `b = 5`, then both RHS expressions are evaluated before either LHS is updated:

```text
a <= b  → schedule a = 5
c <= a  → schedule c = OLD a = 1

NBA region:
a = 5
c = 1
```

Therefore:

> **Non-blocking assignments preserve the old values during RHS evaluation and model simultaneous register updates.**

---

## 6.3 The Physical Hardware Reality

A flip-flop does not behave like a software statement.

At a clock edge, a bank of flip-flops effectively:

1. Samples its input.
2. Stores that sampled value.
3. Updates its output after the relevant propagation delay.

All flip-flops connected to the same clock edge operate in parallel.

Consider:

```text
        ┌──────┐          ┌──────┐
D_A ───►│ FF A │── Q_A ──►│ FF B │── Q_B
        └──────┘          └──────┘
            ▲                 ▲
            │                 │
           clk               clk
```

At the clock edge:

```text
FF A samples D_A
FF B samples OLD Q_A

Then:
FF A updates Q_A
FF B updates Q_B
```

FF B does **not** wait for FF A's new Q output and then capture it during the same edge.

That is exactly why this code correctly models a two-stage pipeline:

```verilog
always @(posedge clk) begin
    Q_A <= D_A;
    Q_B <= Q_A;
end
```

The simulation evaluates:

```text
Q_A <= D_A  → sample current D_A
Q_B <= Q_A  → sample current OLD Q_A

NBA:
Q_A updates
Q_B updates
```

This matches the hardware.

---

## 6.4 Why Blocking Is Dangerous in Sequential Logic

Consider:

```verilog
always @(posedge clk) begin
    Q_A = D_A;
    Q_B = Q_A;
end
```

Simulation executes the statements sequentially:

```text
Q_A = D_A
↓
Q_A immediately changes
↓
Q_B = Q_A
↓
Q_B sees NEW Q_A
```

This can make a pipeline appear to collapse into a single stage.

For example, if:

```text
D_A = 8
Q_A = 5
Q_B = 2
```

then the blocking version can produce:

```text
Q_A = 8
Q_B = 8
```

whereas the intended sequential hardware behavior is:

```text
Q_A = 8
Q_B = 5
```

This is the fundamental reason non-blocking assignments are preferred for clocked sequential logic.

---

## 6.5 Combinational Logic — Why Blocking Works

Combinational logic has no clocked storage. A combinational block often describes a chain of calculations.

```verilog
always @(*) begin
    temp = a & b;
    out  = temp | c;
end
```

Here the intended dependency is:

```text
a,b
 ↓
temp = a & b
 ↓
out = temp | c
```

Blocking assignment is appropriate because `out` needs to see the newly calculated `temp`.

With non-blocking assignments:

```verilog
always @(*) begin
    temp <= a & b;
    out  <= temp | c;
end
```

the simulator does this:

```text
Active region:
    evaluate a & b
    schedule temp update
    evaluate OLD temp | c
    schedule out update

NBA region:
    update temp
    update out
```

Therefore `out` uses the **old value of `temp`**.

This creates an extra delta-cycle of simulation behavior and can cause confusing races when other processes interact with the signals.

The correct combinational style is:

```verilog
always @(*) begin
    temp = a & b;
    out  = temp | c;
end
```

In SystemVerilog, `always_comb` is preferred.

---

## 6.6 The Cummings Rules — Industry Standard Guidance

Cliff Cummings' work on Verilog race conditions and non-blocking assignments strongly influenced standard RTL coding practices.

### Rule 1: Sequential logic → non-blocking

```verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 1'b0;
    else
        q <= d;
end
```

### Rule 2: Latches → non-blocking

```verilog
always @(*) begin
    if (en)
        q <= d;
end
```

The incomplete assignment intentionally describes storage, so non-blocking assignment is appropriate.

### Rule 3: Combinational logic → blocking

```verilog
always @(*) begin
    case (sel)
        2'b00: out = a;
        2'b01: out = b;
        2'b10: out = c;
        default: out = d;
    endcase
end
```

### Rule 4: Avoid mixing assignment types in one procedural block

For example:

```verilog
always @(posedge clk) begin
    temp = a & b;
    q    <= temp;
end
```

This may simulate correctly, but mixing styles makes the timing behavior harder to reason about and can introduce race problems when signals are shared with other processes.

There are specialized cases where mixing can be intentional, but ordinary RTL should follow a consistent assignment style.

### Rule 5: Avoid multiple procedural drivers for the same variable

```verilog
always @(posedge clk)
    q <= a;

always @(posedge clk)
    q <= b;
```

This creates multiple procedural drivers for `q` and should not be used for ordinary synthesizable RTL.

---

## 6.7 Why Mixing Can Cause Problems

Consider:

```verilog
always @(posedge clk) begin
    temp = a & b;
    q    <= temp;
end
```

Inside this single block, it happens in a predictable order:

```text
temp = a & b
↓
temp immediately changes
↓
q <= temp
↓
q samples the new temp
↓
q updates later in NBA
```

So this particular example is not necessarily broken.

Now reverse the statements:

```verilog
always @(posedge clk) begin
    q    <= temp;
    temp = a & b;
end
```

Now:

```text
q samples OLD temp
temp changes immediately
q updates later
```

The result depends on procedural ordering.

The deeper issue appears when multiple always blocks interact.

```verilog
always @(posedge clk)
    temp = a & b;

always @(posedge clk)
    q <= temp;
```

Both blocks wake up because of the same clock edge.

The simulator is allowed to choose an execution order for active events. If the first block executes first, `q` can sample the new `temp`. If the second executes first, `q` samples the old `temp`.

That is a **simulation race condition**.

Non-blocking assignments remove this ambiguity for normal clocked RTL:

```verilog
always @(posedge clk)
    temp <= a & b;

always @(posedge clk)
    q <= temp;
```

Both blocks sample their RHS values during the active region and update their registers in the NBA region.

---

## 6.8 The Complete Event Queue Trace

Consider:

```verilog
module pipeline (
    input      clk,
    input  [7:0] a,
    output reg [7:0] b, c
);

    always @(posedge clk) begin
        b <= a;
        c <= b;
    end

endmodule
```

Initial state:

```text
a = 8
b = 5
c = 2
```

At the positive clock edge:

### Active region

The always block is triggered.

First statement:

```verilog
b <= a;
```

The simulator evaluates:

```text
a = 8
```

and schedules:

```text
NBA event: b ← 8
```

But `b` is not changed yet.

Second statement:

```verilog
c <= b;
```

The simulator evaluates:

```text
b = 5
```

because `b` has not been updated yet.

It schedules:

```text
NBA event: c ← 5
```

### NBA region

The scheduled updates execute:

```text
b ← 8
c ← 5
```

Final state:

```text
a = 8
b = 8
c = 5
```

That is exactly the behavior expected from a two-stage pipeline.

With blocking assignments:

```verilog
always @(posedge clk) begin
    b = a;
    c = b;
end
```

the simulator performs:

```text
b = a
↓
b becomes 8 immediately
↓
c = b
↓
c becomes 8
```

Final state:

```text
a = 8
b = 8
c = 8
```

The simulated behavior no longer represents two independent registers sampling simultaneously.

---

## 6.9 Intra-Assignment Delay

Verilog supports delays associated with assignments.

Compare:

```verilog
a <= #10 b;
```

with:

```verilog
#10 a <= b;
```

They are not equivalent.

### Intra-assignment delay

```verilog
a <= #10 b;
```

The RHS is evaluated immediately.

```text
T = 0:
    sample b

T = 10:
    update a with sampled value
```

### Procedural delay

```verilog
#10 a <= b;
```

The process waits first.

```text
T = 0:
    wait

T = 10:
    evaluate b
    schedule/update a
```

So if `b` changes between T=0 and T=10:

```text
a <= #10 b
```

uses the value of `b` at T=0, while:

```text
#10 a <= b
```

uses the value of `b` at T=10.

### Typical use

Intra-assignment delays are mainly useful in simulation and testbenches:

```verilog
always @(posedge clk) begin
    data  <= #2 new_data;
    valid <= #2 1'b1;
end
```

They can model stimulus timing or propagation behavior.

For synthesizable RTL, explicit delays such as `#2` are generally not synthesizable and should not be used to describe physical hardware timing.

---

## 6.10 Common Bugs

### Bug 1: Non-blocking assignment in combinational logic

```verilog
always @(*) begin
    if (sel)
        out <= a;
    else
        out <= b;
end
```

The problem is that the assignment is scheduled into the NBA region rather than updating immediately.

This creates a delta-cycle separation between input evaluation and output update.

It does **not automatically create a physical flip-flop**, and saying that it "creates a register" is too simplistic. Synthesis can still infer the intended combinational hardware. The issue is primarily simulation scheduling and possible race behavior.

Correct style:

```verilog
always @(*) begin
    if (sel)
        out = a;
    else
        out = b;
end
```

---

### Bug 2: Blocking assignment in sequential logic

```verilog
always @(posedge clk)
    q = d;

always @(posedge clk)
    result = q + 1;
```

Both blocks trigger at the same clock edge.

Because `q` is updated using a blocking assignment in the active region, the simulator's execution order can determine whether `result` sees the old or new value.

This is a race condition.

Correct style:

```verilog
always @(posedge clk)
    q <= d;

always @(posedge clk)
    result <= q + 1;
```

Now both registers sample their inputs before either register is updated.

---

### Bug 3: Blocking assignments causing simulation/hardware mismatch

Consider:

```verilog
always @(posedge clk) begin
    a = b + c;
    d = a * 2;
end
```

Simulation executes sequentially:

```text
a = b + c
d = NEW a * 2
```

So simulation effectively calculates:

```text
d = (b + c) * 2
```

But if `a` and `d` represent flip-flops, hardware samples both old inputs at the clock edge.

Therefore `d` should use the **old** value of `a`.

The safer sequential description is:

```verilog
always @(posedge clk) begin
    a <= b + c;
    d <= a * 2;
end
```

Now simulation correctly models two registers:

```text
new_a = old_b + old_c
new_d = old_a * 2
```

---

## 6.11 IEEE Standard and Simulation Regions

The Verilog language defines event scheduling semantics so that simulators can model concurrent hardware using an event-driven simulation model.

A simplified view of the scheduling process is:

```text
Active events
     ↓
Inactive events (#0)
     ↓
NBA events
     ↓
Monitor / observation regions
```

Modern SystemVerilog defines a more detailed scheduler with additional regions, including observed, reactive, and postponed regions.

The important point is:

> **The scheduling regions are part of the language semantics, not merely an implementation trick used by one simulator.**

This defined ordering is what makes non-blocking assignments useful for modeling clocked hardware.

---

## 6.12 SystemVerilog Additions

SystemVerilog added procedural blocks that explicitly communicate design intent.

### `always_ff`

Used for flip-flop-based sequential logic:

```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

### `always_comb`

Used for combinational logic:

```systemverilog
always_comb begin
    out = a & b;
end
```

### `always_latch`

Used for latch behavior:

```systemverilog
always_latch begin
    if (en)
        q <= d;
end
```

These constructs allow tools to check whether the code follows the intended modeling style.

For example, `always_ff` places restrictions on how variables are written and is intended to model flip-flop behavior. `always_comb` provides automatic sensitivity handling and checks associated with combinational logic.

The assignment-style convention remains:

```text
always_ff    → <=
always_comb → =
always_latch → <=
```

---

## 6.13 The Deep Insight

The most important concept is not:

> "`=` means combinational."

or:

> "`<=` means sequential."

The deeper principle is:

> **Blocking assignment models immediate procedural state change. Non-blocking assignment separates sampling from updating.**

That separation is exactly what clocked hardware needs.

A useful mental model is:

```text
Blocking:
    READ → UPDATE → READ → UPDATE

Non-blocking:
    READ → READ → READ
              ↓
          UPDATE UPDATE UPDATE
```

For flip-flops:

```text
Clock edge
    ↓
All registers sample their inputs
    ↓
All registers update their outputs
```

Non-blocking assignment models this naturally.

This is why:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
    q3 <= q2;
end
```

creates the expected three-stage pipeline behavior.

At every clock edge:

```text
new_q1 = old_d
new_q2 = old_q1
new_q3 = old_q2
```

---

# Quiz — Module 6 Answers

## Q1. Trace the active and NBA regions

Initial state:

```text
p = 1
q = 2
r = 3
```

Code:

```verilog
always @(posedge clk) begin
    p <= q;
    q <= r;
    r <= p;
end
```

### Active region

The simulator evaluates all RHS expressions using the current values.

```text
p <= q  → schedule p = 2
q <= r  → schedule q = 3
r <= p  → schedule r = 1
```

Nothing has changed yet.

### NBA region

The scheduled updates occur:

```text
p = 2
q = 3
r = 1
```

### Final answer

```text
p = 2
q = 3
r = 1
```

This is effectively a three-register rotation.

---

## Q2. Why is this combinational block problematic?

Code:

```verilog
always @(*) begin
    temp <= a + b;
    out  <= temp * 2;
end
```

The problem is that both assignments are non-blocking.

During the active region:

```text
temp <= a + b
    ↓
schedule temp update

out <= temp * 2
    ↓
evaluate OLD temp
    ↓
schedule out update
```

Only afterward, in the NBA region, does `temp` receive the newly calculated value.

Therefore `out` does not use the newly calculated `temp` during the same execution of the block.

The correct combinational style is:

```verilog
always @(*) begin
    temp = a + b;
    out  = temp * 2;
end
```

Now:

```text
temp = a + b
    ↓
temp immediately updates
    ↓
out = temp * 2
    ↓
out sees NEW temp
```

Important correction to a common misconception:

> Non-blocking assignment in combinational logic does not inherently synthesize a flip-flop. The main problem is incorrect simulation scheduling and potential races. Incomplete assignments, not non-blocking syntax by itself, are what commonly cause latch inference.

---

## Q3. How would you prove blocking assignments can cause a real hardware bug?

Use a pipeline example:

```verilog
always @(posedge clk) begin
    stage1 = input;
    stage2 = stage1;
end
```

Suppose:

```text
input  = 10
stage1 = 5
stage2 = 2
```

Simulation with blocking assignments produces:

```text
stage1 = 10
stage2 = 10
```

because `stage2` sees the newly updated `stage1`.

But real hardware contains two flip-flops:

```text
input → FF1 → FF2
```

At the same clock edge:

```text
FF1 samples input = 10
FF2 samples OLD FF1 = 5
```

Therefore hardware produces:

```text
stage1 = 10
stage2 = 5
```

The simulation has effectively collapsed two pipeline stages into one.

The correct RTL is:

```verilog
always @(posedge clk) begin
    stage1 <= input;
    stage2 <= stage1;
end
```

This is a concrete example of simulation behavior failing to represent the intended hardware timing.

---

## Q4. Difference between Version A and Version B

### Version A

```verilog
always @(posedge clk)
    a <= #5 b;
```

This is an intra-assignment delay.

At the clock edge:

```text
T = 0:
    sample b

T = 5:
    update a with the sampled value
```

So:

> **Version A samples `b` immediately and updates `a` 5 time units later.**

### Version B

```verilog
always @(posedge clk)
    #5 a <= b;
```

The procedural block waits first.

```text
T = 0:
    wait 5

T = 5:
    evaluate b
    schedule a update
```

So:

> **Version B samples `b` after the 5-time-unit delay.**

The key difference is:

```text
A: SAMPLE → WAIT → UPDATE

B: WAIT → SAMPLE → UPDATE
```

If `b` changes during those five time units, the two versions can produce different results.

---

## Q5. Identify the simulation/synthesis mismatch

Code:

```verilog
always @(posedge clk) begin
    x = a & b;
    y = x | c;
    z = y ^ d;
end
```

The problem is the use of blocking assignments for sequential logic.

### Simulation behavior

Simulation executes the statements in order:

```text
x = a & b
↓
y = NEW x | c
↓
z = NEW y ^ d
```

Therefore simulation effectively calculates:

```text
x = a & b
y = (a & b) | c
z = ((a & b) | c) ^ d
```

all during the same procedural execution.

### Hardware behavior

If `x`, `y`, and `z` are synthesized as flip-flops, they all sample their inputs on the same clock edge.

Therefore:

```text
new_x = old_a & old_b
new_y = old_x | old_c
new_z = old_y ^ old_d
```

So the actual hardware contains three sequential stages:

```text
x → y → z
```

The correct RTL is:

```verilog
always @(posedge clk) begin
    x <= a & b;
    y <= x | c;
    z <= y ^ d;
end
```

Now the simulation matches the physical pipeline.

---

# Q6. Hard Question — Why Is the NBA Region Necessary?

This is the most important question in the module.

A tempting idea is:

> "Why not simply execute blocking assignments normally and update every LHS at the end of the entire `always` block?"

Because that would solve only a **local** problem.

Verilog is not one giant procedural program. It is a collection of **concurrent processes**.

Consider:

```verilog
always @(posedge clk)
    q1 <= d;

always @(posedge clk)
    q2 <= q1;
```

Both always blocks are triggered by the same clock edge.

There is no meaningful concept of:

```text
always block 1 finishes
THEN
always block 2 starts
```

The simulator must represent the fact that both processes are concurrent.

### Problem 1: Multiple processes must sample before updating

At the clock edge:

```text
Process A:
    q1 <= d

Process B:
    q2 <= q1
```

The intended hardware behavior is:

```text
q1 samples d
q2 samples OLD q1

then:
q1 updates
q2 updates
```

If updates were performed merely at the end of each `always` block, the simulator would still have to define how different blocks interact.

Suppose it executes block A first:

```text
Block A:
    q1 updates
Block A finishes

Block B:
    q2 reads NEW q1
```

Now the pipeline is broken.

If it executes block B first:

```text
Block B:
    q2 reads OLD q1

Block A:
    q1 updates
```

the correct result occurs.

The problem is therefore not just where one block ends. The problem is **coordination between concurrent blocks**.

### Problem 2: The NBA region creates a global synchronization point

The NBA region effectively gives clocked processes this structure:

```text
                    CLOCK EDGE
                        │
          ┌─────────────┴─────────────┐
          │                           │
       Process A                   Process B
          │                           │
      sample d                    sample q1
          │                           │
      schedule q1                 schedule q2
          │                           │
          └─────────────┬─────────────┘
                        │
                    NBA REGION
                        │
                  update q1, q2
```

This is the critical insight.

The NBA region is not merely:

> "A place where assignments happen later."

It acts as a **deferred update mechanism that allows many concurrent processes to complete their sampling before their state changes become visible.**

### Problem 3: Cascading updates would otherwise corrupt sequential behavior

Consider a three-stage pipeline:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
    q3 <= q2;
end
```

The desired behavior is:

```text
new_q1 = old_d
new_q2 = old_q1
new_q3 = old_q2
```

Without deferred updates, an update to `q1` could become visible before another process samples it.

That would allow information to travel through multiple pipeline stages during one clock edge.

Instead, NBA scheduling preserves the boundary:

```text
CLOCK EDGE
   ↓
SAMPLE ALL OLD STATE
   ↓
NBA
   ↓
UPDATE ALL REGISTER STATE
```

### Problem 4: "End of always block" is not a global event

This is the subtle answer.

There is no single "end of the always block" for the entire design.

There may be:

```text
1000 always blocks
1000 concurrent events
multiple modules
multiple clocks
multiple triggered processes
```

All of these interact through the simulator's event queue.

Therefore the language needs a scheduling mechanism that can say:

> "These values have been sampled now. Do not make their updates visible until the appropriate later simulation region."

That mechanism is the NBA region.

### The deeper hardware analogy

Think of a clock edge as a global barrier:

```text
                CLOCK EDGE
                    │
        ┌───────────┼───────────┐
        ↓           ↓           ↓
      FF1         FF2         FF3
     SAMPLE      SAMPLE      SAMPLE
        │           │           │
        └───────────┼───────────┘
                    ↓
              UPDATE OUTPUTS
```

The NBA region provides the simulation equivalent of this separation:

```text
ACTIVE REGION
    ↓
sample/evaluate RHS
    ↓
NBA REGION
    ↓
update LHS
```

That is why simply saying "update at the end of the always block" is insufficient.

The required boundary is not:

> **end of one procedural block**

It is:

> **after all relevant concurrent processes have had the opportunity to evaluate their RHS expressions for that simulation time step.**

That is the fundamental reason the NBA mechanism matters.

---

# Final Mental Model

If you remember only one diagram from this module, remember this:

```text
                BLOCKING
                    │
        RHS → UPDATE → RHS → UPDATE
                    │
             Immediate visibility


             NON-BLOCKING
                    │
        RHS → RHS → RHS → RHS
                    │
              NBA REGION
                    │
        UPDATE → UPDATE → UPDATE
                    │
             Deferred visibility
```

For hardware modeling:

```text
COMBINATIONAL LOGIC
    ↓
Need immediate procedural propagation
    ↓
BLOCKING (=)


SEQUENTIAL LOGIC
    ↓
Need simultaneous register behavior
    ↓
NON-BLOCKING (<=)
```

And the most precise rule is:

> **Use the assignment type that matches the hardware abstraction you are modeling: blocking for immediate procedural combinational computation, non-blocking for clocked state updates where sampling and updating must be separated.**

