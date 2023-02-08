.import check.s
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
    addi sp, sp, -32
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw ra, 28(sp)
    
    add a0, x0, a1 # check m0
    add a1, x0, a2
    jal check_mat_dims
    
    lw a0, 16(sp) # check m1
    lw a1, 20(sp)
    jal check_mat_dims
    
    lw a0, 8(sp) # check m0 cols == m1 rows
    lw a1, 16(sp)
    jal check_matmul_rc

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    # save dimensions and m1 address (cannot be replaced since we loop back after each row)
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    add s0, x0, a2 # common dimension, so we will never use a2 & a4 in this function
    add s1, x0, a1 # number of rows, so we will never use a1 in this function
    add s2, x0, a5 # number of columns, so we will never use a5 in this function
    add s3, x0, a3 # address of m1, so we will never use a3 in this function
    
    add t0, x0, x0 # index for outer loop

outer_loop_start:
    bge t0, s1, outer_loop_end # are we done with everything?
    add t1, x0, x0 # index for inner loop   
    
inner_loop_start:
    # a0 is correct (address of m0 row)
    
    # a1 (address of m1 column, always first row!)
    slli t2, t1, 2 # byte offset of column
    add a1, s3, t2 # actual address of column
    
    add a2, x0, s0 # a2 (number of dimensions to dot-product)
    li a3, 1 # stride of m0
    add a4, x0, s2 # stride of m1 (number of columns in m1)
    
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw a0, 8(sp)
    sw a6, 12(sp) # CC checker screams at you if you don't save this
    sw ra, 16(sp)
    
    jal dot
    add t2, x0, a0 # temp storage of dot product
    
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw a0, 8(sp)
    lw a6, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    
    sw t2, 0(a6) # write return value
    addi a6, a6, 4 # update address of next element
       
    addi t1, t1, 1 # increment inner loop index
    blt t1, s2, inner_loop_start # next inner loop?
    
inner_loop_end:
    addi t0, t0, 1 # increment outer loop index
    
    slli t2, s0, 2 # byte offset for 1 row of m0
    add a0, a0, t2 # actual address of next row (forgets old one)
    
    j outer_loop_start # next outer loop
    
outer_loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    
    jr ra
