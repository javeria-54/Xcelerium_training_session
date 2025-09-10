# Logical Operations

### Problem Statment
* Write a program that demonstrates:
AND &, OR |, XOR ^, NOT ~, and bit-shifting <<, >>.
* Example: Given x = 5, y = 9, show results of x & y, x | y, etc.

### Solution 
I use switch cases to solve this same approch as the arithmetic operations. i take user input of two numbers and operations from user as a sign which are:
* **AND &**
* **OR |**
* **XOR ^**
* **NOT ~**
* **logical shift left <<**
* **logical shift right >>**

I use `l` and `r` as the sign of logical shift left and logical shift right. sll is shifting number to the left by 1 bit and srl is shifting number to the write by 1.   

### Truth tables:

| **a** | **b** | **AND** | **OR** | **XOR** | **NOT(a)** |
| ----- | ----- | ------- | ------ | ------- | ---------- |
| 0     | 0     | 0       | 0      | 0       | 1          |
| 0     | 1     | 0       | 1      | 1       | 1          |
| 1     | 0     | 0       | 1      | 1       | 0          |
| 1     | 1     | 1       | 1      | 0       | 0          |
-----

### Result:
```bash
enter two integers 1
2
choose op (&, |, ^, ~, r, l): &
result 0

enter two integers5
9
choose op (&, |, ^, ~, r, l): &
result 1

enter two integers 5
9
choose op (&, |, ^, ~, r, l): |
result 13

```
Let verify the results:

Result 1:

* binary format of 1 is 0001
* binary fornamt of 2 is 0010
* so for AND the result must be 0000

Result 2:

* binary format of 1 is 0101
* binary fornamt of 2 is 1001
* so for AND the result must be 0001

Result 3:

* binary format of 1 is 0101
* binary fornamt of 2 is 1001
* so for AND the result must be 1101

### Power of 2

### Problem statement
* Write a function that checks if a number is power of 2 using bitwise operators only.

### Solution
I use this simple algorithm which i get from online sources `(num > 0 && (num & (num - 1)) == 0)` here num is the number i want to verify is the power of 2 or not. if this condition is true then the number is power of 2 otherwise not. and the pricipal of this condition is very simple it takes a number as input then subtracting 1 just flip the bits and after fliping if we take AND with the orignal number then if the number is positive and greater then zero should always gives 0 as output.
```
To verify lets take a number 8
num = 1000
num - 1 = 0111
after AND 0000 
so the umber is power of two
```
```
take another number 7
num = 0111
num - 1 = 0110
AND = 0110
not equal to zero then this number is not a power of 2
```
### Result:
```bash
enter an integer 67       
67 is not a power of 2
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_07.c -o task_07
./task_07
```