// func Dnrm2(N int, X []float64, incX int) float64
TEXT ·Dnrm2(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X+8(FP), SI	// X.data
	MOVL	incX+24(FP), AX

	// Clear accumulators
	XORPD	X0, X0
	XORPD	X1, X1

	// Setup stride
	SALQ	$3, AX	// AX = 8 * incX

	// Check that there is 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 values to process

	// Setup long stride
	MOVQ	AX, CX
	SALQ	$1, CX 	// CX = 16 * incX

simd_loop:
	// Multiply first two values
	MOVLPD	(SI), X2
	MOVHPD	(SI)(AX*1), X2
	MULPD	X2, X2

	// Update data pointer using long stride
	ADDQ	CX, SI

	// Multiply second two pairs
	MOVLPD	(SI), X4
	MOVHPD	(SI)(AX*1), X4
	MULPD	X4, X4

	// Update data pointer using long stride
	ADDQ	CX, SI

	// Accumulate the results of multiplications
	ADDPD	X2, X0
	ADDPD	X4, X1

	SUBQ	$4, BP
	JGE		simd_loop	// There are 4 or more values to process

	// Summ all intermediate results from SIMD operations
	ADDPD	X0, X1
	MOVHLPS X1, X0
	ADDSD	X1, X0

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any value to process
	JE	end

loop:
	// Multiply one pair
	MOVSD	(SI), X2
	MULSD	X2, X2

	// Update data pointers
	ADDQ	AX, SI
	ADDQ	BX,	DI

	// Accumulate the results of multiplication
	ADDSD	X2, X0

	DECQ	BP
	JNE	loop

end:
	// Return the square root of sum
	SQRTSD	X0, X0
	MOVSD	X0, r+32(FP)
	RET
