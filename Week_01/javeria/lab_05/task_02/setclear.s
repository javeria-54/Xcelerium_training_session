.section .text
.globl _start

_start:
    li   a0, 8            # num = 8
    li   a1, 3            # pos = 3
    li   a2, 0            # choice = 0 (clear bit)

    blt  a1, zero, exit   # If pos < 0, exit
    li   t0, 31
    bgt  a1, t0, exit     # If pos > 31, exit

    li   t0, 1
    beq  a2, t0, set_bit
    beq  a2, zero, clear_bit
    j    exit

set_bit:
    li   t0, 1
    sll  t0, t0, a1      # t0 = 1 << pos
    or   a0, a0, t0      # num = num | t0
    j    exit
    
clear_bit:
    li   t0, 1
    sll  t0, t0, a1      # t0 = 1 << pos
    not  t0, t0          # t0 = ~t0
    and  a0, a0, t0      # num = num & t0

exit:

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0