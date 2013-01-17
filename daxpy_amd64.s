//func Daxpy(N int, alpha float64, X []float64, incX int, Y []float64, incY int)
TEXT ·Daxpy(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVSD	alpha+8(FP), X0
	MOVQ	X_data+16(FP), SI
	MOVL	incX+32(FP), AX
	MOVQ	Y_data+40(FP), DI
	MOVL	incY+56(FP), BX

	// Setup 0, 1, -1
	PCMPEQL	X1, X1
	PCMPEQL	X7, X7
	XORPD	X6, X6	// 0
	PSLLQ	$54, X1
	PSRLQ	$2, X1	// 1
	PSLLQ	$63, X7
	ORPD	X1, X7	// -1

	// Check data bounaries
	MOVL	BP, CX
	DECL	CX
	MOVL	CX, DX
	IMULL	AX, CX	// CX = incX * (N - 1)
	IMULL	BX, DX	// DX = incY * (N - 1)
	CMPL	CX, X_len+24(FP)
	JGE		panic
	CMPL	DX, Y_len+48(FP)
	JGE		panic

	// Check that is there any work to do
	UCOMISD	X0, X6	
	JE	end	// alpha == 0

	// Setup strides
	SALQ	$3, AX	// AX = sizeof(float64) * incX
	SALQ	$3, BX	// BX = sizeof(float64) * incY

	// Check that there are 4 or more pairs for SIMD calculations
	SUBQ	$4, BP
	JL		rest	// There are less than 4 pairs to process

	// Setup two alphas in X0
	MOVLHPS	X0, X0

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $8
	JNE	with_stride
	CMPQ	BX, $8
	JNE	with_stride

	// Fully optimized loops (for incX == incY == 1)
	UCOMISD	X0, X1
	JE	full_simd_loop_sum	// alpha == 1
	UCOMISD	X0, X7
	JE	full_simd_loop_diff	// alpha == -1

	full_simd_loop:
		// Load first two pairs and scale
		MOVUPD	(SI), X2
		MOVUPD	(DI), X3
		MULPD	X0, X2
		// Load second two pairs and scale
		MOVUPD	16(SI), X4
		MOVUPD	16(DI), X5
		MULPD	X0, X4
		// Save sum of first two pairs
		ADDPD	X2, X3
		MOVUPD	X3, (DI)
		// Save sum of second two pairs
		ADDPD	X4, X5
		MOVUPD	X5, 16(DI)

		// Update data pointers
		ADDQ	$32, SI
		ADDQ	$32, DI

		SUBQ	$4, BP
		JGE		full_simd_loop	// There are 4 or more pairs to process
	JMP	rest

	full_simd_loop_sum:
		// Load first two pairs
		MOVUPD	(SI), X2
		MOVUPD	(DI), X3
		// Load second two pairs
		MOVUPD	16(SI), X4
		MOVUPD	16(DI), X5
		// Save a sum of first two pairs
		ADDPD	X2, X3
		MOVUPD	X3, (DI)
		// Save a sum of second two pairs
		ADDPD	X4, X5
		MOVUPD	X5, 16(DI)

		// Update data pointers
		ADDQ	$32, SI
		ADDQ	$32, DI

		SUBQ	$4, BP
		JGE		full_simd_loop_sum	// There are 4 or more pairs to process
	JMP	rest_sum

	full_simd_loop_diff:
		// Load first two pairs
		MOVUPD	(SI), X2
		MOVUPD	(DI), X3
		// Load second two pairs
		MOVUPD	16(SI), X4
		MOVUPD	16(DI), X5
		// Save a difference of first two pairs
		SUBPD	X2, X3
		MOVUPD	X3, (DI)
		// Save a difference of second two pairs
		SUBPD	X4, X5
		MOVUPD	X5, 16(DI)

		// Update data pointers
		ADDQ	$32, SI
		ADDQ	$32, DI

		SUBQ	$4, BP
		JGE		full_simd_loop_diff	// There are 4 or more pairs to process
	JMP	rest_diff

with_stride:
	// Setup long strides
	MOVQ	AX, CX
	MOVQ	BX, DX
	SALQ	$1, CX 	// CX = 16 * incX
	SALQ	$1, DX 	// DX = 16 * incY

	UCOMISD	X0, X1
	JE	half_simd_loop_sum	// alpha == 1
	UCOMISD	X0, X7
	JE	half_simd_loop_diff	// alpha == -1

	half_simd_loop:
		// Load first two pairs and scale
		MOVLPD	(SI), X2
		MOVHPD	(SI)(AX*1), X2
		MOVLPD	(DI), X3
		MOVHPD	(DI)(BX*1), X3
		MULPD	X0, X2
		// Save sum of first two pairs
		ADDPD	X2, X3
		MOVLPD	X3, (DI)
		MOVHPD	X3, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load second two pairs and scale
		MOVLPD	(SI), X4
		MOVHPD	(SI)(AX*1), X4
		MOVLPD	(DI), X5
		MOVHPD	(DI)(BX*1), X5
		MULPD	X0, X4
		// Save sum of second two pairs
		ADDPD	X4, X5
		MOVLPD	X5, (DI)
		MOVHPD	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process
	JMP rest

	half_simd_loop_sum:
		// Load first two pairs
		MOVLPD	(SI), X2
		MOVHPD	(SI)(AX*1), X2
		MOVLPD	(DI), X3
		MOVHPD	(DI)(BX*1), X3
		// Save a sum of first two pairs
		ADDPD	X2, X3
		MOVLPD	X3, (DI)
		MOVHPD	X3, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load second two pairs
		MOVLPD	(SI), X4
		MOVHPD	(SI)(AX*1), X4
		MOVLPD	(DI), X5
		MOVHPD	(DI)(BX*1), X5
		// Save a sum of second two pairs
		ADDPD	X4, X5
		MOVLPD	X5, (DI)
		MOVHPD	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process
	JMP rest_sum

	half_simd_loop_diff:
		// Load first two pairs
		MOVLPD	(SI), X2
		MOVHPD	(SI)(AX*1), X2
		MOVLPD	(DI), X3
		MOVHPD	(DI)(BX*1), X3
		// Save a difference of first two pairs
		SUBPD	X2, X3
		MOVLPD	X3, (DI)
		MOVHPD	X3, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load second two pairs
		MOVLPD	(SI), X4
		MOVHPD	(SI)(AX*1), X4
		MOVLPD	(DI), X5
		MOVHPD	(DI)(BX*1), X5
		// Save a difference of second two pairs
		SUBPD	X4, X5
		MOVLPD	X5, (DI)
		MOVHPD	X5, (DI)(BX*1)

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		SUBQ	$4, BP
		JGE		half_simd_loop	// There are 4 or more pairs to process
	JMP	rest_diff

rest:
	// Undo last SUBQ
	ADDQ	$4,	BP
	// Check that are there any value to process
	JE	end
	loop:
		// Load from X and scale
		MOVSD	(SI), X2
		MULSD	X0, X2
		// Save a sum in Y
		ADDSD	(DI), X2
		MOVSD	X2, (DI)

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
		MOVSD	(SI), X2
		// Save a sum in Y
		ADDSD	(DI), X2
		MOVSD	X2, (DI)

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
		MOVSD	(DI), X2
		// Save sum in Y
		SUBSD	(SI), X2
		MOVSD	X2, (DI)

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
