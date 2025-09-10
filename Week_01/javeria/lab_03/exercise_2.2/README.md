# Multiplication Table Script (Bash)

##  Problem Statement

1. Create a script that prints the first 10 multiples of a number (provided as an argument)
2. Use a for loop to calculate and print the multiples
3. Test with different numbers

---

##  Solution

The script:

1. Checks if the user provided a command-line argument.
2. If no argument is given, it prints an error and exits.
3. If a number is provided, it uses a `for` loop to multiply the number by values from 1 to 10.
4. Prints each result as the multiplication table.

---

##  How to Run

1. Save the script in a file, e.g., `table.sh`.
2. Give it execute permission:

   ```bash
   chmod +x table.sh
   ```
3. Run the script with a number as an argument:

   ```bash
   ./table.sh 5
   ```

---

##  Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/multiples$ ./multiples.sh 5
 multiple are 5
 multiple are 10
 multiple are 15
 multiple are 20
 multiple are 25
 multiple are 30
 multiple are 35
 multiple are 40
 multiple are 45
 multiple are 50
```

---


