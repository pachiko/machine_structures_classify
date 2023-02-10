.import check.s
.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # PROLOGUE
    addi sp, sp, -20
    sw s0, 0(sp) # FILE PATH/ DESCRIPTOR
    sw s1, 4(sp) # MATRIX
    sw s2, 8(sp) # ROWS, THEN TUPLE
    sw s3, 12(sp) # COLS, then ELEMENTS
    sw ra, 16(sp)
    
    # SAVE DATA
    add s0, a0, x0
    add s1, a1, x0
    add s2, a2, x0
    add s3, a3, x0
    
    # OPEN FILE FOR WRITE
    addi a1, x0, 1
    jal fopen
    add s0, a0, x0 # FILE DESCRIPTOR
    jal check_file_open
    
    # MALLOC ROW COL TUPLE
    addi a0, x0, 8
    jal malloc
    jal check_malloc
    
    # WRITE ROW COL TO MEM
    sw s2, 0(a0)
    sw s3, 4(a0)
    mul s3, s2, s3 # elements
    add s2, x0, a0 # save tuple

    # WRITE ROW COL TO FILE
    add a0, x0, s0 # file
    add a1, x0, s2 # ptr to write
    addi a2, x0, 2 # 2 elements
    addi a3, x0, 4 # 4 bytes each
    jal fwrite
    addi a1, x0, 2 # check 2 elements
    jal check_file_write
    
    # FREE TUPLE
    add a0, x0, s2
    jal free
    
    # WRITE MATRIX TO FILE
    add a0, x0, s0 # file
    add a1, x0, s1 # ptr to write
    add a2, s3, x0 # m x n elements
    addi a3, x0, 4 # 4 bytes each
    jal fwrite
    add a1, x0, s3 # check m x n elements
    jal check_file_write
    
    # CLOSE FILE
    add a0, x0, s0 # file
    jal fclose
    jal check_file_close
        
    # EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    
    jr ra
