.data
.byte 255 # 0
.byte 0x60 # 1
hello: .word 0x60 # 2
.space 0x30 # 6
.ascii "1234" # 0x36
abcd: .asciiz "12345" # 0x3A
def: .half 256 # 0x40
.text
main:
	addi	$t1,	$zero,	10
	mul	$t2,	$t1,	$t1

syscalls:
	syscall	2,	$t2,	$zero
	syscall	0,	$zero,	$zero

