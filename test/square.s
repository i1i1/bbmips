.data
	.byte 255
	.byte 0x60
hello:	.word 0x60
	.space 0x30
	.ascii "1234"

abcd:	.asciiz "12345"
def:	.half 256

pref:	.asciiz "Square of "
mid:	.asciiz " is equal to "
suf:	.asciiz "\n"

.text
main:
	addi	$t1,	$zero,	10

	mul	$t2,	$t1,	$t1

	la	$s0,	pref
	la	$s1,	mid
	la	$s2,	suf

	add	$a0,	$s0,	$zero
	jal	$ra,	puts

	syscall	2,	$t1,	$zero

	add	$a0,	$s1,	$zero
	jal	$ra,	puts

	syscall	2,	$t2,	$zero

	add	$a0,	$s2,	$zero
	jal	$ra,	puts

	syscall	0,	$zero,	$zero


puts:
	la	$t1,	puts_loop

puts_loop:
	lb	$t0,	0($a0)
	jie	$ra,	$t0,	$zero
	syscall	3,	$t0,	$zero
	addi	$a0,	$a0,	1
	jie	$t1,	$zero,	$zero

