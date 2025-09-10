#  Macros and File I/O in C

This module demonstrates:

1. Using **macros** for common operations.
2. Managing **student records** using structures and performing **file I/O** (write/read data from a file).

---

##  Task 3.1:
### Macros in C

### Problem Statement

Write macros for:
* SQUARE(x)
* MAX(a,b)
* MAX(a,b,c)
* MAX(a,b,c,d)
* TO_UPPER(c) (convert char to uppercase if lowercase).
Demonstrate with test cases.

### Solution

* Use `#define` preprocessor directives to create reusable macros.s
* Test them with sample values inside a function.

---
### Result 
```bash
SQUARE(5) = 25
MAX2(10, 20) = 20
MAX3(3, 7, 5) = 7
MAX4(1, 2, 3, 4) = 4
TO_UPPER('a') = A
```

##  Task 3.2
### File I/O with Structures

### Problem Statement

Write a program that:
* Define a struct Student { char name[50]; int roll; float gpa; };
* Store details of 5 students in an array.
* Print the student with the highest GPA.
* Saves them to a text file (students.txt).
* Reads them back and prints.

### Solution
* I used the same approch as used in previous lab to open and close the file and read and write from the file or in the file.
* Define a structure `Student` with fields: `name`, `roll`, `gpa`. 
* Use an array of 5 students.
* Find the student with the highest GPA using a loop.
* Write student data to file using `fprintf`.
* Read data back using `fscanf` and print. 
---
### Results

```bash
Enter details of 5 students:
Student 1 name: Saima
Student 1 roll: 01  
Student 1 GPA: 3.7
Student 2 name: Humna
Student 2 roll: 05
Student 2 GPA: 3.4
Student 3 name: Zahra
Student 3 roll: 51
Student 3 GPA: 3.5
Student 4 name: Laiba 
Student 4 roll: 07
Student 4 GPA: 3.2
Student 5 name: Areeba
Student 5 roll: 56
Student 5 GPA: 2.7

Top student: Saima (Roll: 1) with GPA 3.70

Data saved to students.txt

Reading back from file:
Name: Saima, Roll: 1, GPA: 3.70
Name: Humna, Roll: 5, GPA: 3.40
Name: Zahra, Roll: 51, GPA: 3.50
Name: Laiba, Roll: 7, GPA: 3.20
Name: Areeba, Roll: 56, GPA: 2.70
```

 ### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_03.c -o task_03 
./task_03
```

### Sources
* https://www.geeksforgeeks.org/c/basics-file-handling-c/
* https://www.geeksforgeeks.org/c/macros-and-its-types-in-c-cpp/
* Lecture notes of day_02
* Chatgpt