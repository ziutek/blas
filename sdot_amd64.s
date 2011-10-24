// func Sdot(N int, X []float32, incX int, Y []float32, incY int) float32
TEXT ·Sdot(SB), 7, $0
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
	XORPS	X0, X0

	// Setup strides
	SALQ	$2, AX	// AX = sizeof(float32) * incX
	SALQ	$2, BX	// BX = sizeof(float32) * incY

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 pairs to process

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $4
	JNE	with_stride
	CMPQ	BX, $4
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	full_simd_loop:
		// Multiply four pairs
		MOVUPS	(SI), X2
		MOVUPS	(DI), X3
		MULPS	X2, X3

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		// Accumulate the results of multiplications
		ADDPS	X3, X0

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process

	JMP hsum

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// 8 = 16 * incX
	SALQ	$1, DX 	// 8 = 16 * incY

	// Partially optimized loop
	half_simd_loop:
		// Load first two pairs
		MOVSS	(SI), X2
		MOVSS	(SI)(AX*1), X4
		MOVSS	(DI), X3
		MOVSS	(DI)(BX*1), X5

		// Create two half-vectors
		UNPCKLPS	X4, X2
		UNPCKLPS	X5, X3

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load second two pairs
		MOVSS	(SI), X4
		MOVSS	(SI)(AX*1), X6
		MOVSS	(DI), X5
		MOVSS	(DI)(BX*1), X7

		// Create two half-vectors
		UNPCKLPS	X6, X4
		UNPCKLPS	X7, X5

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI
		
		// Create two full-vectors
		MOVLHPS	X4, X2
		MOVLHPS	X5, X3

		// Multiply them
		MULPS	X2, X3

		// Accumulate the results of multiplications
		ADDPS	X3, X0

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process

hsum:
	// Horizontal sum
	MOVHLPS X0, X3
	ADDPS	X0, X3
	MOVSS	X3, X0
	SHUFPS	$0xe1, X3, X3
	ADDSS	X3, X0

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any pair to process
	JE	end

	loop:
		// Multiply one pair
		MOVSS	(SI), X2
		MULSS	(DI), X2

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX,	DI

		// Accumulate the results of multiplication
		ADDSS	X2, X0

		DECQ	BP
		JNE	loop

end:
	// Return the sum
	MOVSS	X0, r+56(FP)
	RET

panic:
	CALL	runtime·panicslice(SB)
	RET
