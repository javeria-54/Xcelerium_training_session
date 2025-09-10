# Arrays and String

### String:
### Problem statement:

* Write a function to reverse a string without using library functions.

### Solution:

I write a program for a length of max 100 characters for user input string. Loop run until its length reahes the null character. The main body of the function have two variables, (start and end) are initialized as first and last charcter of the string. Inside the while loop another loop exists which ensure that the loop increment until it reaches the last character and then start is stored in temporary variable temp then start is stored in end and at last temp is stored in end which is at start initialized as the first character. so now we have end with first character and start with last chahrcter now. This process continues until start becomes greater than or equal to end, meaning all the characters have been swapped and the string is now reversed without using any extra space.  

### Result:
```bash
enter a string: javeria
reversed string: airevaj
```
### Arrays:
### Problem Statement:
* Write a function that scans an integer array and prints the second largest element.

### Solution:

I used the simple logic to find the second highest number in the array for this i compare the consecutive values of arrays and find out the largest and then compare the values of largest with other elements if the number is greater then largest then simply modify largest but if the number is less then largest then it should store in second and for next iterations we can compare both if the number is less then largest and greater then second then it should be second largest.   

### Result:
```bash
enter a size of array
5
enter numbers
1
2
3
4
5
second elemet is 4
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_05.c -o task_05
./task05
```

### Sources:

* http://geeksforgeeks.org/dsa/find-second-largest-element-array/
* Chatgpt
