# Enumeration

### Problem Statement

* Define an enum `Weekday { MON, TUE, WED, THU, FRI, SAT, SUN };`
* Write a program that takes a number (1–7) as input and prints the corresponding weekday.

### Solution

First, I defined enums for all weekdays and assigned values starting from 1, because by default enum values start from 0 and increase by 1. Since the requirement of my program was to start from 1, I explicitly set the first value to 1 and continued sequentially.

After that, I declared two variables: `day` and `num`. Here, `num` is the user input. When the user enters a number, the corresponding weekday is shown as output. This mapping works because the enum associates each integer with a specific weekday.

### Result

```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_08$ ./task_08
enter number 1-7 5
Friday
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_08$ ./task_08
enter number 1-7 6   
Saturday
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_08$ ./task_08
enter number 1-7 8
invalid number
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_08$ ./task_08
enter number 1-7 2
Tuesday
```

### How to run the program

To run my program, I used the **GCC compiler** and wrote the code in **VS Code**. The program can be executed in the WSL terminal using the following commands:

```bash
gcc task_08.c -o task_08
./task_08
```

---


