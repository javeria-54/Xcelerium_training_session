# Functions

### Problem Statement

* Write a function `isPrime(int n)` that returns 1 if n is prime, otherwise 0.
* Use it to print all prime numbers between 1–100.
* Write a recursive function `factorial(int n)` that calculates factorial.

### Solution:

### Step 1:

Prime numbers are the numbers which are not divisible by any other number. For this, I created a loop with `i` iterations where `i` starts from 2 and goes up to less than the number we want to check.
`isPrime` is the main function which determines whether the number is prime or not. This function returns **0** if the given number is not prime and **1** if the number is prime.

### Step 2:

The second function is responsible for selecting numbers between 1 to 100 and calling the `isPrime` function to check whether each number is prime or not.

### Step 3:

Factorial is the product of all positive integers less than or equal to a given non-negative integer. For this, I used a **recursive function** (a recursive function is one that calls itself inside its definition).
The base case for this function is 0 and 1. The function repeatedly calls itself until it reaches the base case and calculates the product of the number, returning it to the function.

### Result:

```bash
prime numbers between 1 and 100:
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

### Result:

```bash
Factorial of 5 = 120
```

### How to run the program:

To run my program, I used the `gcc compiler` and the text editor I used is **VS Code**. By using the following commands, the program can be run in the WSL terminal:

```bash
gcc task_04.c -o task_04
./task_04
```

### Sources:

* [https://www.geeksforgeeks.org/c/c-program-for-factorial-of-a-number/](https://www.geeksforgeeks.org/c/c-program-for-factorial-of-a-number/)

---

