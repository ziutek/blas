//func Saxpy(N int, alpha float32, X []float32, incX int, Y []float32, incY int)
TEXT ·Saxpy(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVSS	alpha+4(FP), X0
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX
	MOVQ	Y_data+32(FP), DI
	MOVL	incY+48(FP), BX

	// Setup 0, 1, -1
	PCMPEQW	X1, X1
	PCMPEQW	X8, X8
	XORPS	X7, X7	// 0
	PSLLL	$25, X1
	PSRLL	$2, X1	// 1
	PSLLL	$31, X8
	ORPS	X1, X8	// -1

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

	// Check that is there any work to do
	UCOMISS	X0, X7	
	JE	end	// alpha == 0

	// Setup strides
	SALQ	$2, AX	// AX = sizeof(float32) * incX
	SALQ	$2, BX	// BX = sizeof(float32) * incY

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 pairs to process

	// Setup four alphas in X0
	SHUFPS	$0, X0, X0

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $4
	JNE	with_stride
	CMPQ	BX, $4
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	UCOMISS	X0, X1
	JE	full_simd_loop_sum	// alpha == 1
	UCOMISS	X0, X8
	JE	full_simd_loop_diff	// alpha == -1

	full_simd_loop:
		// Load four pairs and scale
		MOVUPS	(SI), X2
		MOVUPS	(DI), X3
		MULPS	X0, X2
		// Save sum
		ADDPS	X2, X3
		MOVUPS	X3, (DI)

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process
	JMP	rest

	full_simd_loop_sum:
		// Load four pairs
		MOVUPS	(SI), X2
		MOVUPS	(DI), X3
		// Save a sum
		ADDPS	X2, X3
		MOVUPS	X3, (DI)

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$4, BP
		JGE		full_simd_loop_sum	// There are 4 or more pairs to process
	JMP	rest_sum

	full_simd_loop_diff:
		// Load four pairs
		MOVUPS	(SI), X2
		MOVUPS	(DI), X3
		// Save a difference
		SUBPS	X2, X3
		MOVUPS	X3, (DI)

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$4, BP
		JGE		full_simd_loop_diff	// There are 4 or more pairs to process
	JMP	rest_diff

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 8 * incX
	SALQ	$1, DX 	// DX = 8 * incY

	UCOMISS	X0, X1
	JE	half_simd_loop_sum	// alpha == 1
	UCOMISS	X0, X8
	JE	half_simd_loop_diff	// alpha == -1

	half_simd_loop:
		// Load first two pairs
		MOVSS	(SI), X2
		MOVSS	(SI)(AX*1), X4
		MOVSS	(DI), X3
		MOVSS	(DI)(BX*1), X5

		// Create two half-vectors
		UNPCKLPS	X4, X2
		UNPCKLPS	X5, X3

		// Save data pointer for destination
		MOVQ	DI, R8
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

		// Scale and sum
		MULPS	X0, X2
		ADDPS	X2, X3

		// Unvectorize and save the result
		MOVHLPS	X3, X5
		MOVSS	X3, X4
		MOVSS	X5, X6
		SHUFPS  $0xe1, X3, X3
		SHUFPS  $0xe1, X5, X5
		MOVSS	X4, (R8)
		MOVSS	X3, (R8)(BX*1)
		MOVSS	X6, (DI)
		MOVSS	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process
	JMP rest

	half_simd_loop_sum:
		MOVSS	(DI), X2
		MOVSS	(DI)(BX*1), X3
		ADDSS	(SI), X2
		ADDSS	(SI)(AX*1), X3
		MOVSS	X2, (DI)
		MOVSS	X3, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		MOVSS	(DI), X4
		MOVSS	(DI)(BX*1), X5
		ADDSS	(SI), X4
		ADDSS	(SI)(AX*1), X5
		MOVSS	X4, (DI)
		MOVSS	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop_sum	// There are 4 or more pairs to process
	JMP rest_sum

	half_simd_loop_diff:
		MOVSS	(DI), X2
		MOVSS	(DI)(BX*1), X3
		SUBSS	(SI), X2
		SUBSS	(SI)(AX*1), X3
		MOVSS	X2, (DI)
		MOVSS	X3, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		MOVSS	(DI), X4
		MOVSS	(DI)(BX*1), X5
		SUBSS	(SI), X4
		SUBSS	(SI)(AX*1), X5
		MOVSS	X4, (DI)
		MOVSS	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop_diff	// There are 4 or more pairs to process
	JMP rest_diff

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP
	// Check that are there any value to process
	JE	end
	loop:
		// Load from X and scale
		MOVSS	(SI), X2
		MULSS	X0, X2
		// Save sum in Y
		ADDSS	(DI), X2
		MOVSS	X2, (DI)

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX, DI

		DECQ	BP
		JNE	loop
	RET

rest_sum:
	// Undo last SUBQ
	ADDQ	$4,	BP
	// Check that are there any value to process
	JE	end
	loop_sum:
		// Load from X
		MOVSS	(SI), X2
		// Save sum in Y
		ADDSS	(DI), X2
		MOVSS	X2, (DI)

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX, DI

		DECQ	BP
		JNE	loop_sum
	RET

rest_diff:
	// Undo last SUBQ
	ADDQ	$4,	BP
	// Check that are there any value to process
	JE	end
	loop_diff:
		// Load from Y 
		MOVSS	(DI), X2
		// Save sum in Y
		SUBSS	(SI), X2
		MOVSS	X2, (DI)

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX, DI

		DECQ	BP
		JNE	loop_diff
	RET

panic:
	CALL	runtime·panicindex(SB)
end:
	RET
