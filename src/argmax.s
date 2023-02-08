.import check.s
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
    addi sp, sp -4 # store s0 value
    sw s0, 0(sp)
    add s0, x0, a0 # address of array in s0

    addi t0, x0, 1 # index of iterator, start checking for next
    add a0, x0, x0 # index of the max
    
    lw t2, 0(s0) # load the first
    addi t2, t2, 1 # + 1 since we prefer lower index if tied
        
loop_continue:
    bge t0, a1, loop_end # terminate
    slli t1, t0, 2 # byte offset
    add t1, t1, s0 # address of element
    lw t1, 0(t1) # value of element

    blt t1, t2, done # Do nothing
    add a0, x0, t0 # update index
    addi t2, t1, 1 # update max + 1
    
done:
    addi t0, t0, 1 # increment iterator
    j loop_continue
    
loop_end:
    lw s0, 0(sp)
    addi sp, sp 4 # restore s0 value

    jr ra
