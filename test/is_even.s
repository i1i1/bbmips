.data
even: .asciiz " is even\n"
odd:  .asciiz " is odd\n"

.text
main:
	addi	$a0,	$zero,	6	# a0 = 5

syscalls:
	syscall	2,	$a0,	$zero	# print(a0)
	la	$s0,	num_even
	la	$s1,	exit
	jal	$ra,	is_even
	jie	$v0,	$zero,	$s0

num_odd:
	la	$a0,	odd
	jal	$ra,	puts
	jie	$zero,	$zero,	$s1

num_even:
	la	$a0,	even
	jal	$ra,	puts
	jie	$zero,	$zero,	$s1

exit:
	syscall	0,	$zero,	$zero	# exit(0)


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

is_even:
	addi	$t0,	$zero,	2
	mod	$v0,	$a0,	$t0
	jie	$zero,	$zero,	$ra


