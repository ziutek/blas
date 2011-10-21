// func Ddot(N int, X []float64, incX int, Y []float64, incY int) float64
TEXT ·Ddot(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X+8(FP), SI	// X.data
	MOVL	incX+24(FP), AX
	MOVQ	Y+32(FP), DI	// Y.data
	MOVL	incY+48(FP), BX

	// Clear accumulators
	XORPD	X0, X0
	XORPD	X1, X1

	// Setup strides
	SALQ	$3, AX	// AX = 8 * incX
	SALQ	$3, BX	// BX = 8 * incY

	// Check that there is 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 pairs to process

	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 16 * incX
	SALQ	$1, DX 	// DX = 16 * incY

simd_loop:
	// Multiply first two pairs
	MOVLPD	(SI), X2
	MOVHPD	(SI)(AX*1), X2
	MOVLPD	(DI), X3
	MOVHPD	(DI)(BX*1), X3
	MULPD	X2, X3

	// Update data pointers using long strides
	ADDQ	CX, SI
	ADDQ	DX, DI

	// Multiply second two pairs
	MOVLPD	(SI), X4
	MOVHPD	(SI)(AX*1), X4
	MOVLPD	(DI), X5
	MOVHPD	(DI)(BX*1), X5
	MULPD	X4, X5

	// Update data pointers using long strides
	ADDQ	CX, SI
	ADDQ	DX, DI

	// Accumulate the results of multiplications
	ADDPD	X3, X0
	ADDPD	X5, X1

	SUBQ	$4, BP
	JGE		simd_loop	// There are 4 or more pairs to process

	// Summ all intermediate results from SIMD operations
	ADDPD	X0, X1
	MOVHLPS X1, X0
	ADDSD	X1, X0

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any pair to process
	JE	end

loop:
	// Multiply one pair
	MOVSD	(SI), X2
	MULSD	(DI), X2

	// Update data pointers
	ADDQ	AX, SI
	ADDQ	BX,	DI

	// Accumulate the results of multiplication
	ADDSD	X2, X0

	DECQ	BP
	JNE	loop

end:
	// Return the sum
	MOVSD	X0, r+56(FP)
	RET
