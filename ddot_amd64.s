// func Ddot(N int, X []float64, incX int, Y []float64, incY int) float64
TEXT ·Ddot(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX
	MOVQ	Y_data+32(FP), DI
	MOVL	incY+48(FP), BX

	// Check data bounaries
	MOVL	BP, CX
	DECL	CX
	MOVL	CX, DX
	IMULL	AX, CX	// CX = incX * (N - 1)
	IMULL	BX, DX	// DX = incY * (N - 1)
	CMPL	CX, X_len+16(FP)
	JGE		panic
	CMPL	DX, Y_len+40(FP)
	JGE		panic

	// Clear accumulators
	XORPD	X0, X0
	XORPD	X1, X1

	// Setup strides
	SALQ	$3, AX	// AX = sizeof(float64) * incX
	SALQ	$3, BX	// BX = sizeof(float64) * incY

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 pairs to process

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $8
	JNE	with_stride
	CMPQ	BX, $8
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	full_simd_loop:
		// Multiply first two pairs
		MOVUPD	(SI), X2
		MOVUPD	(DI), X3
		MULPD	X2, X3
		// Multiply second two values
		MOVUPD	16(SI), X4
		MOVUPD	16(DI), X5
		MULPD	X4, X5

		// Update data pointers
		ADDQ	$32, SI
		ADDQ	$32, DI

		// Accumulate the results of multiplications
		ADDPD	X3, X0
		ADDPD	X5, X1

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process

	JMP hsum

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 16 * incX
	SALQ	$1, DX 	// DX = 16 * incY

	// Partially optimized loop
	half_simd_loop:
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
		JGE		half_simd_loop	// There are 4 or more pairs to process

hsum:
	// Summ intermediate results from SIMD operations
	ADDPD	X0, X1
	// Horizontal sum
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

panic:
	CALL	runtime·panicindex(SB)
	RET
