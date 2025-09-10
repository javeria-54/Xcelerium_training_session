##  Problem Statement

* Write an assembly program for non-restoring 32-bit unsigned division in RISC-V assembly language.
* Write a C code for the same purpose.
* Use the toolchain to build the assembly file from your C file. 
* Compare the two assembly files. Which is more optimized? 

---

##  Solution

The program:

1. **Handles signs** of dividend and divisor, works with their absolute values, and applies the correct sign at the end.
2. **Non-Restoring Division Algorithm**:

   * Iterates through bits from MSB to LSB.
   * Shifts remainder left and brings down the next bit of the dividend.
   * Subtracts divisor if remainder ≥ 0, otherwise adds divisor.
   * Updates quotient bits depending on the sign of remainder.
3. After the loop, if the remainder is negative, it is corrected by adding the divisor.
4. Finally, adjusts signs of quotient and remainder and prints the result.

##  How to Run on Spike

For c code:

```bash
gcc non_restoring_division.c -o non_restoring_division
./ non_restoring_division
```

For assembly file: 

1. Save the program as `non_restoring_division.s`.
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


