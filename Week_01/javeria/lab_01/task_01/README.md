#  Basic Syntax and Datatype in C

### Problem Statement
The first task of the module is to declare some datatypes used in c and then print the values and sizes for all datatypes and the last task is to typecasting between these datatypes. 

### Step 1
In the first problem i declare some datatypes in my program which include 

* **int**, 
* **float**, 
* **double** 
* **char**

I assigned some values to each of them and then i print its size and values using simple `printf` and `sizeof` operator. 

### Step 2
The last problem of task is typecasting. Typecasting in C is the process to convert one datatype to other such as conversion of int to float and vice verse. There are two types of typecasting implicit and explicit. 

* **Implicit typecasting** autometically done by compiler.
* **Explicit Typecasting** done manually by programmer.

In this program i use explicit typecasting to convert one datatype to other. For this i use another variable of the type i want to convert my previous variable. and then simply assign it to the newly declare varible and then see the values of both variables.

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task1.c -o task1
./task1
```

### Results:
```bash
size of int: 4 bytes
size of float: 4 bytes        
size of double: 8 bytes       
size of char: 1 bytes
original values:
age = 21
pie = 3.140000
precise pi = 3.141593
grade = A

Casting float pi=3.14 to int 3
Casting int age=21 to float 21.00
Casting double precise_pi=3.14159 to int 3
Casting char grade='A' to int asci 65
Casting int 66 to char B
```

### Sources:
* https://www.geeksforgeeks.org/c/c-typecasting/
* Slides of day_01 
---
