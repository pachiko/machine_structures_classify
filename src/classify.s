.import check.s
.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # PROLOGUE
    addi sp, sp, -28
    sw s0, 0(sp) # argv
    sw s1, 4(sp) # silent mode
    sw s2, 8(sp) # temp row*
    sw s3, 12(sp) # temp col*
    sw s4, 16(sp) # temp h*
    sw s5, 20(sp) # temp o*
    sw ra, 24(sp)
    
    # SAVE INPUT
    add s0, x0, a1 # argv
    add s1, x0, a2 # silent mode

    # check arg count
    jal check_classify_arg_count # just check if a0 == 5

    # prepare temporary row & col *
    addi a0, x0, 4
    jal malloc
    jal check_malloc
    add s2, a0, x0
    
    addi a0, x0, 4
    jal malloc
    jal check_malloc
    add s3, a0, x0

    # Read pretrained m0
    lw a0, 4(s0)
    add a1, s2, x0
    add a2, s3, x0
    jal read_matrix
    
    lw t0, 0(s2)
    lw t1, 0(s3)
    
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw a0, 8(sp)
    
    # Read pretrained m1
    lw a0, 8(s0)
    add a1, s2, x0
    add a2, s3, x0
    jal read_matrix
    
    lw t0, 0(s2)
    lw t1, 0(s3)
    
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw a0, 8(sp)

    # Read input matrix
    lw a0, 12(s0)
    add a1, s2, x0
    add a2, s3, x0
    jal read_matrix
    
    lw t0, 0(s2)
    lw t1, 0(s3)
    
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw a0, 8(sp)

    # malloc h
    lw t0, 24(sp) # rows in m0
    lw t1, 4(sp) # cols in input
    mul t0, t0, t1 # elements
    slli a0, t0, 2 # bytes
    jal malloc
    jal check_malloc
    add s4, x0, a0
    
    # Compute h = matmul(m0, input)
    lw a0, 32(sp) # & to m0
    
    lw a1, 24(sp) # rows m0
    
    lw a2, 28(sp) # cols m0
    
    lw a3, 8(sp) # & to input
    
    lw a4, 0(sp) # rows input
    
    lw a5, 4(sp) # cols input 
    
    add a6, x0, s4 # & to h
    jal matmul

    # Compute h = relu(h)
    add a0, x0, s4 # & to h
    
    lw t0, 24(sp) # rows in m0
    lw t1, 4(sp) # cols in input
    mul a1, t0, t1 # elements
    
    jal relu

    # malloc o
    lw t0, 12(sp) # rows in m1
    lw t1, 4(sp) # cols in h = cols in input
    mul t0, t0, t1 # elements
    slli a0, t0, 2 # bytes
    jal malloc
    jal check_malloc
    add s5, x0, a0

    # Compute o = matmul(m1, h)
    lw a0, 20(sp) # & to m1
    
    lw a1, 12(sp) # rows m1
    
    lw a2, 16(sp) # cols m1
    
    add a3, x0, s4 # & to h
    
    lw a4, 24(sp) # rows h = rows in m0
    
    lw a5, 4(sp) # cols h = cols in input
    
    add a6, x0, s5 # & to o
    jal matmul

    # Write output matrix o
    lw a0, 16(s0) # file
    add a1, x0, s5 # o
    lw a2, 12(sp) # rows o = rows m1
    lw a3, 4(sp) # cols o = cols h = cols in input
    
    jal write_matrix

    # Compute and return argmax(o)
    add a0, x0, s5
    
    lw t0, 12(sp) # rows in m1
    lw t1, 4(sp) # cols in h = cols in input
    mul a1, t0, t1 # elements
    
    jal argmax
    add s0, x0, a0 # save retval in argv

    # FREE ALL THE SHIT m0, m1, input, h, o, and row*, col*
    lw a0, 32(sp)
    jal free
    
    lw a0, 20(sp)
    jal free
    
    lw a0, 8(sp)
    jal free
    
    add a0, x0, s2
    jal free
    
    add a0, x0, s3
    jal free
    
    add a0, x0, s4
    jal free
    
    add a0, x0, s5
    jal free
    
    # RETURN STACK POINTER
    addi sp, sp 36
   
    # If enabled, print argmax(o) and newline
    bne s1, x0, dont_print_argmax
    add a0, x0, s0
    jal print_int
    li a0 '\n'
    jal print_char
    
    dont_print_argmax:
    add a0, x0, s0
    
    # EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    
    jr ra


    