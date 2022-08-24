#;	Assignment #11
#; 	Author: Keith Beauvais
#; 	Section: 1001
#; 	Date Last Modified: 11/20/2021
#; 	Program Description: This program will ask the user to define the size and limits of a square 2 dimensional array (matrix) 
#; 						 which the program will populate with semi-random values that will create a variation of a magic square.

.data
#;	System service constants
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_PRINT_CHARACTER = 11
	SYSTEM_EXIT = 10
	SYSTEM_READ_INTEGER = 5

#;	Random Number Generator Values
	M = 0x00010001
	A = 75
	C = 74
	previousRandomNumber: .word  1

#;	Magic Square
	MINIMUM_SIZE = 2
	MAXIMUM_SIZE = 10
	MAXIMUM_TOTAL = 1000
	magicSquare: .space MAXIMUM_SIZE*MAXIMUM_SIZE*4 

#; 
	userOutputSize: .asciiz "Magic Square Size (2-10) : "
	errorSize: .asciiz "Size must be between 2 and 10."
	newLine: .asciiz "\n"
	magicNumber: .asciiz "Magic Number: "
	errorMagic: .asciiz "Magic number must be between the square size and 1000."
	space: .asciiz "  "

	size: .word  0
	magic: .word  0
	nextRandom: .word 0 
	randomRowNumber: .word 0
	randomColumnNumber: .word 0
	rowTotal: .word 0
	columnTotal: .word 0

.text
.globl main
.ent main
main:
	#;  Ask user for size of magic square to generate
	#;	Check that the size is between 2 and 10
	#;	Output an error and ask again if not within bounds
	sizeLoop:
		#; Prints out the "Magic Square Size (2-10) : "
		li $v0, SYSTEM_PRINT_STRING
		la $a0, userOutputSize
		syscall
		#; Reads input from user
		li $v0, SYSTEM_READ_INTEGER
		syscall

		#; moves the input size to a global variable 
		move $t0, $v0
		sw $t0, size

		#; error size checking
		blt $t0, MINIMUM_SIZE, errorSizeMessage
		bgt $t0, MAXIMUM_SIZE, errorSizeMessage
		j keepChecking

		#; error size checking 
		errorSizeMessage:
		#; prints out "Size must be between 2 and 10." and then loops back to reprompt user
		li $v0, SYSTEM_PRINT_STRING
		la $a0, errorSize
		syscall
		#; new line
		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall
		#; new line
		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall

		j sizeLoop

		#; skips to if everything is good 
		keepChecking:

	#;  Ask user for column/row total
	#;	Check that the total is between the square size and 1000
	#;	Output an error and ask again if not within bounds
	magicNumberLoop:
		#; prints out "Magic Number: "
		li $v0, SYSTEM_PRINT_STRING
		la $a0, magicNumber
		syscall
		#; reads user input 
		li $v0, SYSTEM_READ_INTEGER
		syscall
		#; saves input to global variable 
		move $t1, $v0
		sw $t1, magic
		#; error size checking
		blt $t1, $t0, errorMagicMessage
		bgt $t1, MAXIMUM_TOTAL, errorMagicMessage
		j moveOn
		#; prints out "Magic number must be between the square size and 1000."
		errorMagicMessage:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, errorMagic
		syscall
		#; new line
		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall
		#; new line
		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall

		j magicNumberLoop

		moveOn:

	#; Create a magic square

	la $a0, magicSquare
	lw $a1, size
	lw $a2, magic
	jal createMagicSquare
	
	#; Print the magic square

	la $a0, magicSquare
	lw $a1, size
	lw $a2, size
	jal printMatrix


	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main

#; Prints a 2D matrix to the console
#; Arguments:
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
.globl printMatrix
.ent printMatrix
printMatrix:
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	li $t4, 0 # counter

	mul $t3, $t1, $t2 # array size 

	printMatrixLoop:
		#; prints out the integer 
        li $v0, SYSTEM_PRINT_INTEGER
        lw $a0, ($t0)
        syscall
		#; prints out the a space
        li $v0, SYSTEM_PRINT_STRING
        la $a0, space
        syscall

		#; moves the index over, increases count by 1 and subtracts one from the total array size
        addu $t0, $t0, 4
        subu $t3, $t3, 1
        addu $t4, $t4, 1
		#; checks the column size to the count to end the line or not 
        bne $t4, $t2, printMatrixLoop

    endLine:
		#; ends the line 
        li $v0, SYSTEM_PRINT_STRING
        la $a0, newLine
        syscall
		#; resets the count
        li $t4, 0 
        bnez $t3, printMatrixLoop

        li $v0, SYSTEM_PRINT_STRING
        la $a0, newLine
        syscall


	jr $ra
.end printMatrix

#; Gets a random non-negative number between a specified range
#; Uses a linear congruential generator
#;	m = 2^16+1
#;	a = 75
#;	c = 74
#;	newRandom = (previous*a+c)%m
#; Arguments:
#;	$a0 - Minimum Value
#;	$a1 - Maximum Value
#; Global Variables/Constants Used
#;	previousRandom - Used to generate the next value, must be updated each time
#;	m, a, c
#; Returns a random signed integer number
.globl getRandomNumber
.ent getRandomNumber
getRandomNumber:
	#; Multiply the previous random number by A
	#; Add C
	#; Get the remainder by M
	#; Set the previousRandomNumber to this new random value
	#; Use the new random value to generate a random number within the specified range
	#; return randomNumber = newRandom%(maximum-minimum+1)+minimum

	lw $t0, previousRandomNumber
	li $t1, M
	li $t2, A
	li $t3, C 

	mul $t0, $t0, $t2
	add $t0, $t0, $t3
	rem $t0, $t0, $t1
	sw $t0, previousRandomNumber

	move $t0, $a0 # min
	move $t1, $a1 # max

	lw $t2, previousRandomNumber
	sub $t0, $t1, $t0
	add $t0, $t0, 1
	rem $t0, $t2, $t0
	move $v0, $t0 #; returns a number from 0 to n-1 for index of array
	add $t0, $t0, 1

	jr $ra
.end getRandomNumber

#; Creates a magic square 2D matrix
#;
#; Example 3x3 Magic Square with 11 as totals:
#;	4 1 6	4+1+6 = 11
#;  5 3 3	5+3+3 = 11
#;  2 7 2	2+7+2 = 11
#;	
#;	4+5+2 = 11
#;	1+3+7 = 11
#;	6+3+2 = 11
#;	
#; Arguments:
#;	$a0 - &matrix
#;	$a1 - size of matrix
#;	$a2 - row/column desired total
.globl createMagicSquare
.ent createMagicSquare
createMagicSquare:
	#; Initialize Matrix values to 0
	#; loop:
	#; 	Choose a random row # using getRandomNumber
	#; 	Choose a random column # using getRandomNumber
	#; 	Check if the column and row totals are < desired total
	#; 	If both are < than the desired total:
	#; 		Add 1 to matrix[row][column]
	#; Repeat until all rows/columns have a total value equal to the desired value
	subu $sp, $sp, 20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
    sw $ra, 20($sp)

	move $s0, $a0 #;  &matrix
	move $s1, $a1 #;  size of matrix
	move $s2, $a2 #;  row/column desired total
	li $t1, 0 #; used to initialize loop to 0's
	li $t2, 0 #; counter for initializeLoop:
	li $s3, 0 #; counter for randomNumberLoop:
	mul $s4, $a1, $a1

	initializeLoop:
		#; sets the magic square to all 0's
		sw $t1, ($s0) 
		add $s0, $s0, 4
		add $t2, $t2, 1
		bne $t2, $s4, initializeLoop

		move $s0, $a0 #; save address again
		move $t5, $a2

		mul $s4, $a1, $a2
	randomNumberLoop:
	
		li $a0, 1 #; 1 is the min a1 already has the max
	
		jal getRandomNumber
		sw $v0, randomRowNumber #; saves to global variable 

		li $a0, 1 #; 1 is the min a1 already has the max
		jal getRandomNumber
		sw $v0, randomColumnNumber #; saves to global variable 

		#; getting the row total from random numver generator and saving to global 
		move $a0, $s0
		move $a1, $s1
		move $a2, $a1
		lw $a3, randomRowNumber
		jal getRowTotal
		sw $v0, rowTotal

		#; getting the column total from random numver generator and saving to global 
		move $a0, $s0
		move $a2, $a1
		lw $a3, randomColumnNumber
		jal getColumnTotal
		sw $v0, columnTotal
		
		#; saves the row and column totals 
		lw $t6, rowTotal
		lw $t7, columnTotal

		#; ends if the counter is the size x the magic number 
		beq $s3, $s4, endThis

		#; if the row total is less than the magic number check column 
		blt $t6, $s2, checkColumnTotal
		j randomNumberLoop

		checkColumnTotal:
		#; if the column total is less then magic number then add one if not then reloop 
		blt $t7, $s2, addOne
		j randomNumberLoop

		addOne:
		#; goes to the address of the random numbers and adds one uses row major ordering and reloops until size x the magic number is hit
		add $s3, $s3, 1
		lw $t1, randomRowNumber
		lw $t2, randomColumnNumber

		mul $t1, $t1, $a1
		add $t1, $t1, $t2
		mul $t1, $t1, 4
		add $t1, $s0, $t1

		lw $t2, ($t1)
		add $t2, $t2, 1
		sw $t2, ($t1)
		
		j randomNumberLoop
		
	
		endThis:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
    addu $sp, $sp, 20
	jr $ra
.end createMagicSquare

#; Gets the total of the specified column
#; Arguments
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
#;	$a3 - column # to total
#; Returns the total of the column values in the matrix
.globl getColumnTotal
.ent getColumnTotal
getColumnTotal:
	#; goes to the top of the column and loops through the and calculates the sum of the random column 
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	move $t3, $a3

	li $v0, 0
	li $t4, 0 # counter
	
	# mul $t3, $t3, $t1
	add $t3, $t3, 0
	mul $t3, $t3, 4
	add $t0, $t0, $t3

	sumColumnLoop:

	lw $t5, ($t0)
	add $v0, $v0, $t5
	add $t4, $t4, 1
	mul $t6, $t2, 4
	add $t0, $t0, $t6
	
	blt $t4, $t2, sumColumnLoop

	jr $ra
.end getColumnTotal

#; Gets the total of the specified row
#; Arguments
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
#;	$a3 - row # to total
#; Returns the total of the row values in the matrix
.globl getRowTotal
.ent getRowTotal
getRowTotal:
	#; goes to the beginning of the row and loops through the and calculates the sum of the random row
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	move $t3, $a3

	li $v0, 0
	li $t4, 0 # counter
	
	mul $t3, $t3, $t2
	add $t3, $t3, 0
	mul $t3, $t3, 4
	add $t0, $t0, $t3

	sumRowLoop:

	lw $t5, ($t0)
	add $v0, $v0, $t5
	add $t4, $t4, 1
	add $t0, $t0, 4
	
	blt $t4, $t2, sumRowLoop
	jr $ra
.end getRowTotal