# Setting and Clearing bits

### Problem Statement

* Write an assembly program for setting or clearing any bit in a 32-bit number in RISC-V assembly language.
* Write a C code for the same purpose.
* Use the toolchain to build the assembly file from your C file. 
* Compare the two assembly files. Which is more optimized? 
* Run both on spike and see their working.

###  Solution Approach

1. **Input Handling**

   * Read a 32-bit unsigned integer (`num`).
   * Read a bit position (`pos`, range 0–31).
   * Read user’s choice (`choice`: 1 = set bit, 0 = clear bit).

2. **Validation**

   * If `pos` is outside 0–31, print an error and exit.

3. **Bit Manipulation**

   * **Set Bit**: Use bitwise OR with a mask → `num | (1U << pos)`
   * **Clear Bit**: Use bitwise AND with inverted mask → `num & ~(1U << pos)`

4. **Output**

   * Print the modified number after the operation.
   * Handle invalid `choice` input with an error message.

##  How to Run on Spike

For c code:

```bash
gcc set_clear.c -o set_clear
./ set_clear
```

For assembly file: 

1. Save the program as `set_clear.s`.
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


