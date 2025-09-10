#  Custom String Functions in C

This module demonstrates how to implement standard string operations manually using pointers, as well as a simple palindrome checker.

---

##  Task 2.1: 
### Implement `strlen` Using Pointers

### Problem Statement

Write a function `my_strlen` that calculates the length of a string without using the built-in `strlen` function.

### Solution

* Start with a pointer `p = s`.
* Traverse the string until the null terminator `'\0'`.
* Return the difference `p - s`.
---

###  Implement `strcpy` Using Pointers

### Problem Statement

Write a function `my_strcpy` that copies a source string into a destination string using pointers.

### Solution

* Iterate through `src` until `'\0'` is reached.
* Copy each character into `dest`.
* Append the null terminator at the end.
---

###  Implement `strcmp` Using Pointers

### Problem Statement

Write a function `my_strcmp` that compares two strings character by character, similar to the built-in `strcmp`.

### Solution

* Traverse both strings together.
* If characters differ, return the difference.
* If both reach `'\0'`, return 0 (strings are equal).
---

### Results
```bash
Len = 5
Copied: World

```

## Task 2.2
###  Palindrome Checker

### Problem Statement

Write a function `is_palindrome` that checks if a string is a palindrome (same forward and backward).

### Solution

* Use two pointers:
  * `s` at the start of the string
  * `end` at the last character
* Compare characters while moving inward.
* If mismatch occurs, return **not a palindrome**.
* If all characters match, return **palindrome**.

### Results

```bash
Palindrome? Yes
```
 ### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_02.c -o task_02 
./task_02
```

### Sources

* https://www.programiz.com/c-programming/library-function/string.h/strlen
* https://www.programiz.com/c-programming/library-function/string.h/strcpy
* https://www.programiz.com/c-programming/library-function/string.h/strcmp
* Chatgpt 


