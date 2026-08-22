# DAY 3 — SESSION 4: Advanced Counters

## Theoretical Extensions Over Basic Counter
A "basic" counter only increments[cite: 1]. Real-world counters typically need some combination of:
* **Directionality (up/down):** controlled by a mux-like conditional choosing between increment and decrement each cycle[cite: 1].
* **Parallel load:** ability to jump directly to an arbitrary starting value, essential for use cases like timers with a programmable duration[cite: 1].
* **Enable:** ability to pause counting without losing the current value (distinct from reset, which destroys the value)[cite: 1].
* **Modulo-N (arbitrary wraparound point):** needed whenever the natural binary wraparound (power-of-2) doesn't match the desired counting range (e.g., counting 0–9 for a decimal digit, or 0–11 for a 12-hour clock)[cite: 1].

## Modulo-N Theory
For power-of-2-width counters counting through their entire range, wraparound happens "for free" due to fixed-width binary overflow[cite: 1]. But for arbitrary limits (not a clean power of 2), you must explicitly detect the boundary condition (`if (count == LIMIT-1)`) and force wraparound (`count <= 0`) rather than relying on natural overflow[cite: 1]. This is a fundamentally different mechanism from simple binary overflow, even though the visible behavior (wrapping) looks similar[cite: 1].

## `$clog2` Function — Theoretical Purpose
This function computes the minimum number of bits required to represent a given number of distinct values[cite: 1]. It exists to let you parameterize bit-width based on a range requirement (e.g., "I need to count from 0 to N-1") rather than manually calculating and hardcoding a width[cite: 1]. This distinguishes it conceptually from a plain width parameter (`WIDTH`) — one directly specifies bit-count, the other derives bit-count from a range requirement[cite: 1].

## Priority Structure Theory (General Pattern Across All Advanced Counters)
The consistent priority order used throughout is:
> `Reset (highest) > Load > Enable-gated operation > implicit Hold (lowest)`[cite: 1]

This ordering reflects real-world urgency: a reset must override everything (safety), an explicit load request is a deliberate override of normal counting, enable gates whether normal counting proceeds, and if none of these apply, the value simply persists[cite: 1]. This exact priority pattern recurs throughout sequential digital design — it's a general reusable mental template, not something unique to counters[cite: 1].

## Design Approach for Advanced/Combined-Feature Counters
1. List every required feature (direction? load? enable? custom modulo?)[cite: 1].
2. Establish priority order using the standard template above[cite: 1].
3. Within the "enabled counting" branch, nest the direction logic (if up/down needed), and within each direction branch, apply the modulo-wraparound check appropriate to that direction (up wraps at max→0, down wraps at 0→max)[cite: 1].
4. Add defensive coding where appropriate (e.g., bounds-checking a loaded value against the valid range) — this isn't strictly required by the spec but improves robustness[cite: 1].
5. **Testbench:** test each feature in isolation first (pure counting, pure hold, pure load) before testing combinations, and specifically construct a test that drives the counter to its wraparound boundary to visually confirm correct wrap behavior in both directions if applicable[cite: 1].
