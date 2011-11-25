// func Sdsdot(N int, alpha float32, X []float32, incX int, Y []float32, incY int) float32
TEXT ·Sdsdot(SB), 7, $0
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
		// Load four pairs
		MOVUPS	(SI), X2
		MOVUPS	(DI), X3

		// Move two high pairs to low part of another registers
		MOVHLPS	X2, X4
		MOVHLPS	X3, X5
		
		// Convert to float64
		CVTPS2PD X2, X2
		CVTPS2PD X3, X3
		CVTPS2PD X4, X4
		CVTPS2PD X5, X5

		// Multiply converted values
		MULPD	X2, X3
		MULPD	X4, X5

		// Update data pointers
		ADDQ	$16, SI
		ADDQ	$16, DI

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
		// Load first two pairs
		MOVSS		(SI), X2
		MOVSS		(SI)(AX*1), X6
		MOVSS		(DI), X3
		MOVSS		(DI)(BX*1), X7

		// Convert them to float64 and multiply
		UNPCKLPS	X6, X2
		UNPCKLPS	X7, X3
		CVTPS2PD	X2, X2
		CVTPS2PD	X3, X3
		MULPD		X2, X3

		// Update data pointers using long strides
		ADDQ	CX, SI
		ADDQ	DX, DI

		// Load second two pairs
		MOVSS		(SI), X4
		MOVSS		(SI)(AX*1), X6
		MOVSS		(DI), X5
		MOVSS		(DI)(BX*1), X7

		// Convert them to float64 and multiply
		UNPCKLPS	X6, X4
		UNPCKLPS	X7, X5
		CVTPS2PD	X4, X4
		CVTPS2PD	X5, X5
		MULPD		X4, X5

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

	// Check that are there any value to process
	JE	end

	loop:
		// Load one pair
		MOVSS	(SI), X2
		MOVSS	(DI), X3
		
		// Convert them to float64 and multiply
		CVTSS2SD	X2, X2
		CVTSS2SD	X3, X3
		MULSD		X3, X2

		// Update data pointers
		ADDQ	AX, SI
		ADDQ	BX,	DI

		// Accumulate the results of multiplication
		ADDSD	X2, X0

		DECQ	BP
		JNE	loop

end:
	// Add alpha
	MOVSS		alpha+4(FP), X1
	CVTSS2SD	X1, X1
	ADDSD		X1, X0

	// Convert result to float32 and return
	CVTSD2SS	X0, X0	
	MOVSS		X0, r+56(FP)
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
