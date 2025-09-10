#  Command-line Arguments

##  Problem Statement

Create a script that accepts two numbers as command-line arguments
Calculate and print the sum of these numbers
Run the script with different number pairs

---

##  Solution

The script:

1. Uses `echo` to ask the user to enter two numbers.
2. Uses `read` to store the numbers in variables `X` and `Y`.
3. Performs addition using `SUM=$((X + Y))`.
4. Prints the sum using `echo`.

---

##  How to Run

1. Save the script in a file, e.g., `sum.sh`.
2. Give it execute permission:

   ```bash
   chmod +x sum.sh
   ```
3. Run the script:

   ```bash
   ./sum.sh
   ```

---

##  Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/sum$ ./sum.sh
enter two numbers   
45
67
Sum: 112
```
---


