# Factorial Calculator (Bash Script)

##  Problem Statement

1. Create a function that calculates the factorial of a number
2. Call this function with different numbers in your script
3. Print the results

###  Solution

Factorial 
$$
n! = n \times (n-1) \times (n-2) \times ... \times 1
$$

Example:

* $5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$


The script:

1. Checks if the user provided a number as an argument.
2. If no argument is given, it shows an error and exits.
3. Defines a function `factorial()` that:

   * Starts with `fact=1`.
   * Uses a `for` loop to multiply numbers from 1 up to `num`.
   * Prints the factorial result.
4. Calls the function with the given number.
---

###  How to Run

1. Save the script in a file, e.g., `factorial.sh`.

2. Give it execute permission:

   ```bash
   chmod +x factorial.sh
   ```

3. Run the script with a number as an argument:

   ```bash
   ./factorial.sh 5
   ```

### Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh
Error: provide a number as an argument
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh 6
Factorial of 6 is: 720
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh 2
Factorial of 2 is: 2
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh 4
Factorial of 4 is: 24
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh 8
Factorial of 8 is: 40320
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/factorial$ ./factorial.sh 3
Factorial of 3 is: 6
```


