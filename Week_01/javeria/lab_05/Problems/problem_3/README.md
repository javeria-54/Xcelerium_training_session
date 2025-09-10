# Factorial Calculation (RISC-V Assembly)

##  Problem Statement

We need to write a **RISC-V assembly program** that computes the **factorial** of a number.

---

##  Solution

1. **Initialization**

   * `t1 = 1` → loop counter (starts at 1).
   * `t2 = 5` → number for factorial (can be changed).
   * `t3 = 1` → result storage (accumulates factorial).

2. **Loop (`loop`)**

   * Multiply result (`t3 = t3 * t1`).
   * Increment counter (`t1 = t1 + 1`).
   * Check if counter ≤ target number (`t1 ≤ t2`). If true, repeat.

3. **Result**

   * Store final result in `a0`.

4. **Exit**

   * Uses Spike `tohost` convention.
---

##  How to Run on Spike

1. Save as `factorial.S`.
2. Assemble and link:

   ```bash
   make
   ```
3. Run with Spike:

   ```bash
   make run 
   make debug
   ```
   ```
4. Final result will be stored in **`a0`**.

---

### Example
Factorial is defined as:

$$
n! = n \times (n-1) \times (n-2) \times \dots \times 1
$$

Example:

* $5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$

