# Log Analysis Script

## Problem Statement
1. Create a log file with entries of the format: "YYYY-MM-DD username action"
2. Write a script that:
   a. Counts the total number of entries
   b. Lists unique usernames
   c. Counts actions per user
---

### Solution

I implemented a Bash script (`log_analysis.sh`) that processes a file named `log.txt`.

1. **Total entries:** Uses `wc -l` to count all lines in the file.
2. **Unique usernames:** Uses `awk` to extract the second column, then `sort` and `uniq` to remove duplicates.
3. **Actions per user:** Counts how many times each user appears in the logs.

### Result:

```bash
Log Analysis
Total entries: 6

Unique usernames:
abdul
ghazia
javeria
saad

Actions per user:
abdul: 1
ghazia: 1
javeria: 3
saad: 1
```
---

## How to Run

1. Save the script as `log_analysis.sh`.
2. Give it execute permission:

   ```bash
   chmod +x log_analysis.sh
   ```
3. Run the script (make sure `log.txt` is in the same directory):

   ```bash
   ./log_analysis.sh
   ```

---

### Sources
* 
* Chatgpt

