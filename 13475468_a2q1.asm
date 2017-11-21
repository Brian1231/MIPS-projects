	#Brian O'Leary
	#13475468	
	
	#Write and verify a MIPS32 assembly language program that finds all of the equilibrium indices in an array of
	#numbers. The inputs to the program should be an array of 32-bit numbers and the length of the array. The
	#output from the program should be an array of equilibrium indices and the length of the array of equilibrium
	#indices.
	.data			# Data segment
arrIn: 	.word 1,5,-7,2,3,-4,0	# Array of numbers
sizeIn:	.word 7			# Size of Input array
arrOut: .space 32 		# Output array with allocated space
sizeOut:.word  			# Size of Output array
 	
 	.text 			# Text segment
 	.globl main 		# Global symbol

main: 	addi $t0, $zero, 0	# Array index to 0
	la $s1, sizeIn
	lw $t1 , ($s1)		# $t1 = array size
	la $t2, arrIn		# Load address of input array
	la $t5, arrOut		# Load address of output array
	addi $s2, $zero, 4	# $s2 = 4
	add $s6, $zero, $zero   # Init output array size to 0

loop:	multu $s2, $t0    	# Multiply index by 4 to get offset. n*4
	mflo $t3          	# Put multiplication result back in t3. $t3 = offset. $t3 = n*4
	add $t3, $t3, $t2	# $t3 = arrIn[offset]
	
	add $s4, $zero, $zero  	# Init left sum to 0
	add $s5, $zero, $zero 	# Init right sum to 0
	add $s0, $zero, $zero 	# Init sum index to 0
	
	beq $t0, $zero, skipL	# Skip left sum for 0th index
	
	#sum left of n
sumL:	multu $s2, $s0    	# Multiply index by 4 to get offset. n*4
	mflo $t4          	# Put multiplication result back in t3. $t4 = offset. $t3 = n*4
	add $t4, $t4, $t2	# $t4 = arrIn[offset]
	lw $t4, ($t4)		# Load number
	add $s4, $s4, $t4	# Add number to left sum

	addi $s0, $s0, 1	# Increment index
	bne $s0, $t0, sumL	# If index is not equal to n, repeat sumL loop
	
skipL:	beq $t0, $t1, skipR	# Skip right sum for last index

	#sum right of n
sumR:	multu $s2, $s0    	# Multiply index by 4 to get offset. n*4
	mflo $t4          	# Put multiplication result back in t4. $t3 = offset. $t4 = n*4
	add $t4, $t4, $t2	# $t4 = arrIn[offset]
	lw $t4, ($t4)		# Load number
	add $s5, $s5, $t4	# Add number to left sum

	addi $s0, $s0, 1	# Increment index
	bne $s0, $t1, sumR	# If index is not equal to array size, repeat sumR loop
	
	lw $t3, ($t3)		# Subtract arrayIn[n] from right sum
	sub $s5, $s5, $t3
	
skipR:	bne $s4, $s5, noteq	# Check if left sum equals right sum
	multu $s2, $s6    	# Multiply Output array size by 4 to get offset. n*4
	mflo $t4          	# Put multiplication result back in t3. $t4 = offset. $t3 = n*4
	add $t4, $t4, $t5	# $t4 = arrOut[offset]
	
	sw $t0, ($t4)		# Store index in output array
	addi $s6, $s6, 1	# Increment size of output array
	
noteq:
	addi $t0, $t0, 1	# Increment sequence count
 	bne $t0, $t1, loop	# If sequence count is below array size, repeat loop
 	
 	la $t4, sizeOut		# Load address to store Output array size
 	sw $s6, ($t4)		# Store size of Output array
 	
 	li $v0, 10		# system call for exit
 	syscall 		# Exit!
