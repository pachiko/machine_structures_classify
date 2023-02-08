.import check.s
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
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    add a0, x0, a1
    
    jal check_size
    
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 12
    
loop_start:
    add t0, x0, x0 #index = 0
    
loop_continue:
    bge t0, a1, loop_end # terminating condition
    slli t1, t0, 2 # byte-offset
    add t1, t1, a0 # address
    lw t2, 0(t1) # value
    
    bge t2, x0, done # do nothing
    sw x0, 0(t1) # write back
    
done:
    addi t0, t0, 1 # increment index
    j loop_continue # loop again?
    
loop_end:
    jr ra
