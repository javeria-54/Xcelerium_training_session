# Number Guessing Game (Bash Script)

##  Problem Statement

1. Write a script that implements a simple guessing game
2. Generate a random number between 1 and 10
3. Use a while loop to allow the user to guess until correct
4. Provide "higher" or "lower" hints

---

##  Solution

The script:

1. Uses `$RANDOM` to generate a number between **1 and 10**.
2. Asks the user to guess the number.
3. Uses a `while true` loop to keep asking until the user guesses correctly.
4. Compares the guess with the actual number and gives hints.
5. Breaks out of the loop when the correct number is guessed.

---

##  Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/javeria/Week_01/lab_03/guess_game$ ./guess_game.sh
guess a number between 1 to 10:
enter your guess: 5
too high!
enter your guess: 3
 correct the number was 3
```
---

##  How to Run

1. Save the script in a file, e.g., `guess.sh`.
2. Give it execute permission:

   ```bash
   chmod +x guess.sh
   ```
3. Run the script:

   ```bash
   ./guess.sh
   ```

---




