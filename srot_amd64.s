// func Srot(N int, X []float32, incX int, Y []float32, incY int, c, s float32)
TEXT ·Srot(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX
	MOVQ	Y_data+32(FP), DI
	MOVL	incY+48(FP), BX
	MOVSS	c+52(FP), X0
	MOVSS	s+56(FP), X1

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
	SALQ	$2, AX	// AX = sizeof(float32) * incX
	SALQ	$2, BX	// BX = sizeof(float32) * incY

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 2 pairs to process

	// Setup four c in X0, and four s in X1
	SHUFPS	$0,	X0, X0 // (c, c, c, c)
	SHUFPS	$0,	X1, X1 // (s, s, s, s)

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $4
	JNE	with_stride
	CMPQ	BX, $4
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	full_simd_loop:
		// Load four pairs
		MOVUPS	(SI), X2	// x
		MOVUPS	(DI), X3	// y
		MOVAPS	X2, X4	// x
		MOVAPS	X3, X5	// y
		// Givens rotation
		MULPS	X0, X2	// c * x
		MULPS	X1, X3	// s * y
		MULPS	X1, X4	// s * x
		MULPS	X0, X5	// c * y
		ADDPS	X2, X3	// s * y + c * x
		SUBPS	X4, X5	// c * y - s * x
		// Save the result
		MOVUPS	X3, (SI)
		MOVUPS	X5, (DI)
		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process

	JMP	rest

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 8 * incX
	SALQ	$1, DX 	// DX = 8 * incY

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
	
		// Save data pointers for destination
		MOVQ	SI, R8
		MOVQ	DI, R9
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

		// Create two full-vectors
		MOVLHPS	X4, X2
		MOVLHPS	X5, X3
		// Copy them for Y calculaction second
		MOVAPS	X2, X4	// x
		MOVAPS	X3, X5	// y

		// Givens rotation
		MULPS	X0, X2	// c * x
		MULPS	X1, X3	// s * y
		MULPS	X1, X4	// s * x
		MULPS	X0, X5	// c * y
		ADDPS	X2, X3	// s * y + c * x
		SUBPS	X4, X5	// c * y - s * x

		// Unvectorize and save the X
		MOVHLPS	X3, X2
		MOVSS	X3, X4
		MOVSS	X2, X6
		SHUFPS  $0xe1, X3, X3
		SHUFPS  $0xe1, X2, X2
		MOVSS	X4, (R8)
		MOVSS	X3, (R8)(AX*1)
		MOVSS	X6, (SI)
		MOVSS	X2, (SI)(AX*1)

		// Unvectorize and save the Y
		MOVHLPS	X5, X2
		MOVSS	X5, X4
		MOVSS	X2, X6
		SHUFPS  $0xe1, X5, X5
		SHUFPS  $0xe1, X2, X2
		MOVSS	X4, (R9)
		MOVSS	X5, (R9)(BX*1)
		MOVSS	X6, (DI)
		MOVSS	X2, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 2 or more pairs to process

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any value to process
	JE	end

	loop:
		// Load one pair
		MOVSS	(SI), X2
		MOVSS	(DI), X3
	
		MOVSS	X2, X4	// x
		MOVSS	X3, X5	// y
		// Givens rotation
		MULSS	X0, X2	// c * x
		MULSS	X1, X3	// s * y
		MULSS	X1, X4	// s * x
		MULSS	X0, X5	// c * y
		ADDSS	X2, X3	// s * y + c * x
		SUBSS	X4, X5	// c * y - s * x
		// Save the result
		MOVSS	X3, (SI)
		MOVSS	X5, (DI)

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX, DI

		DECQ	BP
		JNE	loop

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
