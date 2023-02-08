.import check.s
.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use (assumes no out-of-bounds access)
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
    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw ra, 20(sp)

    add a0, x0, a2
    jal check_size

    lw a3, 12(sp)
    add a0, x0, a3
    jal check_stride
    
    lw a4, 16(sp)
    add a0, x0, a4
    jal check_stride
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24
        
loop_start:
    addi sp, sp, -4
    sw s0, 0(sp) # remember s0
    add s0, x0, a0 # save address of arr0
    
    add a0, x0, x0 # init return value
    add t0, x0, x0 # used elements count
    add t1, x0, x0 # init index arr0 (i)
    add t2, x0, x0 # init index arr1 (j)

loop_continue:
    bge t0, a2, loop_end # terminate
    
    slli t3, t1, 2 # byte offset i
    slli t4, t2, 2 # byte offset j
    
    add t3, t3, s0 # address of arr0[i]
    add t4, t4, a1 # address of arr1[j]
    
    lw t3, 0(t3) # value of arr0[i]
    lw t4, 0(t4) # value of arr1[j]
    
    mul t3, t3, t4 # product
    add a0, a0, t3 # sum
    
    addi t0, t0, 1 # increment used count
    add t1, t1, a3 # increment i by stride of arr0
    add t2, t2, a4 # increment j by stride of arr1
    
    j loop_continue
    
loop_end:
    lw s0, 0(sp)
    addi sp, sp 4 # restore s0

    jr ra
