# Dynamic Memory Allocation and Leak Detection in C

###  Task 5.1 – Dynamic Array, Sum, and Average

### Problem Statement

 Create a dynamic array using `malloc`, take 5 integers as input, calculate their sum and average, then free the memory.


### Solution

* Memory for 5 integers is allocated using `malloc`.
* The user enters 5 integers which are stored in the allocated array.
* A loop calculates the **sum** and **average** of the array elements.
* Memory is released using `free(ptr)` to prevent memory leaks.

### Result
```bash
Enter 5 integers:
1
2
3
4
5
sum of elements in array : 15 
average of elements in array : 3
```


###  Task 5.2 – Extend Array with Realloc

### Problem statement
2. **Task 5.2**: Use `realloc` to extend the size of a previously allocated array. First store 5 elements, then resize the array to store 10 elements, and print both versions.

### Solution

* Initially, memory is allocated for 5 integers using `malloc`.
* After user input, the array is printed.
* The array is extended to 10 integers using `realloc`.
* The user enters 5 more integers, and the full resized array is displayed.
* Finally, memory is freed with `free(ptr)`.

### Result 
```bash
Enter 5 integers:
1
2
3
4
5
Original array: 1 2 3 4 5 
Enter 5 integers:
1
2
3
4
5
Resized array: 1 2 3 4 5 1 2 3 4 5
``` 


###  Task 5.3 – Memory Leak Detector

### Problem statement
3. **Task 5.3**: Implement a simple **memory leak detector** that tracks allocated pointers, ensures proper `free` calls, and reports any unfreed memory at the end.

### Solution

* Custom functions `my_malloc` and `my_free` track allocated pointers inside a global array (`allocated_ptrs`).
* Each allocation is recorded, and each `free` removes the pointer from the list.
* If the program ends and some pointers are not freed, `report_leaks()` prints them.
* In this implementation, freeing an untracked pointer prints a warning.

## Result
```bash
Warning: Tried to free untracked pointer 0x5ce2dd4fbae0
No memory leaks detected!
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_05.c -o task_05 
./task_05
```

### Sources
* https://www.geeksforgeeks.org/c/dynamic-memory-allocation-in-c-using-malloc-calloc-free-and-realloc/
* Chatgpt
