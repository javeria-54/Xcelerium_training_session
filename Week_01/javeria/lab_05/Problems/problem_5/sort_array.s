.data
array:  .word 31, 25, 32, 47, 15   # Define an array of 5 integers
size:   .word 5                    # Size of the array

.text
.global _start

_start:
    la t0, array       # base address of array
    lw t1, size        # size (n) → t1
    addi t1, t1, -1    # n-1 passes
    li t2, 0           # outer loop counter (i = 0)

outer_loop:
    li t3, 0           # inner loop counter (j = 0)
    la t4, array       # reset pointer to beginning

inner_loop:
    lw a1, 0(t4)       # arr[j]
    lw a0, 4(t4)       # arr[j+1]
    ble a1, a0, no_swap

    # swap arr[j] and arr[j+1]
    sw a0, 0(t4)
    sw a1, 4(t4)

no_swap:
    addi t4, t4, 4     # move pointer (j++)
    addi t3, t3, 1
    blt t3, t1, inner_loop

    addi t2, t2, 1     # i++
    blt t2, t1, outer_loop

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
