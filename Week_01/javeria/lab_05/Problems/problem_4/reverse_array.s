.data
array:  .word 1, 2, 3, 4, 5
size:   .word 5

.text
.global _start

_start:
    la t0, array        # base address of array
    la t1, size         # load address of size
    lw t1, 0(t1)        # load size value into t1
    li t2, 0            # i = 0
    addi t3, t1, -1     # j = size - 1

loop:
    bge t2, t3, end         # stop when i >= j
    
    slli t4, t2, 2      # offset = i * 4
    add t4, t0, t4

    slli t5, t3, 2      # offset = j * 4
    add t5, t0, t5
    
    # Swap array[i] and array[j]
    lw a1, 0(t4)
    lw a0, 0(t5)
    sw a0, 0(t4)
    sw a1, 0(t5)
    
    addi t2, t2, 1      # i++
    addi t3, t3, -1     # j--
    j loop

end:

# Exit for Spike
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
