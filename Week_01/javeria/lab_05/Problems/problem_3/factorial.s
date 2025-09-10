.section .text
.globl _start

_start:
    li t1, 1       
    li t2, 5       
    li t3, 1       

loop:
    mul t3, t3, t1     
    addi t1, t1, 1     
    ble t1, t2, loop   

    mv a0, t3          

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
