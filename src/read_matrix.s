.import check.s
.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # PROLOGUE
    addi sp, sp, -28
    sw s0, 0(sp) # row*
    sw s1, 4(sp) # col*
    sw s2, 8(sp) # file*
    sw s3, 12(sp) # array*
    sw s4, 16(sp) # bytes in array
    sw ra, 20(sp)
    
    # STORE RETURN PTR
    add s0, x0, a1 # return row*
    add s1, x0, a2 # return col*
    
    # READ & CHECK FILE
    add a1, x0, x0 # read permission
    jal fopen
    add s2, x0, a0 # file descriptor
    jal check_file_open # check if file descriptor == -1

    # ALLOCATE BUFFER FOR # ROW, # COL
    addi a0, x0, 8 # 2 x 4 bytes
    jal malloc # allocate memory for fread
    jal check_malloc # check if a0 == 0
    
    # READ # ROW, # COL
    add a1, a0, x0 # buffer
    add a0, x0, s2 # file descriptor
    addi a2, x0, 8 # 2 x 4 bytes
    addi sp, sp, -4
    sw a1, 0(sp)
    jal fread
    
    # CHECK READ
    addi a1, x0, 8 # byte check
    jal check_file_read
    lw a1, 0(sp)
    addi sp, sp 4
    
    # WRITE # ROW # COL, FREE BUFFER
    lw t0, 0(a1) # numRows
    lw t1, 4(a1) # numCols
    sw t0, 0(s0)
    sw t1, 0(s1)
    
    add a0, a1, x0 # move buffer ptr
    jal free # free the buffer
    
    lw t0, 0(s0)
    lw t1, 0(s1)
    
    # ALLOCATE ARRAY
    mul s4, t0, t1 # numElems
    slli s4, s4, 2 # in bytes...
    add a0, x0, s4
    jal malloc # allocate memory for fread
    jal check_malloc # check if a0 == 0
    add s3, a0, x0 # store the array ptr
   
    # SETUP READ ARGS, READ MATRIX
    add a0, x0, s2
    add a1, x0, s3
    add a2, x0, s4
    jal fread # read the matrix
    add a1, x0, s4
    jal check_file_read
         
    # CLOSE FILE
    add a0, x0, s2
    jal fclose
    jal check_file_close
    
    add a0, x0, s3
    
    # EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 28
    
    jr ra
    
    