//func Sscal(N int, alpha float32, X []float32, incX int)
TEXT ·Sscal(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVSS	alpha+4(FP), X0
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX

	// Check data bounaries
	MOVL	BP, CX
	DECL	CX
	IMULL	AX, CX	// CX = incX * (N - 1)
	CMPL	CX, X_len+16(FP)
	JGE		panic

	// Setup stride
	SALQ	$2, AX	// AX = sizeof(float32) * incX

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 values to process

	// Setup four alphas in X0
	SHUFPS	$0, X0, X0

	// Check if incX != 1
	CMPQ	AX, $4
	JNE	with_stride

	// Fully optimized loop (for incX == 1)
	full_simd_loop:
		// Load four values and scale
		MOVUPS	(SI), X2
		MULPS	X0, X2
		// Save scaled values
		MOVUPS	X2, (SI)

		// Update data pointers
		ADDQ	$16, SI

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process

	JMP	rest

with_stride:
	// Setup long stride
	MOVQ	AX, CX
	SALQ	$1, CX 	// CX = 8 * incX

	// Partially optimized loop
	half_simd_loop:
		// Load first two values
		MOVSS	(SI), X2
		MOVSS	(SI)(AX*1), X4

		// Create a half-vector
		UNPCKLPS	X4, X2

		// Save data pointer
		MOVQ	SI, DI
		// Update data pointer using long stride
		ADDQ	CX, SI

		// Load second two values
		MOVSS	(SI), X4
		MOVSS	(SI)(AX*1), X6

		// Create a half-vector
		UNPCKLPS	X6, X4

		// Create a full-vector
		MOVLHPS	X4, X2

		// Scale the full-vector
		MULPS	X0, X2

		// Unvectorize and save the result
		MOVHLPS	X2, X3
		MOVSS	X2, X4
		MOVSS	X3, X5
		SHUFPS  $0xe1, X2, X2
		SHUFPS  $0xe1, X3, X3
		MOVSS	X4, (DI)
		MOVSS	X2, (DI)(AX*1)
		MOVSS	X5, (SI)
		MOVSS	X3, (SI)(AX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any value to process
	JE	end

	loop:
		// Load from X and save scaled
		MOVSS	(SI), X2
		MULSS	X0, X2
		MOVSS	X2, (SI)

		// Update data pointers
		ADDQ	AX, SI

		DECQ	BP
		JNE	loop

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
