##  Problem Statement

Write a RISC-V assembly program to **sort an array of integers in ascending order** using the **Bubble Sort algorithm**.

---

##  Solution

The program:

1. Defines an array of integers and its size in the `.data` section.
2. Uses **nested loops** (outer and inner) to repeatedly compare adjacent elements.
3. **Swaps elements** if they are out of order.
4. Continues until the entire array is sorted.
5. Exits properly for the Spike simulator using the `.tohost` mechanism.

##  How to Run on Spike

1. Save the program as `sort_array.S`.
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
