// func Sswap(N int, X []float32, incX int, Y []float32, incY int)
TEXT ·Sswap(SB), 7, $0
	MOVQ	N+0(FP), BP
	MOVQ	X_data+8(FP), SI
	MOVQ	incX+32(FP), AX
	MOVQ	Y_data+40(FP), DI
	MOVQ	incY+64(FP), BX

	// Check data bounaries
	MOVQ	BP, CX
	DECQ	CX
	MOVQ	CX, DX
	IMULQ	AX, CX	// CX = incX * (N - 1)
	IMULQ	BX, DX	// DX = incY * (N - 1)
	CMPQ	CX, X_len+16(FP)
	JGE		panic
	CMPQ	DX, Y_len+48(FP)
	JGE		panic

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
		// Load four values from X
		MOVUPS	(SI), X0
		// Load four values from Y
		MOVUPS	(DI), X2
		// Save them
		MOVUPS	X0, (DI)
		MOVUPS	X2, (SI)

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process

	JMP rest

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 8 * incX
	SALQ	$1, DX 	// DX = 8 * incY

	// Partially optimized loop
	half_simd_loop:
		// Load two values from X
		MOVSS	(SI), X0
		MOVSS	(SI)(AX*1), X1
		// Load two values from Y
		MOVSS	(DI), X2
		MOVSS	(DI)(BX*1), X3
		// Save them
		MOVSS	X0, (DI)
		MOVSS	X1, (DI)(BX*1)
		MOVSS	X2, (SI)
		MOVSS	X3, (SI)(AX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load two values from X
		MOVSS	(SI), X0
		MOVSS	(SI)(AX*1), X1
		// Load two values from Y
		MOVSS	(DI), X2
		MOVSS	(DI)(BX*1), X3
		// Save them
		MOVSS	X0, (DI)
		MOVSS	X1, (DI)(BX*1)
		MOVSS	X2, (SI)
		MOVSS	X3, (SI)(AX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP

	// Check that are there any value to process
	JE	end

	loop:
		// Load values from X and Y
		MOVSS	(SI), X0
		MOVSS	(DI), X1
		// Save them
		MOVSS	X0, (DI)
		MOVSS	X1, (SI)

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX,	DI

		DECQ	BP
		JNE	loop

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
