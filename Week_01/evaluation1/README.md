# Evaluation-1: Productivity Tools and C Language

Welcome to **Evaluation-1** 
This repository contains the starter files and structure for your first evaluation.  
You will demonstrate your understanding of **C programming, Bash scripting, Makefile, Git workflow, and RISC-V assembly (Spike)**.

---

## Basic Instructions
- **Time Limit:** 3 hours  
- Work individually. Collaboration is **not allowed**.  
- You must complete the tasks in this repository and push your work to your fork.  
- After finishing, create a **Pull Request** to the original repo everything stored in a folder with your name.  
- You may use manuals, documentation, and your own notes.  
- Internet is allowed **only for standard docs/libraries**.  
- Do not use AI assistants (ChatGPT, Copilot, etc.) or copy code from external sources.  

---

## 📁 Repository Structure
```

├── bitops.c        # C program for Task-1 (bit manipulation)
├── fib.s           # RISC-V assembly program for Task-2 (Fibonacci)
├── run\_tests.sh    # Bash test harness for Task-1
├── Makefile        # Build & test automation
└── README.md       # Instructions (this file)

````

---

## Tasks

### **Task-1: Bit Manipulation Utility (C + Bash + Makefile + Git)**

Implement and extend `bitops.c` to support the following operations on **32-bit unsigned integers**:

1. Count number of set bits (`1s`)  
2. Reverse all bits  
3. Check if the number is a power of two  
4. Set a specific bit (at position `k`)  
5. Clear a specific bit (at position `k`)  
6. Toggle a specific bit (at position `k`)  
7. Extract a range of bits `[m:n]`  
8. Perform **logical AND / OR** between two numbers  

⚡ **Note:** Use **optimized bitwise logic** (`&`, `|`, `^`, `~`, `<<`, `>>`) instead of brute-force loops.  

#### Bash Test Harness (`run_tests.sh`)
- Generate test inputs (normal + edge cases: `0`, `UINT32_MAX`, powers of 2, alternating patterns).  
- Run the program with these inputs.  
- Compare outputs with expected results.  
- Print a **summary report** (Passed/Failed).  

#### Makefile
- `make build` → Compile the C program  
- `make test` → Run the Bash test harness  
- `make clean` → Remove build artifacts  

#### Git
- Commit your work frequently with **meaningful commit messages**.  
- Add documentation in this README (examples, commands, notes).  
- Push to your fork and create a Pull Request at the end.  

---

### **Task-2: RISC-V Assembly Challenge (Fibonacci on Spike)**

Implement `fib.s` to compute the **first n Fibonacci numbers**.  

Steps:
1. Hardcode `n` in the `.data` section.  
2. Use an **iterative algorithm** in RISC-V assembly.  
3. Store results in memory.  

Run with:  
```bash
spike fib
````

---

## Submission Checklist

* [ ] Implemented `bitops.c` with all required operations
* [ ] Completed `run_tests.sh` to generate and verify results
* [ ] Configured `Makefile` for build, test, clean
* [ ] Implemented `fib.s` for Fibonacci in RISC-V assembly
* [ ] Updated `README.md` in your folder (dont change the original Readme) with:

  * Algorithm explanations
  * How to build & run
  * Example outputs
* [ ] Committed work regularly with meaningful messages
* [ ] Pushed work to forked repo
* [ ] Created a Pull Request

---

## Example Commands

### Build and Run C Program

```bash
make build
./bitops
```

### Run Tests

```bash
make test
```

### Clean Project

```bash
make clean
```

### Run Fibonacci on Spike

```bash
riscv64-unknown-elf-gcc fib.s -o fib
spike fib
```

---
 **Tip:** Write clean, modular code. Document your steps and explain optimizations in this README.
Good luck.

---

```

---

Would you like me to also **add TODO placeholders inside `bitops.c`, `run_tests.sh`, `Makefile`, and `fib.s`**, so students get a clear skeleton to start from instead of a blank file?
```
