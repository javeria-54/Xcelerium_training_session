.section .text
.globl _start

_start:
    li   a0, -4538        # dividend = 4538
    li   a1, 3           # divisor = 3
    li   a2, 0           # quotient = 0
    li   a3, 0           # remainder = 0
    li   a4, 16          # n = 16 bits
    
    slt  t0, a0, x0      # dividend < 0
    slt  t1, a1, x0      # divisor < 0
    xor  t2, t0, t1      # sign = ((dividend < 0) ^ (divisor < 0)) ? -1 : 1;
    
    bge  a0, x0, abs_dividend_done
    sub  a0, x0, a0      # a0 = -a0 dividend
abs_dividend_done: 
    bge  a1, x0, abs_divisor_done
    sub  a1, x0, a1      # a1 = -a1 divisor
abs_divisor_done:
    li   t3, 15          # counter i = 15   
division_loop:
    blt  t3, x0, loop_end  # if i < 0, exit loop    
    slli a3, a3, 1       # remainder = remainder << 1;
    srl  t4, a0, t3      #  (u_dividend >> i)
    andi t4, t4, 1       # next_bit = (u_dividend >> i) & 1
    or   a3, a3, t4      # remainder = remainder | next_bit;
    sub  t5, a3, a1      # remainder = remainder - u_divisor;
    blt  t5, x0, negative_result 
positive_result:
    #  quotient = (quotient << 1) | 1
    mv   a3, t5          
    slli a2, a2, 1       
    ori  a2, a2, 1       
    j    next_iteration
negative_result:    
    add t5, t5, a1        # remainder = remainder + u_divisor;
    slli a2, a2, 1       # quotient = quotient << 1;     
next_iteration:
    addi t3, t3, -1      # i--
    j    division_loop    
loop_end:
    beq  t2, x0, positive_quotient
    sub  a2, x0, a2      # quotient = -quotient    
positive_quotient:
    beq  t0, x0, positive_remainder
    sub  a3, x0, a3      # remainder = -remainder    
positive_remainder:

    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)

1:  j 1b

.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
