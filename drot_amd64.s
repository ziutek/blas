// func Drot(N int, X []float64, incX int, Y []float64, incY int, c, s float64)
TEXT ·Drot(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX
	MOVQ	Y_data+32(FP), DI
	MOVL	incY+48(FP), BX
	MOVSD	c+56(FP), X0
	MOVSD	s+64(FP), X1

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

	// Setup strides
	SALQ	$3, AX	// AX = sizeof(float64) * incX
	SALQ	$3, BX	// BX = sizeof(float64) * incY

	// Check that there are 2 or more pairs for SIMD calculations
	SUBQ	$2, BP
	JL		rest	// There are less than 2 pairs to process

	// Setup two c in X0, and two s in X1
	MOVLHPS	X0, X0 // (c, c)
	MOVLHPS	X1, X1 // (s, s)

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $8
	JNE	with_stride
	CMPQ	BX, $8
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	full_simd_loop:
		// Load two pairs
		MOVUPD	(SI), X2	// x
		MOVUPD	(DI), X3	// y
		MOVAPD	X2, X4	// x
		MOVAPD	X3, X5	// y
		// Givens rotation
		MULPD	X0, X2	// c * x
		MULPD	X1, X3	// s * y
		MULPD	X1, X4	// s * x
		MULPD	X0, X5	// c * y
		ADDPD	X2, X3	// s * y + c * x
		SUBPD	X4, X5	// c * y - s * x
		// Save the result
		MOVUPD	X3, (SI)
		MOVUPD	X5, (DI)
		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$2, BP
		JGE		full_simd_loop	// There are 2 or more pairs to process

	JMP	rest

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 16 * incX
	SALQ	$1, DX 	// DX = 16 * incY

	// Partially optimized loop
	half_simd_loop:
		// Load two pairs
		MOVLPD	(SI), X2
		MOVHPD	(SI)(AX*1), X2
		MOVLPD	(DI), X3
		MOVHPD	(DI)(BX*1), X3
		MOVAPD	X2, X4	// x
		MOVAPD	X3, X5	// y
		// Givens rotation
		MULPD	X0, X2	// c * x
		MULPD	X1, X3	// s * y
		MULPD	X1, X4	// s * x
		MULPD	X0, X5	// c * y
		ADDPD	X2, X3	// s * y + c * x
		SUBPD	X4, X5	// c * y - s * x
		// Save the result
		MOVLPD	X3, (SI)
		MOVHPD	X3, (SI)(AX*1)
		MOVLPD	X5, (DI)
		MOVHPD	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$2, BP
		JGE		half_simd_loop	// There are 2 or more pairs to process

rest:
	// Undo last SUBQ
	ADDQ	$2,	BP

	// Check that are there any value to process
	JE	end

	// Load one pair
	MOVSD	(SI), X2
	MOVSD	(DI), X3

	MOVSD	X2, X4	// x
	MOVSD	X3, X5	// y
	// Givens rotation
	MULSD	X0, X2	// c * x
	MULSD	X1, X3	// s * y
	MULSD	X1, X4	// s * x
	MULSD	X0, X5	// c * y
	ADDSD	X2, X3	// s * y + c * x
	SUBSD	X4, X5	// c * y - s * x
	// Save the result
	MOVSD	X3, (SI)
	MOVSD	X5, (DI)

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
