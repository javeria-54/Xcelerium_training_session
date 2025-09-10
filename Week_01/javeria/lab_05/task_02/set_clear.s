	.file	"set_clear.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"Enter a 32-bit number: "
	.align	3
.LC1:
	.string	"%u"
	.align	3
.LC2:
	.string	"Enter bit position (0-31): "
	.align	3
.LC3:
	.string	"%d"
	.align	3
.LC4:
	.string	"Error: Bit position must be between 0 and 31."
	.align	3
.LC5:
	.string	"Enter choice (1 = Set bit, 0 = Clear bit): "
	.align	3
.LC6:
	.string	"After setting bit %d: %u\n"
	.align	3
.LC7:
	.string	"After clearing bit %d: %u\n"
	.align	3
.LC8:
	.string	"Invalid choice! Use 1 for set, 0 for clear."
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	printf
	addi	a5,s0,-20
	mv	a1,a5
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	scanf
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	printf
	addi	a5,s0,-24
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	scanf
	lw	a5,-24(s0)
	blt	a5,zero,.L2
	lw	a4,-24(s0)
	li	a5,31
	ble	a4,a5,.L3
.L2:
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	puts
	li	a5,1
	j	.L8
.L3:
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	printf
	addi	a5,s0,-28
	mv	a1,a5
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	scanf
	lw	a4,-28(s0)
	li	a5,1
	bne	a4,a5,.L5
	lw	a5,-24(s0)
	mv	a4,a5
	li	a5,1
	sllw	a5,a5,a4
	sext.w	a4,a5
	lw	a5,-20(s0)
	or	a5,a4,a5
	sext.w	a5,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	lw	a4,-20(s0)
	mv	a2,a4
	mv	a1,a5
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	printf
	j	.L6
.L5:
	lw	a5,-28(s0)
	bne	a5,zero,.L7
	lw	a5,-24(s0)
	mv	a4,a5
	li	a5,1
	sllw	a5,a5,a4
	sext.w	a5,a5
	not	a5,a5
	sext.w	a4,a5
	lw	a5,-20(s0)
	and	a5,a4,a5
	sext.w	a5,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	lw	a4,-20(s0)
	mv	a2,a4
	mv	a1,a5
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	printf
	j	.L6
.L7:
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	puts
.L6:
	li	a5,0
.L8:
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 15.1.0"
	.section	.note.GNU-stack,"",@progbits
