import numpy as np
import fxpmath as fxp
a = ["0x7ff8940","0x7f19f0d","0x736ea","0x1d92f"]
b=["0x407d4","0x1f6db","0x6a115","0x7f888cf"]
def fixed_to_float(string):
    return fxp.Fxp(string, signed = True, n_word= 27, n_frac=20, overflow='wrap' ).get_val()

def float_to_fixed(num):
    
    fixed_value = int(round(num * (2**20)))  # Multiply by 2^20 for fixed-point conversion
    
    # Handle overflow
    if fixed_value > (2**26) - 1:
        fixed_value = (2**26) - 1
    elif fixed_value < -(2**26):
        fixed_value = -(2**26)
        
    return fixed_value & 0x7FFFFFF  # Ensure 27 bits

def matrix_multiplication():
    n = int(input())  # Rows of A
    m = int(input())  # Columns of A. Rows of B
    p = int(input())  # Columns of B
    
    matrixA = []  # Initialize matrix A
    iterator = 0
    for i in range(n):
        row = []
        for j in range(m):
            hex_val = input().strip()
            row.append(fixed_to_float(hex_val))
            iterator+=1
        matrixA.append(row)
         
    matrixB = []
    iterator=0
    for i in range(m):
        row = []
        for j in range(p):
            hex_val = input().strip()
            row.append(fixed_to_float(hex_val))
            iterator += 1
        matrixB.append(row)

    # Convert matrices to NumPy arrays and multiply them in floating-point
    matrixAfloat = np.array(matrixA)
    matrixBfloat = np.array(matrixB)
    float_mult = np.matmul(matrixAfloat, matrixBfloat)

    for row in float_mult:
        for element in row:
            print(element)

    # Perform fixed-point multiplication
    fixed_mult = [[0 for _ in range(p)] for _ in range(n)]
    
    for i in range(n):  # Iterate through rows of matrixA
        for j in range(p):  # Iterate through columns of matrixB
            sum = 0
            for k in range(m):  # Iterate through columns of matrixA/rows of matrixB
                sum += matrixA[i][k] * matrixB[k][j]
            fixed_mult[i][j] = sum
            
    for row in fixed_mult:
        for element in row:
            print(element)

if __name__ == "__main__":
    matrix_multiplication()
