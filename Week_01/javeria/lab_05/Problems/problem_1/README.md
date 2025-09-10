# Absolute Difference (RISC-V Assembly)

##  Problem Statement

Implement a program to calculate the absolute difference between two numbers.

---

##  Solution

1. **Initialization**

   * Load `t1 = 15` and `t2 = 27`.

2. **Subtraction**

   * Compute `t3 = t1 - t2`.

3. **Check sign**

   * If `t3 < 0`, negate it to make it positive.

4. **Store result**

   * Move the result into `a0` (conventionally used for function return values).

5. **Exit for Spike**

   * Uses `tohost` to signal program completion.

---

##  How to Run on Spike

1. Save the file as `difference.S`.
2. Assemble and link:

   ```bash
   make
   ```
3. Run with Spike:

   ```bash
   make run 
   make debug
   ```
4. The result will be stored in **`a0`**.

---

##  Example Execution

* If `t1 = 15` and `t2 = 27`, then

  $$
  |15 - 27| = 12
  $$

The result should be stored in register `a0`.

* Input: `t1 = 15`, `t2 = 27`
* Subtraction: `15 - 27 = -12`
* Negated to absolute: `12`
* Final result:

  ```
  a0 = 12
  ```

---
