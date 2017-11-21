	#Brian O'Leary
	#13475468	
	
	#Write and verify a MIPS32 assembly language program that will display a wall of tiles. The design of the
	#tiles should be based on the letters in your name. Each tile should be 5 pixels wide and 5 pixels high. Each
	#row of the tile should be created from the corresponding letter of your name. The letter should be converted
	#to a binary number equal to the position of that letter in the alphabet (A=0). The bits of the binary number
	#indicate whether to colour in the corresponding pixel or not. The pixel should be in colour if the bit is one and
	#should be white if the bit is zero. Moving horizontally and vertically, tiles should be mirror images of the
	#previous tile. Choose whatever colour you prefer (except white!). The tiles should start in the top level of the
	#display and should cover the entire display (i.e. there may the tile fragments visible at the bottom and right of
	#the display).
	
	## BITMAP DISPLAY SETTINGS ## 
	# unit width in pixels=1, 
	# unit height in pixels=1, 
	# display width in pixels=256, 
	# display height in pixels=256, 
	# base address for display=0x10010000.
	
	.data			# Data segment

name:	.ascii "_____"
	.align	5
binArr: .space 32		#Space to store binary digits				
 	.text 			# Text segment
 	.globl main 		# Global symbol

main: 	
### Create array of binary digits from input name ###
	la $t0, name
	li $t1, 5		# Loop count for 5 characters
	li $s3, 2
	li $s5, 20		# Binary array offset. 20 bits for each char 
	
binLoop:lb $t3, ($t0)		# Load char from name
	subi $t3, $t3, 65	# Subtract 65 from char to put in range 0-25
	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327680	# Store array outside of memory required by display
	add $t4, $t4, $s5	# Get address to store binary bits
	li $t2, 5		# Loop count for 5 binary digits per char
	
	# Loop to construct binary array from char
binChar:
	div $t3,$s3   		# $t3 is number to be converted into binary. $s3 is 2
	mflo $t3      		# storing quotient in $t3 for further division
	mfhi $s4		# remainder (binary digit)
	
	sw $s4, ($t4)		# Store binary digit in binary array
	addi $t4, $t4, -4	# Move backwards through array so binary digits are in correct order
	addi $t2, $t2, -1	# Loop through 5 binary digits
	bne $t2,0,binChar 	# Reached end of binary answer if quotient = 0
	
	addi $s5, $s5, 20	# Increment binary array offset
	addi $t0, $t0, 1	# Increment char from name
	subi $t1, $t1, 1	# Increment loop count
	bne $t1, 0, binLoop	# Loop 5 times. Once for each car in name
	
### Create tile from binary array ###

	lui $s1, 0x00F0		# color: red
	li $s2, -1		# color: white
	lui $a1, 0x1001 	# load the display address
	
	li $t1, 1		# Upside down check
    	jal drawAllTiles
    	j end
    	
drawAllTiles:
	move $s0, $a1
	li $t8, 0		# tile count per column (51)
drawTileColumn:
	li $t7, 51		# tile count per row
	li $t0, 1		# Begin with orientation 1
drawTileRow:
	move $a1, $s0		# Address of top left pixel in tile
	
	#Choose which tile to draw
	bne $t1, 1, downwards
	#UPWARDS#
	bne $t0, 1, draw2
	jal drawTile1
	j tileDrawn
draw2: 	jal drawTile2
	j tileDrawn
	#DOWNWARDS#
downwards:
	bne $t0, 1, draw4
	jal drawTile3
	j tileDrawn
draw4:  jal drawTile4
tileDrawn:
	addi $s0, $s0, -5120	# Move pointer back up 5 pixel rows(1024*5)
	addi $s0, $s0, 20	# Move pointer to right to draw next tile
	
	addi $t7, $t7, -1	# Tiles per row
    	bne $t7, 0, drawTileRow
    	
    	# Fill in fragment at right side of display depending on row orientation
    	move $a1, $s0		# Load address
    	bne $t1, 1, f2
    	jal frag1
    	j done
f2:	jal frag2  
done:
    	addi $t8, $t8, 1	# Increment column count
    	move $t9, $t8
    	lui $s0, 0x1001 	# load the display address
addRow: addi $s0, $s0, 5120	# Move pointer down 5 pixels for every row we've drawn
	addi $t9, $t9, -1
	bne $t9, 0, addRow
	
	bne $t1, 0, one		# Inverse upside down check. So every second row is upside down
	li $t1, 1
	j zero
one:	li $t1, 0
zero:
	bne $t8, 51, drawTileColumn	# Number of rows
    	
    	# Fill in fragment at bottom side of display depending on row orientation
	li $t0, 52	#52 frags at bottom
	li $t1, 1	# Frag 3 or 4 check
botFragLoop:

    	move $a1, $s0		# Load address
    	bne $t1, 1, f4
    	jal frag3
    	bne $t1, 0, one1	# Inverse frag down check.
	li $t1, 1
	j zero1
one1:	li $t1, 0
zero1:
    	j doneFrag
f4:	jal frag4
	bne $t1, 0, one2	# Inverse frag down check.
	li $t1, 1
	j zero2
one2:	li $t1, 0
zero2:
doneFrag:
	addi $t0, $t0, -1
	bne $t0, 0, botFragLoop
end:
 	li $v0, 10		# system call for exit
 	syscall 		# Exit!
 	
 	
 	
### ROUTINES FOR DRAWING TILE IN DIFFERENT ORIENTATIONS ###
 	
## DRAW TILE IN ORIENTATION 1 ###
drawTile1:	

	move $s0, $a1
	li $t2, 25		# Loop counter. 25 for all bits in binary array
	li $t6, 5		# Increase row every 5 digits
	li $t3, 4		# t3 = 4
	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	
SingleTileLoop1:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, w1		# Check if bit is 1 or 0 and choose color
	sw $s1, ($s0)		# Store Color in display pixel
	j c1
w1:	sw $s2, ($s0)		# Store White in display pixel
c1:
	add $s0, $s0, $t3	# Increment display address by 4 to get next pixel
	add $t4, $t4, $t3	# Increment binary array address to get next digit
	addi $t2, $t2, -1	# Loop counter for 25 pixels in tile
	addi $t6, $t6, -1	# Increment char per row
	bne $t6, 0, jump1
	li $t6, 5		# Reset char per row to 5
	addi $s0, $s0 -20	# Reset pointer to left side of tile
	addi $s0, $s0, 1024	# Drop a row#1104
jump1:
	bne $t2, 0, SingleTileLoop1	# Loop if we havn't reached the last binary digit
	li $t0, 2		# Setup for next tile
	jr $ra
	
## DRAW TILE IN ORIENTATION 2 ###
drawTile2:	
	move $s0, $a1
	li $t2, 25		# Loop counter. 25 for all bits in binary array
	li $t6, 5		# Increase row every 5 digits
	li $t3, 4		# t3 = 4
	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 16	# Begin and end of first char
SingleTileLoop2:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, w2
	sw $s1, ($s0)		# Store Color in display pixel
	j c2
w2:	sw $s2, ($s0)		# Store White in display pixel
c2:
	add $s0, $s0, $t3	# Increment display address by 4 to get next pixel
	sub $t4, $t4, $t3	# Decrement binary array address to get next digit
	addi $t2, $t2, -1	# Loop counter for 25 pixels in tile
	addi $t6, $t6, -1	# Increment char per row
	bne $t6, 0, jump2
	li $t6, 5		# Reset char per row to 5
	addi $t4, $t4, 40	# Begin and end of next char
	addi $s0, $s0 -20	# Reset pointer to left side of tile
	addi $s0, $s0, 1024	# Drop a row#1104
jump2:
	bne $t2, 0, SingleTileLoop2	# Loop if we havn't reached the last binary digit
	li $t0, 1		# Setup for next tile
	jr $ra

## DRAW TILE IN ORIENTATION 3 ###
drawTile3:	
	move $s0, $a1
	li $t2, 25		# Loop counter. 25 for all bits in binary array
	li $t6, 5		# Increase row every 5 digits
	li $t3, 4		# t3 = 4
	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 80	# Begin and start of last char
SingleTileLoop3:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, w3
	sw $s1, ($s0)		# Store Color in display pixel
	j c3
w3:	sw $s2, ($s0)		# Store White in display pixel
c3:
	add $s0, $s0, $t3	# Increment display address by 4 to get next pixel
	add $t4, $t4, $t3	# Decrement binary array address to get next digit
	addi $t2, $t2, -1	# Loop counter for 25 pixels in tile
	addi $t6, $t6, -1	# Increment char per row
	bne $t6, 0, jump3
	li $t6, 5		# Reset char per row to 5
	addi $t4, $t4, -40	# Begin at start of previous char
	addi $s0, $s0 -20	# Reset pointer to left side of tile
	addi $s0, $s0, 1024	# Drop a row#1104
jump3:
	bne $t2, 0, SingleTileLoop3	# Loop if we havn't reached the last binary digit
	li $t0, 2		# Setup for next tile
	jr $ra
	
## DRAW TILE IN ORIENTATION 4 ###
drawTile4:	
	move $s0, $a1
	li $t2, 25		# Loop counter. 25 for all bits in binary array
	li $t6, 5		# Increase row every 5 digits
	li $t3, 4		# t3 = 4
	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 96	# Begin and end of last char
SingleTileLoop4:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, w4
	sw $s1, ($s0)		# Store Color in display pixel
	j c4
w4:	sw $s2, ($s0)		# Store White in display pixel
c4:
	add $s0, $s0, $t3	# Increment display address by 4 to get next pixel
	sub $t4, $t4, $t3	# Decrement binary array address to get next digit
	addi $t2, $t2, -1	# Loop counter for 25 pixels in tile
	addi $t6, $t6, -1	# Increment char per row
	bne $t6, 0, jump4
	li $t6, 5		# Reset char per row to 5
	addi $s0, $s0 -20	# Reset pointer to left side of tile
	addi $s0, $s0, 1024	# Drop a row
jump4:
	bne $t2, 0, SingleTileLoop4	# Loop if we havn't reached the last binary digit
	li $t0, 1		# Setup for next tile
	jr $ra

	## ROUTINES TO FILL IN FRAGMENTS ON SCREEN EDGE##
	
## Fragment of tile 3 top
frag3:	move $s0, $a1
	li $s5, 5		# 5 rows

	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 80
frag3Loop:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, fw3
	sw $s1, ($s0)		# Store Color in display pixel
	j fc3
fw3:	sw $s2, ($s0)		# Store White in display pixel
fc3:
	addi $s5, $s5, -1
	addi $s0, $s0, 4	# Next pixel
	addi $t4, $t4, 4	# Next bit
	bne $s5, 0, frag3Loop
	jr $ra
	
## Fragment of tile 4 top
frag4:	move $s0, $a1
	li $s5, 5		# 5 rows

	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 96	# Begin and end of last char
frag4Loop:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, fw4
	sw $s1, ($s0)		# Store Color in display pixel
	j fc4
fw4:	sw $s2, ($s0)		# Store White in display pixel
fc4:
	addi $s5, $s5, -1
	addi $s0, $s0, 4	# Next pixel
	addi $t4, $t4, -4	# Next bit
	bne $s5, 0, frag4Loop
	jr $ra
	
	## Fragment of tile 2 side
frag1:	move $s0, $a1
	li $s5, 5		# 5 rows

	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 16	# Begin and end of first char
frag1Loop:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, fw1
	sw $s1, ($s0)		# Store Color in display pixel
	j fc1
fw1:	sw $s2, ($s0)		# Store White in display pixel
fc1:
	addi $s5, $s5, -1
	addi $s0, $s0, 1024	# Drop a row
	addi $t4, $t4, 20	# Begin and end of next char
	bne $s5, 0, frag1Loop
	jr $ra
	
	## Fragment of tile 4 side
frag2:	move $s0, $a1
	li $s5, 5		# 5 rows

	la $t4, binArr		# Address of binary array
	addi $t4, $t4, 327684	# Store array outside of memory required for display
	addi $t4, $t4, 96	# Begin and end of first char
frag2Loop:	
	lw $t5, ($t4)		# Get binary bit
	beq $t5, 0, fw2
	sw $s1, ($s0)		# Store Color in display pixel
	j fc2
fw2:	sw $s2, ($s0)		# Store White in display pixel
fc2:
	addi $s5, $s5, -1
	addi $s0, $s0, 1024	# Drop a row
	subi $t4, $t4, 20	# Begin and end of next char
	bne $s5, 0, frag2Loop
	jr $ra
