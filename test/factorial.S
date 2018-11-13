.data
hello: .word 0
pref: .asciiz "Factorial is equal to "
suf: .asciiz "\n"

.text
main:
	addi	$s1,	$zero,	5     # s1 = 5
	addi	$s2,	$zero,	1     # s2 = 1
	addi	$s3,	$zero,	1     # s3 = 1

	la	$s4,	loop          # s4 = loop

loop:
	mul	$s2,	$s2,	$s1   # s2 = s2 * s1
	addi	$s1,	$s1,	-1    # s1 = s1 - 1

	jil	$s3,	$s1,	$s4   # if (s3 < s1) goto loop

	la	$s4,	hello
	stw	$s2,	0($s4)

syscalls:
	la	$a0,	pref
	jal	$ra,	puts
	syscall	2,	$s2,	$zero # print(s2)
	la	$a0,	suf
	jal	$ra,	puts

	syscall	0,	$zero,	$zero # exit(0)


puts:
	la	$t1,	puts_loop
	la	$t2,	puts_ret

puts_loop:
	lb	$t0,	0($a0)
	jie	$t0,	$zero,	$t2
	syscall	3,	$t0,	$zero
	addi	$a0,	$a0,	1
	jie	$zero,	$zero,	$t1

puts_ret:
	jie	$zero,	$zero,	$ra


