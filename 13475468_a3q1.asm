	#Brian O'Leary
	#13475468	
	
	#Write a test program that will encrypt a test string using a one-time pad cypher and then decrypt the
	#resulting string. The input string and the one-time pad should be stored in memory before execution of the
	#program. The output string should also be held in memory and should not overwrite the input string. Two
	#separate subroutines should be included in the program – one for encryption and one for decryption. The
	#parameters for the subroutines should be the starting addresses of the input string, of the one-time pad and
	#of the output string. All strings should be terminated with a full stop. In the case of encryption, non-upper
	#case letter characters (e.g. punctuation and spaces) should be removed (expect the termination character).
	#In the case of decryption, you can assume that the string is all upper case letters with no other characters
	#(except the termination character).
	#A program should be written to test the subroutine using the plaintext “WINNIE THE POOH.” and the onetime
	#pad “IDIDKNOWONCEONLYIVESORTOFFORGOTTEN.”
	
	.data			# Data segment
mess0:	.ascii "Input String: \0"
mess1:	.ascii "Encrypted String: \0"
mess2:	.ascii "Decrypted String: \0"
otp: 	.ascii "IDIDKNOWONCEONLYIVESORTOFFORGOTTEN."	# One-Time-Pad Key
inText:	.ascii "WINNIE THE POOH."			# Text to be encrypted/de-crypted
outText:.ascii  					# Output string to hold Encrypted/Decrypted String
 	.text 			# Text segment
 	.globl main 		# Global symbol

main: 	li $t0, 46		# $t0 = . Termination char
	
	# Print message 0 and input String
	la $a0,mess0 
        li $v0,4
        syscall
        la $a0,inText 
        syscall
        # Print newline
	li $a0, 10	
	li $v0, 11      
	syscall
	
	#Load and print string message 1
	la $a0,mess1 
        li $v0,4
        syscall
	# Setup parameters and call Encryption subroutine
	la $a0, inText
 	la $a1, otp
 	la $a2, outText
 	jal Encrypt
	# Print Encrypted String
	la $a0,outText 
        syscall
	# Print newline
	li $a0, 10	
	li $v0, 11      
	syscall
	
	#Load and print string message 2
	la $a0,mess2 
        li $v0,4
        syscall 
	# Setup parameters and call Decryption subroutine
	la $a0, inText
 	la $a1, otp
 	la $a2, outText
	jal Decrypt
	# Print Decrypted String
	la $a0,outText 
        syscall
	#End program
	j Finish
	
	
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
	addi $t3, $t3, 1	# Increment address of one time pad char
	addi $t2, $t2, 1	# Increment address of output char
	
noSave: beq $t4, $t0, end1	# End if we reach the full stop
	addi $t1, $t1, 1	# increment address of input char
	j EnLoop

end1:	sb $t4, ($t3)		# Add termination char to encrypted string
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

Finish:
 	li $v0, 10		# system call for exit
 	syscall 		# Exit!
