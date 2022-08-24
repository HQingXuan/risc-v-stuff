.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
	li t0, 1 # check if array length < 1 or stride < 1.
    blt a3, t0, stride_error # stride < 1
    blt a4, t0, stride_error # stride < 1
    blt a2, t0, length_error # length < 1
    addi sp, sp, -28 # allocate 20 bytes for future use. 
    sw s0, 0(sp) # index array0
    sw s1, 4(sp) # index array1
    sw s2, 8(sp) # value of element array0
    sw s3, 12(sp) # value of element array1
    sw s4, 16(sp) # sum of the dot product
    sw s5, 20(sp) # address for array0
    sw s6, 24(sp) # address for array1
    li s0, 0 # index0 = 0
    li s1, 0 # index1 = 0
    li s2, 0 # arr0[s0] = 0
    li s3, 0 # arr1[s1] = 0
    li s4, 0 # sum = 0
    li s5, 0 # set the start of arr0 to 0
    li s6, 0 # set the strat of arr1 to 0
    li t1, 0 # loop counter. 
    li t2, 0 # track the product. 
    li t3, 0 # arr0 step size
    li t4, 0 # arr1 step size
    add s5, s5, a0 # set s5 to the start of arr0
    add s6, s6, a1 # set s6 to the start of arr1
    li t5, 4 # sizeof(int)
    mul t3, a3, t5 # step size of arr0
    mul t4, a4, t5 # step size of arr1

	# Prologue


loop_start:
	beq t1, a2, loop_end # if loop finishes, end.
    
    lw s2, 0(s5) # value of arr0
    lw s3, 0(s6) # value of arr1
    mul t2, s2, s3 # save the product of arr0[i] * arr1[i]
    add s4, s4, t2 # add the product to sum. 
    add s5, s5, t3 # update address arr0
    add s6, s6, t4 # update address arr1
    addi t1, t1, 1 # increment t1 by 1
    j loop_start
    
    




loop_end:
	addi a0, s4, 0 # update a0
    lw s0, 0(sp) # index array0
    lw s1, 4(sp) # index array1
    lw s2, 8(sp) # value of element array0
    lw s3, 12(sp) # value of element array1
    lw s4, 16(sp) # sum of the dot product
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28 # restore stack pointer.  


	# Epilogue
    
	ret
length_error: # length < 1, error and exit. 
	li a0, 36
    j exit

stride_error: # stride < 1, error and exit. 
	li a0, 37
    j exit