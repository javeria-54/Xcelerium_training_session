# Operator and Expressions

### Problem Statement:

* Write a program that takes two integers as input.
* Perform all arithmetic operations: +, -, *, /, %.
* Extend into a simple calculator using switch statement:
* User chooses the operation symbol (+ - * / %)
* The program executes the selected operation.


### Solution :

This program takes user input for the `operation` and `numbers` using `printf` and `scanf`.

A **switch-case** structure is used to select the operation by its symbol and perform the calculation.

## Supported Operations

* Addition
* Subtraction
* Multiplication
* Division
* Modulus

Works with signed numbers
Handles division by zero by displaying an error message

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task02.c -o task02
./task02
```

### Results:
```bash
Enter two integers: 255
7
Choose operation (+ - * / %): *
result: 1785
```
User can choose any number and any opeartion from the list and run it for its own inputs. 

### Sources:
* I used lecture notes of day_01.
* Idea to deal division with zero in this program is given by `Chatgpt`  

 