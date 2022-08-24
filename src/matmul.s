.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
	li t0, 1 # set t0 = 1 for error checks

	# Error checks
    blt a1, t0, error # check # of rows of m0 less than 1
    blt a2, t0, error # check # of cols of m0 less than 1
    blt a4, t0, error # check # of rows of m1 less than 1
    blt a5, t0, error # check # of cols of m1 less than 1
    bne a2, a4, error # check if col of m0 == row of m1
    
	# Prologue
    li t1, 4 # sizeof(int)
    mul t5, a2, t1 # track the distance that arr0 will update after each loop. 
    
    addi sp, sp, -20 # initialize save register
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    
    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a0 # keep track of arr0 index
    mv s3, a3 # keep track of arr1 index
    mv s4, a6 # keep track of arr2 index
    
outer_loop_start:
	beq s0, a1, outer_loop_end # loop checks all rows of arr0, jump to outer loop end. check height	
    li s1, 0 # reset the inner loop counter.     
    j inner_loop_start # jump to inner loop when outer loop is set. 

inner_loop_start:
	beq s1, a5, inner_loop_end # check width of m1, if finish, jump to loop end. 
    
    addi sp, sp, -60 # allocate space for stack
    sw ra, 0(sp) # save return address
    sw a0, 4(sp) 
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp) # save a0-a4 since these will be used by dot. 
    sw s0, 24(sp)
    sw s1, 28(sp)
    sw t1, 32(sp)
    sw s2, 36(sp) # save s0-s2
    sw a5, 40(sp)
    sw a6, 44(sp)
    sw s3, 48(sp)
    sw s4, 52(sp)
    sw t5, 56(sp)
      
    addi a0, s2, 0 # set the function address of arr0 
    addi a1, s3, 0 # set the function address of arr1
    addi a2, a2, 0 # set the function element number
    addi a3, x0, 1 # set the function stride for arr0
    addi a4, a5, 0 # set the function stride for arr1
    
    jal ra dot # call function dot with parameters. 
      
    lw s4, 52(sp)
    sw a0, 0(s4) # save the dot product to the fitting index of result array.
    addi, s4, s4, 4 # move the index of result array to next place. 
    
    lw ra, 0(sp) # save return address
    lw a0, 4(sp) 
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp) # save a0-a4 since these will be used by dot. 
    lw s0, 24(sp)
    lw s1, 28(sp)
    lw t1, 32(sp)
    lw s2, 36(sp) # save s0-s2
    lw a5, 40(sp)
    lw a6, 44(sp)
    lw s3, 48(sp)
    lw t5, 56(sp)
    
    addi sp, sp 60 # move up the sp pointer.  
    addi s3, s3, 4 # increment the index of arr1 for next loop. 
    addi s1, s1, 1 # update the inner loop counter by 1. 
   
    j inner_loop_start # loop again. 
       
inner_loop_end:
	addi s0, s0, 1 # increment outer loop counter by 1
    addi s3, a3, 0 # reset arr1 index tracker to default. 
    add s2, s2, t5 # update to the next index of arr0 for next loop.  
    j outer_loop_start # outer loop again. 

outer_loop_end:
   
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20 # move up the sp pointer

	# Epilogue

	ret
error:
	li a0, 38
    j exit
