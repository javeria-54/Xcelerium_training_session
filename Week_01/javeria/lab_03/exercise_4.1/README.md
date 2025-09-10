# File reading

##  Problem Statement

1. Create a text file with several lines of content
2. Write a script that reads this file line by line
3. Print each line prefixed with its line number
---

##  Solution

The script:

1. Sets the filename to `file.txt`.
2. Initializes a line counter `lineno` to 1.
3. Uses a `while read` loop to read the file line by line.
4. Prints each line prefixed with its line number.
5. Increments the line number after each line.

---
##  How to Run

1. Create a file named `file.txt` and add some text lines.
2. Save the script in a file, e.g., `linenumber.sh`.
3. Give it execute permission:

   ```bash
   chmod +x linenumber.sh
   ```
4. Run the script:

   ```bash
   ./linenumber.sh
   ```

---

##  Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/read_file$ ./read_file.sh
1: Hello its me javeria.
2: Basically we are learning shell scripting in this lab.
3: I am making a text file today for which i am writting this script.
4: Today is wednesday 20 aug 2025.
5: I am in happy today.
```

---


