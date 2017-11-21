	#Brian O'Leary
	#13475468	
	
	#Write and verify a program that will encrypt or decrypt of a sentence entered using the Keyboard and
	#Display Simulator. The mode (encrypt or decrypt) should be stored in memory prior to execution of the
	#program. The user should type the sentence terminated with a full stop with the keyboard. After the user
	#presses full stop, the program should display the encrypted or decrypted message and quit.
	
	.data			# Data segment
mess1:	.ascii "Input String:  \0"
mess2:	.ascii "Output String: \0"
mode:	.word 1			# Encrypt or Decrypt (Encrypt = 0, Decrypt = 1)
otp: 	.ascii "IDIDKNOWONCEONLYIVESORTOFFORGOTTEN."	# One-Time-Pad Key
inText:	.ascii 			# Text to be encrypted/de-crypted
outText:.ascii  		# Output string to hold Encrypted/Decrypted String
 	.text 			# Text segment
 	.globl main 		# Global symbol

main: 	li $t0, 46		# $t0 = . Termination char
	la $t1, inText		# Load address to store input string
	la $t2, mode
	lw $t2, ($t2)		# Load int representing program mode
	
	lui $t6, 0xffff		# Base address for Keyboard/Display Simulator
	
	#Read input string from user
Read:	#li $v0, 12		# Code to use I/O terminal
	#syscall
	#move $s1, $v0
	#sb $s1, ($t1)
	#addi $t1, $t1, 1
	#bne $s1, $t0, Read
	
	#Input Polling
	lw $s1, 0($t6)		# Check if RCR = 1. If not loop
	andi $s1, $s1, 0x0001	# Bitwise and with 1
	bne $s1, 1, Read	# If not 1, check again
	lw $s1, 4($t6)		# Load input char. RDR
	sb $s1, ($t1)		# Store input char
	addi $t1, $t1, 1	# Increment output string index
	bne $s1, $t0, Read
	
	# Print new line
	li $a0, 10		
	li $v0, 11      
	syscall
	# Print message 1 and input String
	li $v0, 4		
	la $a0, mess1
	syscall
	la $a0, inText		
	syscall
	# Print new line
	li $a0, 10		
	li $v0, 11      
	syscall
	
	# Setup parameters for subroutine
	la $a0, inText
 	la $a1, otp
 	la $a2, outText
 	
 	# Check what mode is selected (Encrypt = 0, Decrypt = 1)
	beq $t2, 1, mode1 	
	jal Encrypt
	j jump
mode1:	jal Decrypt
jump:	 
	# Print message 2 and output String
	li $v0, 4		
	la $a0, mess2
	syscall
	la $a0, outText		
	syscall
	
	lui $t6, 0xffff		# Base address for Keyboard/Display Simulator
	la $t3, outText
	#Output Polling. Print to Display Simulator
Output: 
	lw $t1, 8($t6) 		# Check TCR
	andi $t1, $t1, 0x0001 	# Bitwise and with 1
	beq $t1, $zero, Output 	# If 0, check again 
	lb $s0, ($t3)		# Load char from output string
	sw $s0, 12($t6)		# Store char in TDR
	addi $t3, $t3, 1	# Increment output string index
	bne $s0, $t0, Output	# If char is the termination char, then stop

Finish:
 	li $v0, 10		# system call for exit
 	syscall 		# Exit!
 	
 	
 	### Subroutines taken from Question 1 ###
 	
#Encryption Subroutine
Encrypt:move $t1, $a0		# Set parameters
	move $t2, $a1
	move $t3, $a2
EnLoop:	lb $t4, 0($t1)		# $t4 = input string char
	lb $t5, 0($t2)		# $t5 = one time pad char
	
	subi $t4, $t4, 65	# Scale down ascii codes to range 0-25
	subi $t5, $t5, 65
	add $t5, $t5, $t4	# Sum ascii numbers
	
	blt $t5,26,noSub	# if sum is 25 or less, dont sub 26. (if >25 -> -26)
	subi $t5, $t5, 26
	
noSub:  addi $t5, $t5, 65	# Scale up ascii code to range 65-90
	addi $t4, $t4, 65	# Scale up ascii code to range 65-90
	
	bgt $t4, 90, noSave 	# Only process capital letters. In range 64<x<91
	blt $t4, 65, noSave
	
save:	sb $t5, ($t3)		# Store encrypted char in outText
	addi $t3, $t3, 1	# Increment address of outout
	addi $t2, $t2, 1	# Increment address of one time pad
	
noSave: beq $t4, $t0, end1	# End if we reach the full stop
	addi $t1, $t1, 1	# increment address of input char
	j EnLoop

end1:	sb $t4, ($t3)		# Add termination char to encrypted string
	addi $t3, $t3, 1	# Increment address of output
	sb $zero, ($t3)		# Add Null character to end of encrypted string for printing
	jr $ra 
	
	#Decryption Subroutine
Decrypt:move $t1, $a0		# Set parameters
	move $t2, $a1
	move $t3, $a2
DeLoop: lb $t4, 0($t3)		# $t4 = Encrypted string char
	lb $t5, 0($t2)		# $t5 = one time pad char
	
	beq $t4, $t0, end2	# Check for termination char
	
	subi $t4, $t4, 65	# Scale down ascii codes to range 0-25
	subi $t5, $t5, 65
	sub $t5, $t4, $t5	# Subtract ascii numbers
	bge $t5,0,noAdd		# If sum is greater than -1 dont add 26. (if <0 then +26)
	addi $t5, $t5, 26
	
noAdd:  addi $t5, $t5, 65	# Scale up ascii code to range 65-90
	
	sb $t5, ($t3)		# Store decrypted char in output string
	
	addi $t1, $t1, 1	# Increment addresses of all ascii strings
	addi $t2, $t2, 1
	addi $t3, $t3, 1
	j DeLoop		# Process next char
	
end2:	sb $t4, ($t3)		# Add termination char to Decrypted string
	jr $ra 
