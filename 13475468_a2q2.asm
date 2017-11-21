	#Brian O'Leary
	#13475468	
	
	#Write and verify a MIPS32 assembly language program that will determine if the input numbers are
	#palindromes when written in binary, e.g. 3 decimal equals 11 in binary and so is a binary palindrome.
	#Leading zeros should be ignored. The inputs to the program should be an array of 32-bit numbers and the
	#length of the array. The output from the program should be an array of Boolean values indicating if each
	#number in the input array is a binary palindrome or not. The Boolean values should be stored as bytes
	#(0=false,1=true).
	
	.data			# Data segment
arrIn: 	.word 3,8,17,8,3,8,3	# Array of numbers
sizeIn:	.word 7			# Size of Input array
arrOut: .space 32 		# Output array with allocated space to hold boolean values (0, 1)
binArr: .word			# Space to store temporary binary arrays to check for palindrome
 	.text 			# Text segment
 	.globl main 		# Global symbol

main: 	addi $t0, $zero, 0	# Array index to 0
	la $t1, sizeIn		
	lw $t1 , ($t1)		# $t1 = array size
	addi $s2, $zero, 4	# $s2 = 4
	addi $s3, $zero, 2	# $s2 = 2
	la $t2, arrIn		# Load address of input array
	la $t5, binArr		# Load address of binary array
	
	# Loop through Input array
loop:	multu $s2, $t0    	# Multiply index by 4 to get offset. n*4
	mflo $t3          	# Put multiplication result back in t3. $t3 = offset. $t3 = n*4
	add $t3, $t3, $t2	# $t3 = arrIn[offset]
	lw $t3, ($t3)		# Load nth number into $t3
	add $s5, $zero, $zero  	# Init binary array size to 0
	
	# Loop to construct binary array
binLoop:multu $s2, $s5    	# Multiply index by 4 to get offset. n*4
	mflo $t7          	# Put multiplication result back in t3. $t3 = offset. $t3 = n*4
	add $t7, $t7, $t5	# $t7 = binArr[offset]
	
	div $t3,$s3   		# $t3 is number to be converted into binary. $s3 is 2

	mflo $t3      		# storing quotient in $t3 for further division
	mfhi $s4		# remainder (binary digit)
	
	sw $s4, ($t7)		# Store binary digit in binary array
	
	addi $s5, $s5, 1	# Increment size of binary array 
	bne $t3,0,binLoop 	# Reached end of binary answer if quotient = 0
	sub $s5, $s5, 1		# Decrement array size by 1
	
	# Check if binary array is a palindrome
	addi $t8, $zero, 0	# i = 0
	add $t9, $zero, $s5	# j = N
palin:	# $t6 = binary array[i]
	multu $s2, $t8    	# Multiply index by 4 to get offset. n*4
	mflo $t6          	# Put multiplication result back in t3. $t3 = offset. $t6 = n*4
	add $t6, $t6, $t5	# $t6 = arrIn[offset]
	lw $t6, ($t6)		# Load nth number into $t6
	
	# $t7 = binary array[j]
	multu $s2, $t9    	# Multiply index by 4 to get offset. n*4
	mflo $t7          	# Put multiplication result back in t3. $t7 = offset. $t7 = n*4
	add $t7, $t7, $t5	# $t7 = arrIn[offset]
	lw $t7, ($t7)		# Load nth number into $t6
	
	bne $t6, $t7, notPal	# If pair don't match then it's not a palindrome
	
	addi $t8, $t8, 1	# i++
	subi $t9, $t9, 1	# j--
	blt $t8, $t9, palin	# While i < j
	
	# Store 1 in Output Array
isPal: 	la $t6, arrOut		# Load address of output array
	multu $s2, $t0    	# Multiply index by 4 to get offset. n*4
	mflo $t7          	# Put multiplication result back in t3. $t3 = offset. $t6 = n*4
	add $t7, $t7, $t6	# $t6 = arrIn[offset]
	addi $t8, $zero, 1
	sw $t8, ($t7)		# store 1 in output array 
	j end			# Jump to end of loop

	# Store 0 in Output Array
notPal: la $t6, arrOut		# Load address of output array
	multu $s2, $t0    	# Multiply index by 4 to get offset. n*4
	mflo $t7          	# Put multiplication result back in t3. $t3 = offset. $t6 = n*4
	add $t7, $t7, $t6	# $t6 = arrIn[offset]
	addi $t8, $zero, 0
	sw $t8, ($t7)		# store 0 in output array 

end:	addi $t0, $t0, 1	# Increment sequence count
 	bne $t0, $t1, loop	# If sequence count is below array size, repeat loop
 	
 	# Clear binary array
 	addi $s5, $zero, 8	# Init index to clear 8 bytes
binClear:
	multu $s2, $s5    	# Multiply index by 4 to get offset. n*4
	mflo $t7          	# Put multiplication result back in t3. $t3 = offset. $t3 = n*4
	add $t7, $t7, $t5	# $t7 = binArr[offset]
	
	sw $zero, ($t7)		# Set array value to 0
	
	subi $s5, $s5, 1	# Decrement index
	bge $s5, $zero, binClear# While index >= 0
	
 	li $v0, 10		# system call for exit
 	syscall 		# Exit!
