.section .text
.globl _start

_start:
    li   t1, 15        
    li   t2, 27        
    sub  t3, t1, t2
    blt  t3, x0, negate

negate:
    sub  t3, x0, t3     
    j    store_result

store_result:
    mv   a0, t3  

   # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, 0(t1)
 
    # Loop forever if spike does not exit
1:  j 1b
 
.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
