#  Dataflow Modeling 

## 4.1 What "Dataflow" Actually Means

The name "dataflow" tells you exactly what this style models — how data flows through your circuit continuously. Think of it like water through pipes:

```
        ┌─────────────┐
a ─────►│             │
        │  Logic f(x) ├────► out
b ─────►│             │
        └─────────────┘

```

The moment `a` or `b` changes, `out` changes. There is no waiting, no triggering, and no clock. Data flows continuously through the logic. This is fundamentally different from behavioral modeling where code executes when a triggering event occurs. Dataflow modeling describes a permanent relationship between signals.

---

## 4.2 The assign Statement — Deep Theory

The `assign` statement is the heart of dataflow modeling:

```verilog
assign out = a & b;

```

This single line tells the simulator three things:

1. **CREATE a permanent dependency:** `out` depends on `a` and `b`.
2. **EVALUATE continuously:** Whenever `a` or `b` changes, recalculate `out`.
3. **UPDATE immediately:** `out` gets the new value (after any propagation delay).

### What the Simulator Does Internally

When the simulator encounters `assign out = a & b;`, it creates an entry in the event-driven engine:

* If signal `a` changes $\rightarrow$ re-evaluate `(a & b)` $\rightarrow$ update `out`.
* If signal `b` changes $\rightarrow$ re-evaluate `(a & b)` $\rightarrow$ update `out`.

This is why it is called a continuous assignment. The simulator continuously watches `a` and `b`, re-evaluating the right-hand side the moment either changes.

Compare this to `always @(*)`:

```verilog
always @(*) begin
    out = a & b;
end

```

This looks similar but works differently internally. The `always` block triggers on sensitivity list changes and executes procedurally (statement by statement), whereas `assign` has no trigger and simply maintains a permanent continuous relationship.

---

## 4.3 Rules of `assign` — Complete List

```verilog
// RULE 1: Left-hand side must be a net (wire)
wire out;
assign out = a & b;    // Correct
reg  out2;
assign out2 = a & b;   // Incorrect: reg cannot be on LHS

// RULE 2: Right-hand side can be anything
assign out = a & b;           // nets
assign out = reg_signal;      // reg on RHS is fine
assign out = 4'b1010;         // constants
assign out = a ? b : c;       // expressions

// RULE 3: A wire can only have ONE continuous driver
assign out = a & b;
assign out = c | d;    // Incorrect: two drivers cause contention (X result)

// RULE 4: Cannot be inside always/initial blocks
always @(*) begin
    assign out = a & b;  // Incorrect: assign inside procedural blocks is illegal
end

// RULE 5: Delays are allowed (but ignored by synthesis)
assign #10 out = a & b;  // 10 time unit delay — simulation only

```

---

## 4.4 Operators — Deep Dive

### Arithmetic Operators

```verilog
assign sum  = a + b;   // addition
assign diff = a - b;   // subtraction
assign prod = a * b;   // multiplication
assign quot = a / b;   // division
assign rem  = a % b;   // modulo

```

**Synthesis mapping:**

* `+` $\rightarrow$ Adder circuit (ripple-carry, carry-lookahead, etc.)
* `-` $\rightarrow$ Subtractor (or adder with complement)
* `*` $\rightarrow$ Multiplier (expensive in area and gates)
* `/` and `%` $\rightarrow$ Dividers and modulo (very expensive, often not synthesizable efficiently in RTL)

**Critical width behavior:**

```verilog
wire [3:0] a = 4'b1111;  // 15
wire [3:0] b = 4'b0001;  // 1
wire [3:0] sum;
wire [4:0] sum_full;

assign sum      = a + b;  // 15 + 1 = 16 → 4'b0000 (OVERFLOW!)
assign sum_full = a + b;  // 15 + 1 = 16 → 5'b10000 (Correct)

```

The result width equals the width of the left-hand side. Overflow is silently truncated, making this a very common RTL bug.
*Industry rule:* When adding $N$-bit numbers, make the result $N+1$ bits to capture the carry.

---

### Bitwise vs Logical Operators

```verilog
// BITWISE — operates on each bit individually
assign out = a & b;   // AND each bit
assign out = a | b;   // OR each bit
assign out = a ^ b;   // XOR each bit
assign out = ~a;      // invert each bit

// LOGICAL — treats entire value as true/false
assign out = a && b;  // is a non-zero AND b non-zero?
assign out = a || b;  // is a non-zero OR b non-zero?
assign out = !a;      // is a zero?

```

**Example comparison:**

```verilog
wire [3:0] a = 4'b1100;  // 12
wire [3:0] b = 4'b0011;  // 3

assign bitwise = a & b;   // 4'b1100 & 4'b0011 = 4'b0000
assign logical = a && b;  // 12 is nonzero AND 3 is nonzero = 1'b1

```

Bitwise AND result is `0`, but Logical AND result is `1` for the same inputs.

---

### Relational and Equality Operators

```verilog
// Relational (result is 1-bit true/false)
a > b    // greater than
a < b    // less than
a >= b   // greater or equal
a <= b   // less or equal

// Equality — TWO types
a == b   // logical equality
a != b   // logical inequality

a === b  // case equality
a !== b  // case inequality

```

The difference between `==` and `===` is vital:

```verilog
wire [1:0] a = 2'b1x;  // contains X
wire [1:0] b = 2'b1x;

assign eq1 = (a == b);   // result = X (unknown)
assign eq2 = (a === b);  // result = 1 (identical bit-by-bit including X)

```

* `==` follows 4-value logic; if either operand has `X` or `Z`, the result is `X`.
* `===` performs an exact bit-by-bit comparison (`X` matches `X`, `Z` matches `Z`), always returning `0` or `1`.

*Synthesis implication:* `==` is synthesizable and generates comparator hardware, whereas `===` is non-synthesizable because `X` and `Z` do not exist in real silicon.

---

### Shift Operators

```verilog
assign out = a << 2;   // logical left shift by 2
assign out = a >> 2;   // logical right shift by 2
assign out = a <<< 2;  // arithmetic left shift (Verilog-2001)
assign out = a >>> 2;  // arithmetic right shift (Verilog-2001)

```

Logical shifts fill vacated bits with `0`. Arithmetic right shift fills vacated bits with the sign bit (MSB).

```verilog
reg signed [7:0] a = 8'b10110000;  // -80 in two's complement

assign logical_right    = a >> 2;    // 8'b00101100 = +44 (wrong for signed)
assign arithmetic_right = a >>> 2;  // 8'b11101100 = -20 (correct for signed)

```

*Physical meaning:* Left or right shift by a constant amount is free in hardware, requiring no logic gates—just permanent wire connections to different bit positions.

---

### Reduction Operators

Reduction operators reduce a multi-bit vector to a single bit:

```verilog
wire [3:0] a = 4'b1011;

assign and_all  = &a;   // 1 & 0 & 1 & 1 = 0
assign or_all   = |a;   // 1 | 0 | 1 | 1 = 1
assign xor_all  = ^a;   // 1 ^ 0 ^ 1 ^ 1 = 1 (parity)
assign nand_all = ~&a;  // ~(1 & 0 & 1 & 1) = 1
assign nor_all  = ~|a;  // ~(1 | 0 | 1 | 1) = 0
assign xnor_all = ~^a;  // ~(1 ^ 0 ^ 1 ^ 1) = 0

```

* **Parity check:** `assign parity = ^data;`
* **All-zero check:** `assign all_zero = ~|bus;` (NOR reduction)
* **All-one check:** `assign all_one = &bus;` (AND reduction)

---

### Concatenation and Replication

```verilog
// Concatenation — join signals together
wire [7:0] result = {high_nibble, low_nibble};  // {4-bit, 4-bit} → 8-bit
wire [3:0] swap   = {a[1:0], a[3:2]};          // swap bit pairs

// Replication — repeat a pattern
wire [7:0] replicated = {4{2'b10}};  // 8'b10101010
wire [7:0] sign_extend = {{4{a[3]}}, a[3:0]};  // sign extend 4-bit to 8-bit

```

Sign extension using replication ensures negative numbers retain their value when widened:

```verilog
wire signed [3:0] small = 4'b1011;  // -5 in two's complement
wire signed [7:0] large;

// Incorrect: zero extension changes the value for negative numbers
assign large = {4'b0000, small};  // 8'b00001011 = +11 (wrong)

// Correct: sign extension replicates MSB
assign large = {{4{small[3]}}, small};  // 8'b11111011 = -5 (correct)

```

Concatenation and replication consume zero logic gates; they are implemented purely as wire routing.

---

## 4.5 Operator Precedence

1. Unary operators (`+`, `-`, `!`, `~`)
2. Multiply, divide, modulo (`*`, `/`, `%`)
3. Binary addition and subtraction (`+`, `-`)
4. Shifts (`<<`, `>>`, `<<<`, `>>>`)
5. Relational (`<`, `<=`, `>`, `>=`)
6. Equality (`==`, `!=`, `===`, `!==`)
7. Bitwise AND (`&`)
8. Bitwise XOR / XNOR (`^`, `^~`)
9. Bitwise OR (`|`)
10. Logical AND (`&&`)
11. Logical OR (`||`)
12. Conditional / Ternary (`?:`)

*Industry best practice:* Always use explicit parentheses to avoid ambiguity and subtle evaluation bugs.

---

## 4.6 The Ternary Operator — Hardware Meaning

```verilog
assign out = sel ? a : b;

```

This maps directly to a hardware multiplexer. Nested ternary operators construct multi-input multiplexers (`4:1 mux`, etc.), and synthesis tools directly infer MUX cells from them.

---

## 4.7 Continuous Assignment vs Always Block — The Real Difference

* **Dataflow (`assign`):** Simulator registers a dependency; re-evaluates immediately when inputs change; runs in the continuous assignment region of the event queue.
* **Behavioral (`always`):** Simulator evaluates sensitivity list; schedules the block to run upon trigger; executes procedurally; runs in the active region of the event queue.

---

## 4.8 When to Use Dataflow vs Behavioral

* **Use Dataflow (`assign`) for:** Simple combinational expressions, multiplexers, arithmetic on wires, bus manipulation, and boolean expressions.
* **Use Behavioral (`always`) for:** Sequential logic (flip-flops), complex combinational logic with many conditions, priority encoders, complex case structures, or when intermediate variables are required.

---

## 4.9 Common Misconceptions

* **Misconception 1:** *"assign is faster than always."* (In hardware, both produce identical gates).
* **Misconception 2:** *"Dataflow modeling is only for simple logic."* (Complex systems can be built purely with `assign`, though it sacrifices readability).
* **Misconception 3:** *"assign can only be used outside modules."* (`assign` goes inside the module body but outside procedural blocks).
* **Misconception 4:** *"The delay in assign #10 out = a; means the always block waits 10 units."* (Delays in `assign` are inertial delays in simulation only and are completely ignored by synthesis).

---

## Quiz — Module 4 Solutions

### Q1. What is the result of each:

```verilog
wire [3:0] a = 4'b1010;
wire [3:0] b = 4'b1100;

assign r1 = a & b;    // bitwise
assign r2 = a && b;   // logical
assign r3 = ^a;       // reduction
assign r4 = ~|b;      // reduction

```

* **Answer:**
* `r1` = `4'b1000` (`1010` bitwise AND `1100`)
* `r2` = `1'b1` (both `a` and `b` are non-zero values)
* `r3` = `1'b0` (`1 ^ 0 ^ 1 ^ 0` has an even number of ones, yielding parity 0)
* `r4` = `1'b0` (`|b` is true since `b` is non-zero, inverted via NOR reduction gives `0`)



---

### Q2. Why does this have a bug, and how do you fix it:

```verilog
wire [3:0] a = 4'b1111;
wire [3:0] b = 4'b0001;
wire [3:0] sum;
assign sum = a + b;

```

* **Answer:** This code suffers from a **bit-width overflow bug**. Adding two 4-bit numbers (`15 + 1 = 16`) requires 5 bits to represent accurately. Because `sum` is declared as 4 bits wide, the carry out bit is silently truncated, resulting in `sum = 4'b0000`.
* **Fix:** Increase the bit width of the output wire to 5 bits:
```verilog
wire [4:0] sum;
assign sum = a + b;

```



---

### Q3. What is the difference between `==` and `===`? Which is synthesizable and why?

* **Answer:**
* `==` is logical equality that returns `X` if either operand contains an unknown (`X`) or high-impedance (`Z`) bit.
* `===` is case equality that performs an exact bit-by-bit comparison including `X` and `Z`, returning a definite `0` or `1`.
* **Synthesizability:** Only `==` is synthesizable. `===` is non-synthesizable because `X` and `Z` states do not exist in physical silicon gates.



---

### Q4. Sign-extend an 8-bit signed value to 16-bit using concatenation and replication. Write the assign statement.

* **Answer:**
```verilog
assign extended_value = {{8{signed_in[7]}}, signed_in};

```



---

### Q5. A colleague writes:

```verilog
assign out = a & b | c;

```

**What does this evaluate to by precedence? Rewrite it with explicit parentheses.**

* **Answer:** Due to operator precedence, bitwise AND (`&`) evaluates before bitwise OR (`|`), meaning it evaluates as:
```verilog
assign out = (a & b) | c;

```


* **Explicit rewrite:**
```verilog
assign out = (a & b) | c;

```



---

### Q6. (Hard) Shifts are "free in hardware." But a barrel shifter (shift by variable amount) is NOT free. Explain why shifting by a constant is free but shifting by a variable amount requires logic gates.

* **Answer:**
* **Constant shift:** Shifting by a fixed, static constant (e.g., `a << 2`) requires zero logic gates because the relationship is entirely deterministic at compile time. It is implemented purely through permanent metal routing connections, wiring bit `i` directly to input bit `i+2`.
* **Variable shift (barrel shifter):** Shifting by a dynamic, variable amount (e.g., `a << shift_amt` where `shift_amt` is a signal computed at runtime) means the wiring configuration must change dynamically based on the runtime value of the control inputs. This requires a complex matrix of multiplexers and pass-transistor logic to route any bit position to any target position based on the selection lines, consuming significant area, logic gates, and propagation delay.