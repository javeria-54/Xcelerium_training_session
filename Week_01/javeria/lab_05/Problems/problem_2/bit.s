    .section .text
    .globl _start

_start:
    li t0, 0xF0F0F0F0
    li t1, 0
    li t2, 32

count_bits:
    andi t3, t0, 1
    add  t1, t1, t3
    srli t0, t0, 1
    addi t2, t2, -1
    bnez t2, count_bits

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0