.globl check_size, check_stride, check_mat_dims, check_matmul_rc

.text
check_size:
    addi t0, x0, 1  # a0 >= 1
    bge a0, t0, passed_check
    li a0 36
    j exit
    
check_stride:
    addi t0, x0, 1  # a0 >= 1
    bge a0, t0, passed_check
    li a0 37
    j exit
    
check_mat_dims: # a0, a1 >= 1
    addi t0, x0, 1
    bge a0, t0, check_width
    li a0 38
    j exit
check_width: 
    bge a1, t0, passed_check
    li a0 38
    j exit
    
 check_matmul_rc: # a0 == a1
    beq a0, a1, passed_check
    li a0 38
    j exit

passed_check:
    jr ra