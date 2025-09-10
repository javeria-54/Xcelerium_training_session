#  Task 4.1: Linked List Operations in C

##  Problem Statement

Implement a program in C that performs the following operations on a **singly linked list**:

1. Insert a node at the beginning of the list.
2. Delete a node by its value.
3. Print the linked list after each operation.

The program should demonstrate insertion, deletion, and traversal of a dynamic linked list.

---

###  Solution


* Defined a `struct Node` containing `data` and a pointer `next`.
* Wrote functions to insert at the beginning, delete a value, and print the list.
* Tested these functions in `task4_1_linkedlist()` with different cases.

---


#### **1. Struct Definition**

```c
struct Node {
    int data;
    struct Node *next;
};
```

Represents each node in the linked list.

---

#### **2. Insert at Beginning**

```c
struct Node* insert_begin(struct Node *head, int value);
```

* Creates a new node with given `value`.
* Links it before the current head.
* Returns new head.

---

#### **3. Delete by Value**

```c
struct Node* delete_value(struct Node *head, int value);
```

* Searches for the given value.
* Adjusts pointers to remove the node if found.
* Handles case where value does not exist.

---

#### **4. Print List**

```c
void print_list(struct Node *head);
```

* Traverses from head to NULL.
* Prints nodes in order.

---

### Result

```bash
List after insertions: 30 -> 20 -> 10 -> NULL
List after deleting 20: 30 -> 10 -> NULL
List after trying to delete 100: 30 -> 10 -> NULL
```

### How to run the program:
To run my program i use `gcc compiler` and the text editor i use to write my program is `vs code`. By using the following commands program can be run in wsl terminal.

```bash
gcc task_04.c -o task_04 
./task_04
```

### Sources
* https://www.geeksforgeeks.org/c/linked-list-in-c/
* Chatgpt