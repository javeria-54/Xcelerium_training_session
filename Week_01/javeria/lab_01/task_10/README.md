# Command Line Argument

### Problem statement
* Write a program that accepts two integers from the command line and prints their sum.

### Solution
Command line arguments are the values that pass to the program when you run it from the terminal/command prompt. In its basic structure `argc` Argument count and `argv` Argument vector in the function. `argc` it tells us about the number of argument pass in the function and `argv` is the array of character pointers holding each arguments. At start we check how many arguments are passed by the user if it is not 3 then the program just immediately exits the program. Then i use `atoi` it just act as typecasting as it conert string into number. and then num 1 is assign to it same for the next number then add both of those number and the last step is to display the sum using the `printf` statement. 

### Result
```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_10$ ./task_10 23 45
The sum of 23 and 45 is 68
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_10$ ./task_10 123 43
The sum of 123 and 43 is 166
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_10$ ./task_10 234 26
The sum of 234 and 26 is 260
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_10$ ./task_10 5 7
The sum of 5 and 7 is 12
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_10.c -o task_10 
./task_10 <argc1> <argc2>
```

### Refrence
* https://www.geeksforgeeks.org/cpp/command-line-arguments-in-c-cpp/
* information about `atoi` is taken from AI tools. 