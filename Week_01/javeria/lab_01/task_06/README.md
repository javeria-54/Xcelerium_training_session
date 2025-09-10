# File I/O Basics

### Problem Statement
Write a program that:
* Reads 5 integers from the user and stores them in a file (numbers.txt).
* Reads back the integers from the file and prints them on the console.

### Solution
For this problem i write a program that take five numbers as input from a user and  store them in a file name as `number.txt` . I create a file pointer using `FILE *file` and write the numbers in it using `w` and read the written content using `r` as w states write and read is denoted with r. `fprintf` is used to print somthing in file. `fopen` and `fclose` is used to open and close the file for read and write operations. I added some statements to exit the program in case of unable to read and write from the respective file or in case of reading empty file. Everytime i run this program my file number.txt overwrites if i use write in file. 

### Result

```bash
enter 5 numbers 
23
45
76
98
12
number reading from file 
23
45
76
98
12
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_06.c -o task_06
./task06
```

### Sources:
* I use chatgpt to see how can i write and read in a file.
* https://www.geeksforgeeks.org/c/basics-file-handling-c/
