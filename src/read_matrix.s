.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
    addi sp, sp, -32 # move down sp pointer to save registers
    sw s0, 0(sp) # stores pointer to the filename
    sw s1, 4(sp) # store number of rows of the matrix
    sw s2, 8(sp) # store number of cols of the matrix
    sw s3, 12(sp) # store file descriptor of the file
    sw s4, 16(sp) # store the total number of element for malloc (row * col)
    sw s5, 20(sp) # read file counter
    sw s6, 24(sp) # pointer to the allocated space
    sw ra, 28(sp) # return address
    
    mv s0, a0 # save filename to s0
    mv s1, a1 # save num of rows to s1
    mv s2, a2 # save num of cols to s2

	#set up for fopen
    mv a0, s0 # set a0 as pointer to filename
    addi a1, x0, 0 # set a1 to be read-only permission.
    jal ra, fopen # use fopen to open file
    li t0, -1
    beq a0, t0, fopenError # if a0 == -1, file open failed. 
    mv s3, a0 # save file descriptor in s3. 
    
    #set up for fread
    # 1. read rows first
    mv a1, s1 # set a1 to pointer to rows
    addi a2, x0, 4 # read 4 bytes
    jal ra, fread # use fread function
    li t1, 4
    bne a0, t1, freadError # if the number of bytes read returned does not match a2, report error. 
    
    # 2. read cols
    mv a0, s3
    mv a1, s2 # set a1 to pointer to cols
    addi a2, x0, 4 # read 4 bytes
    jal ra, fread # use fread function
    li t2, 4
    bne a0, t2, freadError # report error if byte length does not match
    
    # calculate space for malloc
    lw t3, 0(s1) # load number of rows to t3
    lw t4, 0(s2) # load number of cols to t4
    mul s4, t3, t4 # save the size of matrix to s4
    li t5, 4
    mul a0, s4, t5 # calculate the number of bytes needed for the matrix
    jal ra, malloc # use malloc function
    beq a0, x0, mallocError # if return value is 0, malloc failed
    mv s6, a0 # save pointer to the allocated space. 
    li s5, 0 # set the read file counter to 0
   
readFile:
	mv a0, s3 # pass in file descriptor 
    slli t0, s5, 2 # calculate the offset of address
    add a1, s6, t0 # pass in argument as the starting address of the buffer
    addi a2, x0, 4 # read 4 bytes
    jal ra fread # use fread function
    li t2, 4
    bne a0, t2, freadError
    addi s5, s5, 1 # increment the file read counter by 1
    bne s5, s4, readFile # if the counter is less than total element, continue read from file. 
    
    #after reading the file, close the file. 
    mv a0, s3 # pass in file descriptor for fclose
    jal ra, fclose # use fclose function
    bne a0, x0, fcloseError # if return value is -1, fclose failed. 
    mv a0, s6
    
	# Epilogue
    lw s0, 0(sp) # stores pointer to the filename
    lw s1, 4(sp) # store number of rows of the matrix
    lw s2, 8(sp) # store number of cols of the matrix
    lw s3, 12(sp) # store file descriptor of the file
    lw s4, 16(sp) # store the total number of element for malloc (row * col)
    lw s5, 20(sp) # read file counter
    lw s6, 24(sp) # pointer to the allocated space
    lw ra, 28(sp)
    
    addi sp, sp, 32
    
    


	ret

fopenError:
	li a0, 27
    j exit

mallocError:
	li a0, 26
    j exit
    
fcloseError:
	li a0, 28
    j exit

freadError:
	li a0, 29
    j exit
