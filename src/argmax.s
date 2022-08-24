.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
    li t3, 1 # set t3 to 1 to use in the length-check. 
    blt a1, t3, end # if the length of the array is less than 1, jump to end. 
    li t0, 0 # set t0 to index
    li t1, 0 # set t1 to 0 as the index of the maximal element. 
    
    
    li t5, 0 # set t5 to 0 to use to track the current max number. 

    


loop_start:
	
    beq t0, a1, loop_end # if the loop has checked all elements in the array, jump to loop_end. 
    slli t2, t0, 2 # temp = i*sizeof(int)
    add t2, t2, a0 # set t2 as the start of the array. 
   	lw t4, 0(t2) # save the element of the array into t4. 
    bge t5, t4, loop_continue # if the max-element is greater or equal to current element, do nothing and jump to loop-continue. 
    add t5, t4, x0 # if t5 is less than t4, update the value of t5 to t4. 
    addi t1, t0, 0 # increment the index of the max value if t5 is updated. 
    j loop_continue # jump to loop_continue. 
    



loop_continue:
	addi, t0, t0, 1 # increment the loop counter by 1. 
    j loop_start # loop again. 
    


loop_end:
	# Epilogue
    add a0, t1, x0 # save the index of the max value into a0. 

	ret
end: 
	li a0, 36
    j exit