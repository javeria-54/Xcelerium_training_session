# Control Structures

## Fibonacci Sequence:

### Problem statement:
My task is to print first n terms in the fibonacci sequence.  As we know that Fibonacci sequence is a series of numbers where each number is the sum of the two preceding ones, typically starting with 0 and 1.

### Solution:

I initialize first two terms of the sequence as `0` and `1` and then equate their sum as the next term of the sequence. Then use a for loop to find the next terms of the sequence as the sum of first two terms is now the third term and by adding third with second term i can get the fourth term as the next term or so on. This program can find the number of terms upto n value and n is actully a user input. 


### Results:

```bash
enter number of terms 10
fibonacci series: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34,
```
## Guess game:

### Problem Statement:

* Program generates a random number between 1–100.
* User repeatedly guesses until correct.
* Program responds with "Too High" or "Too Low" hints.

### Solution:

### Step 1:
I generate a random number between 1 to 100 using this `rand` in build function and then taking its modules as an secret number actully `rand` is generating any number but by taking its modulus with 100 it gives me the remainder which must be between 0 to 99 and by adding it with 1 it should give me a max number 100 

### Step 2:
I use `srand(time(0))` to generate a unique random number between 1 - 100 every time when i run this program.

### Step 3:
I use conditional statements inside the while loop to run this code until user guess the correct number. if the number guessed by the user is less then the secret_number it will return the guess `too low` as a hint for the user and if the user input is too high as compare to number then it print `too high` and keep on going until the user guess the correct input.   

### Results:
```bash
guess the number between 1 and 100
enter your guess: 23
too low 
enter your guess: 45
too low 
enter your guess: 56
too low 
enter your guess: 78
too low 
enter your guess: 98
too high 
enter your guess: 85
too high
enter your guess: 83
correct you guessed the number
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_03.c -o task_03
./task03
```

### Sources:

* https://www.geeksforgeeks.org/dsa/fibonacci-series/
