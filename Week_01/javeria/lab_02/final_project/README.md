# Booth’s Multiplication Algorithm (C Implementation)

## Problem Statement

Write C code to implement Booth's multiplication algorithm. Write different functions for shifting and adding so that you can later visualize functions call stack.
* The function should take two signed integers as input and return their product.
* Use bit manipulation operators for efficient multiplication.
* Write a test function to verify the correctness of your Booth multiplier function.
* Create test cases for various scenarios, including positive, negative, zero inputs, multiplication by zero, multiplication by 1, and edge cases (e.g., overflow).

---

### Solution

### Approach

1. **Registers Used**

   * `A`: Accumulator (initialized to 0).
   * `Q`: Multiplier.
   * `M`: Multiplicand.
   * `Q-1`: Extra bit to track Booth’s condition.

2. **Booth’s Decision Rules**

   * If `(Q0 = 1, Q-1 = 0)` → Perform `A = A - M`.
   * If `(Q0 = 0, Q-1 = 1)` → Perform `A = A + M`.
   * Otherwise, do nothing.
   * Then perform **arithmetic right shift** on `[A, Q, Q-1]`.

3. **Implementation Details**

   * The function `add()` executes the add/subtract operation and performs the right shift.
   * The function `booth_multiply()` runs the algorithm for 8 iterations (8-bit multiplier).
   * The final product is combined from `A` and `Q`.
   * Results are stored as 16-bit signed integers.

4. **Testing**

   * `test_booth()` checks the algorithm with different pairs:

     * Positive × Negative
     * Negative × Zero
     * Positive × Positive
     * Negative × Negative
     * Large values 

---


### Result

```bash
13 x -3 = -39
-7 x 0 = 0
25 x 4 = 100
-27 x -8 = 216
-67 x 56 = -3752
259 x 4 = 12
-257 x -4 = 4
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc booth.c -o booth 
./booth
```

### Sources
* https://www.youtube.com/watch?v=cWfaw7b3jKY
* https://vlsiverify.com/verilog/verilog-codes/booth-multiplier/
* https://github.com/nikhil7d/8bitBoothMultiplier

