.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

	# check number of arguments
    li t0, 5
    bne a0, t0, argumentError
    
    #Prologue:
    addi sp, sp, -48
    sw s0, 0(sp) # # argv
    sw s1, 4(sp) # whether print classification
    sw s2, 8(sp) # pointer to h in heap
    sw s3, 12(sp) # pointer to m0 in heap
    sw s4, 16(sp) # pointer to m1 in heap
    sw s5, 20(sp) # pointer to input in heap
    sw s6, 24(sp) # number of rows and cols of m0 in stack
    sw s7, 28(sp) # number of rows and cols of m1 in stack
    sw s8, 32(sp) # number of rows and cols of input in stack
    sw s9, 36(sp) # pointer to o in heap
    sw s10, 40(sp) # result of argmax
    sw ra, 44(sp) # return address
    
    mv s0, a1
    mv s1, a2

	# Read pretrained m0
    # save rows and cols on stack
    addi sp, sp, -24
    mv s6, sp
    lw a0, 4(s0)
    addi a1, s6, 0
    addi a2, s6, 4
    jal ra read_matrix
    mv s3, a0 # save start of m0
    


	# Read pretrained m1
    addi s7, sp, 8 # move 2 bytes up to store rows and cols for m1
    lw a0, 8(s0) # locate filepath for m1 
    addi a1, s7, 0
    addi a2, s7, 4
    jal ra read_matrix
    mv s4, a0 # save start of m1
    


	# Read input matrix
    addi s8, sp, 16 # move another 2 bytes up to store rows and cols for input
    lw a0, 12(s0)
    addi a1, s8, 0
    addi a2, s8, 4
    jal ra read_matrix
    mv s5, a0 # save start of input


	# Compute h = matmul(m0, input)
    # 1. calculate the space to malloc: rows of m0 * cols of input
    lw t0, 0(s6) # rows of m0
    lw t1, 4(s8) # cols of input
    mul a0, t0, t1 # total elements
    slli a0, a0, 2 # total bytes
    jal ra malloc
    beq a0, x0, mallocError
    mv s2, a0 # set s2 to the pointer to h in heap
    mv a0, s3
    lw a1, 0(s6)
    lw a2, 4(s6)
    mv a3, s5
    lw a4, 0(s8)
    lw a5, 4(s8)
    mv a6, s2 # set h as the start of integer array where result can be stored. 
    jal ra matmul
    


	# Compute h = relu(h)
    lw t0, 0(s6) # height/rows of m0
    lw t1, 4(s8) # width/cols of input
    mul a1, t0, t1
    mv a0, s2
    jal ra, relu
    
   
	# Compute o = matmul(m1, h)
    lw t0, 0(s7)
    lw t1, 4(s8) # note that cols of h is the same as cols of input
    mul a0, t0, t1 # total elements
    slli a0, a0, 2 # total bytes
    jal ra malloc
    beq a0, x0, mallocError
    mv s9, a0 # set s9 to the pointer to o in heap
    mv a0, s4
    lw a1, 0(s7)
    lw a2, 4(s7)
    mv a3, s2
    lw a4, 0(s6)
    lw a5, 4(s8)
    mv a6, s9
    jal ra matmul
    
	# Write output matrix o
    lw a0, 16(s0) # find the output filepath
    mv a1, s9 # pass in the start of o
    lw a2, 0(s7) # row of m1
    lw a3, 4(s8) # col of input
    jal ra write_matrix

	# Compute and return argmax(o)
    mv a0, s9 # pass in the star of o
    lw t0, 0(s7) 
    lw t1, 4(s8)
    mul a1, t0, t1 # total number of elements
    jal ra argmax
    mv s10, a0
    bne s1, x0, finish # continue to print if print classification is set to 0
    mv a0, s10
    jal ra print_int # print argmax(o)
    li a0, '\n'
    jal ra print_char # print new line
    


	# If enabled, print argmax(o) and newline
    
finish:
	addi sp, sp, 24 # restore the space used for rows and cols for m0, m1, and input
    mv a0, s2
    jal ra free # free h
    mv a0, s3
    jal ra free # free m0
    mv a0, s4
    jal ra free # free m1
    mv a0, s5
    jal ra free # free input
    mv a0, s9
    jal ra free # free o
    
    mv a0, s10 # set a0 to the result of argmax(o)
    
    
    lw s0, 0(sp) # # argv
    lw s1, 4(sp) # whether print classification
    lw s2, 8(sp) # pointer to h in heap
    lw s3, 12(sp) # pointer to m0 in heap
    lw s4, 16(sp) # pointer to m1 in heap
    lw s5, 20(sp) # pointer to input in heap
    lw s6, 24(sp) # number of rows and cols of m0 in stack
    lw s7, 28(sp) # number of rows and cols of m1 in stack
    lw s8, 32(sp) # number of rows and cols of input in stack
    lw s9, 36(sp) # pointer to o in heap
    lw s10, 40(sp) # result of argmax
    lw ra, 44(sp)
    addi sp, sp, 48
    


	ret

argumentError:
	li a0, 31
    j exit

mallocError:
	li a0, 26
    j exit