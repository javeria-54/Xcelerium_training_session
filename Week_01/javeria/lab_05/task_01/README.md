#  Restoring_division 

##  Problem Statement

* Write an assembly program for restoring division algorithm in RISC-V assembly language.
* Use the toolchain to build the assembly file from your C file. 
* Compare the two assembly files. Which is more optimized? 
* Run both on spike and see their working.

---

##  Solution

The program implements the **restoring division algorithm** step by step:

1. **Sign Handling**:

   * Determines the final sign of the quotient using XOR of dividend and divisor.
   * Works with unsigned (absolute) values of dividend and divisor during calculation.

2. **Bitwise Division Loop**:

   * Iterates from the most significant bit (MSB) to the least significant bit (LSB).
   * Shifts remainder left, brings down the next bit from dividend.
   * Subtracts divisor and checks if result is negative.

     * If negative → restore remainder and append `0` to quotient.
     * If non-negative → keep remainder and append `1` to quotient.

3. **Final Adjustments**:

   * Applies the correct sign to the quotient.
   * Ensures remainder also carries the correct sign.

4. **Output**:
   Prints the dividend, divisor, quotient, and remainder.

---

##  How to Run on Spike

For c code:

```bash
gcc restoring_division.c -o restoring_division
./ restoring_division
```

For assembly file: 

1. Save the program as `restoring_division.s`.
2. Assemble and link:

   ```bash
   make
   ```
3. Run with Spike:

   ```bash
   make run 
   make debug
   ```


---

