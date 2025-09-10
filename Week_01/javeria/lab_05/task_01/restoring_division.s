	.file	"restoring_division.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"Final Result: %d \303\267 %d = "
	.align	3
.LC1:
	.string	"Quotient = %d, Remainder = %d\n"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-64
	sd	ra,56(sp)
	sd	s0,48(sp)
	addi	s0,sp,64
	li	a5,4096
	addi	a5,a5,-881
	sw	a5,-36(s0)
	li	a5,-3
	sw	a5,-40(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	li	a5,16
	sw	a5,-44(s0)
	lw	a5,-36(s0)
	mv	a4,a5
	lw	a5,-40(s0)
	xor	a5,a4,a5
	sext.w	a5,a5
	bge	a5,zero,.L2
	li	a5,-1
	sw	a5,-28(s0)
	j	.L3
.L2:
	li	a5,1
	sw	a5,-28(s0)
.L3:
	lw	a5,-36(s0)
	sraiw	a5,a5,31
	lw	a4,-36(s0)
	xor	a4,a5,a4
	subw	a5,a4,a5
	sw	a5,-48(s0)
	lw	a5,-40(s0)
	sraiw	a5,a5,31
	lw	a4,-40(s0)
	xor	a4,a5,a4
	subw	a5,a4,a5
	sw	a5,-52(s0)
	lw	a5,-44(s0)
	addiw	a5,a5,-1
	sw	a5,-32(s0)
	j	.L4
.L7:
	lw	a5,-24(s0)
	slliw	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-32(s0)
	lw	a4,-48(s0)
	sraw	a5,a4,a5
	sext.w	a5,a5
	andi	a5,a5,1
	sw	a5,-56(s0)
	lw	a5,-24(s0)
	mv	a4,a5
	lw	a5,-56(s0)
	or	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	mv	a4,a5
	lw	a5,-52(s0)
	subw	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	sext.w	a5,a5
	bge	a5,zero,.L5
	lw	a5,-24(s0)
	mv	a4,a5
	lw	a5,-52(s0)
	addw	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	slliw	a5,a5,1
	sw	a5,-20(s0)
	j	.L6
.L5:
	lw	a5,-20(s0)
	slliw	a5,a5,1
	sext.w	a5,a5
	ori	a5,a5,1
	sw	a5,-20(s0)
.L6:
	lw	a5,-32(s0)
	addiw	a5,a5,-1
	sw	a5,-32(s0)
.L4:
	lw	a5,-32(s0)
	sext.w	a5,a5
	bge	a5,zero,.L7
	lw	a5,-20(s0)
	mv	a4,a5
	lw	a5,-28(s0)
	mulw	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	mv	a4,a5
	lw	a5,-28(s0)
	mulw	a5,a4,a5
	sw	a5,-24(s0)
	lw	a4,-40(s0)
	lw	a5,-36(s0)
	mv	a2,a4
	mv	a1,a5
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	printf
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	mv	a2,a4
	mv	a1,a5
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	li	a5,0
	mv	a0,a5
	ld	ra,56(sp)
	ld	s0,48(sp)
	addi	sp,sp,64
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
