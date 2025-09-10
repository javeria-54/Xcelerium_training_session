# Structure
### Problem Statement
* Define a struct Point { int x; int y; };
* Write a program that takes two points and calculates the Euclidean distance between them.

### Solution
I just use simple implementation of struct point and define two variables inside the structure and p1 and p2 are the oject variables for the of type struct point. To find the distance between two points i use the Euclidean distance formula as it is 
$p1(x_1, y_1)$ and $p2(x_2, y_2)$:
$$
d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}
$$
 To implement this formula i use math.h inbuild library of c. pow for power and sqrt for square root of numbers. I use dot notation to access the member of structure.  

### Result 
```bash
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_09$ ./task_09
enter point (x y): 0 0
enter second point (x y): 2 2
euclidean distance = 2.83
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_09$ ./task_09
enter point (x y): 23 56
enter second point (x y): 12 45
euclidean distance = 15.56
javeria_1207@Javeria:/mnt/d/training_session/training_session/Week_01/lab_01/task_09$ ./task_09
enter point (x y): 2 4
enter second point (x y): 1 5
euclidean distance = 1.41
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_09.c -o task_09 -lm
./task_09
```