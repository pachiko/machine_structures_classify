.globl check_size, check_stride, check_mat_dims, check_matmul_rc, check_malloc, check_file_open, check_file_close, check_file_read, check_file_write

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

check_malloc:
    bne a0, x0, passed_check
    li a0 26
    j exit

check_file_open:
    addi t0, x0, -1
    bne a0, t0, passed_check
    li a0 27
    j exit
    
check_file_close:
    addi t0, x0, -1
    bne a0, t0, passed_check
    li a0 28
    j exit
    
check_file_read: # a0 == a1
    beq a0, a1, passed_check
    li a0 29
    j exit

check_file_write:
    beq a0, a1, passed_check
    li a0 30
    j exit
    
passed_check:
    jr ra