# Array Reversal (RISC-V Assembly)

##  Problem Statement

We need to write a **RISC-V assembly program** that reverses the contents of an array in memory.

---

##  Solution

1. **Initialization**

   * `t0` ← base address of the array.
   * `t1` ← size of the array.
   * `t2` ← `i = 0` (start index).
   * `t3` ← `j = size - 1` (end index).

2. **Loop**

   * Continue while `i < j`.
   * Compute addresses of `array[i]` and `array[j]`.
   * Swap the two elements.
   * Increment `i` and decrement `j`.

3. **End**

   * When `i >= j`, exit the loop.
   * End program using **Spike `tohost` convention**.

---


##  How to Run on Spike

1. Save the program as `reverse.S`.
2. Assemble and link:

   ```bash
   make
   ```
3. Run with Spike:

   ```bash
   make run 
   make debug
   ```
4. After execution, the `array` in memory will be reversed.

---

##  Example Execution

* Initial array in memory:

  ```
  [1, 2, 3, 4, 5]
  ```
* After reversal:

  ```
  [5, 4, 3, 2, 1]
  ```

---


