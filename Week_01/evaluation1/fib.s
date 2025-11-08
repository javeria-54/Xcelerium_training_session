.section .text
.globl _start

_start:
    li t1, 0  # i= 0       
    li t2, 8  # n = 8     
    li t3, 0   # t1 = 0
    li t4, 1    # t2 = 1
    add t5, t4, t3  # nextTerm = t1 + t2; 

loop:
    addi t1, t1, 1   # i++
    mv  t3, t4    # t1=t2
    mv  t4, t5    # t2=nextterm
    add t5, t3, t4  # nextTerm = t1 + t2;
    blt t1, t2, loop  # i <= n; 

# this fibonacci sequence can print first 10 elements of this series

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0