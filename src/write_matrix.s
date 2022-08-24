.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
    addi sp, sp, -28
    sw s0, 0(sp) # filename
    sw s1, 4(sp) # start of matrix
    sw s2, 8(sp) # rows
    sw s3, 12(sp) # cols
    sw s4, 16(sp) # file descriptor 
    sw s5, 20(sp) # total number of elements
    sw ra, 24(sp) # return address
    
    # save arguments to s registers
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    
    #set up for fopen
    mv a0, s0
    addi a1, x0, 1 # write-only permission
    jal ra fopen
    li t0, -1
    beq a0, t0, fopenError # if a0 == -1, fopenError
    mv s4, a0 # save file descriptor
    
    # write row
    addi sp, sp, -4 # save row number in memory
    sw s2, 0(sp)
    mv a0, s4 # file descriptor
    mv a1, sp # row number (in memory)
    li a2, 1 # write 1 element
    li a3, 4 # sizeof(int)
    jal ra fwrite
    li t0, 1
    bne a0, t0, fwriteError
    
    # write col
    sw s3, 0(sp) # overwrite sp with cols
    mv a0, s4
    mv a1, sp
    li a2, 1
    li a3, 4
    jal ra fwrite
    li t0, 1
    bne a0, t0, fwriteError
    addi sp, sp, 4
    
    # write matrix
    mv a0, s4
    mv a1, s1 # pass in pointer to matrix 
    mul s5, s2, s3 # total number of elements to write
    mv a2, s5
    li a3, 4
    jal ra fwrite
    mul t0, s2, s3
    bne a0, t0, fwriteError
    
    # close the file
    mv a0, s4
    jal ra fclose
    bne a0, zero, fcloseError
    
    
	# Epilogue
    
    lw s0, 0(sp) # filename
    lw s1, 4(sp) # start of matrix
    lw s2, 8(sp) # rows
    lw s3, 12(sp) # cols
    lw s4, 16(sp) # file descriptor 
    lw s5, 20(sp) # total number of elements
    lw ra, 24(sp) # return address
    addi sp, sp, 28
    


	ret
fopenError:
	li a0, 27
    j exit
    
fwriteError:
	li a0, 30
    j exit
    
fcloseError:
	li a0, 28
    j exit
