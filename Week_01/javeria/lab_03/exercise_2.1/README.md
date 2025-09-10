# If_Else Statement 

##  Problem Statement

1. Write a script that checks if a number (provided as an argument) is even or odd
2. Use an if-else statement to print the result
3. Test with various numbers

---

##  Solution

The script:

1. Checks if the user has passed a command-line argument.
2. If no argument is given, it shows an error and exits.
3. If a number is provided, it calculates `number % 2`.

   * If the remainder is `0`, the number is **even**.
   * Otherwise, it is **odd**.

---
###  Output:

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh
provide a number as an argument
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 4
4 is even
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 5
5 is odd
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 7
7 is odd
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 9
9 is odd
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 914
914 is even
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/if_else$ ./even.sh 35
35 is odd
```
---

##  How to Run

1. Save the script in a file, e.g., `evenodd.sh`.

2. Give it execute permission:

   ```bash
   chmod +x evenodd.sh
   ```

3. Run the script with a number as an argument:

   ```bash
   ./evenodd.sh 10
   ```

