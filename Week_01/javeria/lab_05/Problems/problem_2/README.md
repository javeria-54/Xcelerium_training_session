# Bit Counter (RISC-V Assembly)

##  Problem Statement

* Implement a function to count the number of set bits in a 32-bit word. 

---

##  Solution

The program works as follows:

1. **Initialization**

   * `t0` ← `0xF0F0F0F0` (the number whose bits we want to count).
   * `t1` ← `0` (will hold the count of set bits).
   * `t2` ← `32` (loop counter, since we are checking 32 bits).

2. **Loop (`count_bits`)**

   * `andi t3, t0, 1` → isolate the least significant bit (LSB).
   * `add t1, t1, t3` → if LSB = 1, increment count.
   * `srli t0, t0, 1` → shift number right by 1 (move to next bit).
   * `addi t2, t2, -1` → decrement loop counter.
   * `bnez t2, count_bits` → repeat until all 32 bits are checked.

3. **Exit**

   * Uses Spike’s convention (`tohost`) to terminate.

---

##  How to Run on Spike

1. Save the program as `bit.s`.
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
4. The result (number of set bits) will be stored in **register `t1`** at the end of execution.

---

##  Example

For `0xF0F0F0F0` (binary: `11110000 11110000 11110000 11110000`):

* There are **16 ones**.
* So after execution:

  ```
  t1 = 16
  ```
---


