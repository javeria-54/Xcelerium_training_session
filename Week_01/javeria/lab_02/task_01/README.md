#  Pointer Tasks in C

This module demonstrates the use of pointers in C through three small tasks:

1. Basic pointer usage
2. Swapping two integers using pointers
3. Pointer arithmetic and array manipulation

---

##  Task 1.1: Basic Pointer Usage

### Problem Statement

Create a program that demonstrates basic pointer usage:
* Declare an integer variable and a pointer to it
* Print the value of the variable using both direct access and the pointer
* Modify the value using the pointer and print the new value


### Solution

* I declare `int x = 21;` and `int *ptr = &x;`.
* Use `*ptr` to access the value stored at the address of `x`.
* Print addresses with `%p`.
* Modify `*ptr = 14;` to update the value of `x` indirectly.

---
### Results

```bash
value of x: 21
value pointed by ptr: 21
address of x: 0x7ffe80c92cac
address of ptr: 0x7ffe80c92cb0

new value of x: 14
value pointed by ptr: 14
address of x: 0x7ffe80c92cac
address of ptr: 0x7ffe80c92cb0
```

##  Task 1.2: Swap Two Integers Using Pointers

### Problem Statement

* Implement a function that swaps two integers using pointers

### Solution

* Function signature: `void swap(int *a, int *b)`
* Use a temporary variable:

  ```c
  int swap = *a;
  *a = *b;
  *b = swap;
  ```
* The function is called as `swap(&a, &b);` in `main()`.
---

### Results

```bash
the value of a 5 and b 10
the value of a 10 and b is 5

```

##  Task 1.3: Pointer Arithmetic on Array

### Problem Statement

Create an array of integers and use pointer arithmetic to:
* Print all elements of the array
* Calculate the sum of all elements
* Reverse the array in-place


### Solution

* Array declaration: `int numbers[5] = {1, 2, 3, 4, 5};`
* Use `*(ptr + i)` or `ptr[i]` to traverse elements.
* Accumulate sum using a loop.
* Reverse the array by swapping elements at `start` and `end` indices.

---
### Results
```bash
 1
 2
 3
 4
 5

sum is 15

 5
 4
 3
 2
 1
 ```

 ### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_01.c -o task_01 
./task_01
```

### Sources

* https://beginnersbook.com/2019/02/c-program-to-swap-two-numbers-using-pointers/ 
* Chatgpt for formating 
* Lecture slides of day_02 