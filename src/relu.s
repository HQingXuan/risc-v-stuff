.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	li t1, 1 # set t1 to 1 to use in the later if-statement. 
	blt a1, t1, end # check whether the length is less than 1, if so, jump to exit. 
	# Prologue
    
    li t0, 0 # set t0 to i.
    li t2, 0 # set t2 to 0 to use as index for the integer array.
    add t2, a0, x0 # find the address of the current element in the array. 
    


loop_start:


beq t0, a1, loop_end # if the loop has checked all element of the array, jump to loop_end. 
slli t2, t0, 2 # temp = i*sizeof(int)
add t2, t2, a0 # find the address of the current element in the array. 
lw t3, 0(t2) # save the element of the current element in the array into t3. 
bge t3, x0, loop_continue # if the element is greater or equal to 0, do nothing and jump to loop_continue. 
sw x0, 0(t2) # otherwise, set the current element of the array to 0. 
j loop_continue # after setting current elemt to 0, jump to loop_continue. 



loop_continue:
addi t0, t0, 1 # increment the loop counter by 1. 
j loop_start # loop again. 


loop_end:


	# Epilogue


	ret
end: 
li a0, 36 # set a0 to 36 as doc says. 
j exit # exit the app. 