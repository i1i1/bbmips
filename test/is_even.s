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
	jie	$s0,	$zero,	$v0

num_odd:
	la	$a0,	odd
	jal	$ra,	puts
	jie	$s1,	$zero,	$zero

num_even:
	la	$a0,	even
	jal	$ra,	puts
	jie	$zero,	$zero,	$s1

exit:
	syscall	0,	$zero,	$zero	# exit(0)


is_even:
	addi    $t0,    $zero,  2
	mod     $v0,    $a0,    $t0
	jie     $zero,  $zero,  $ra


puts:
	la	$t1,	puts_loop

puts_loop:
	lb	$t0,	0($a0)
	jie	$ra,	$t0,	$zero
	syscall	3,	$t0,	$zero
	addi	$a0,	$a0,	1
	jie	$t1,	$zero,	$zero

