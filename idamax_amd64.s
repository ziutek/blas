// func Idamax(N int, X []float64, incX int) int
TEXT ·Idamax(SB), 7, $0
	MOVL	N+0(FP), BP
	MOVQ	X+8(FP), SI	// X.data
	MOVL	incX+24(FP), AX

	// Check data bounaries
	MOVL	BP, CX
	DECL	CX
	IMULL	AX, CX	// CX = incX * (N - 1)
	CMPL	CX, X_len+16(FP)
	JGE		panic

	// Max fp value
	XORPD	X0, X0	// X0 = {0, 0}
	// Max index
	PXOR	X1, X1	// X1 = {0, 0}
	// Increment register
	PCMPEQL X2, X2
	PSRLQ	$63, X2	// X2 = {1, 1}
	// Index register
	MOVQ	X2, X3
	PSLLDQ	$8, X3	// X3 = {0, 1}
	// Mask for sign bit clear
	PCMPEQL	X4, X4 
	PSRLQ	$1, X4

	// Setup stride
	SALQ	$3, AX	// AX = sizeof(float64) * incX

	// Check that there are 2 or more values for SIMD calculations
	SUBQ	$2, BP
	JL		rest	// There are less than 2 values to process

	// Increment register
	PSLLQ	$1, X2	// X2 = (2, 2)

	// Check if incX != 1
	CMPQ	AX, $8
	JNE	with_stride

	// Fully optimized loop (for incX == incY == 1)
	full_simd_loop:
		// Load two values
		MOVUPD	(SI), X5

		// Clear sign on two values
		ANDPD	X4, X5

		// Update data pointer
		ADDQ	$16, SI

		// Compare first two values with max values
		MOVAPD	X0, X6
		CMPPD	X5, X6, 5 // NLT

		// Clear previous max indexes
		PAND	X6,	X1
		// Select indexes of max values
		PANDN	X3,	X6
		// Update max indexes
		POR		X6, X1

		// Update max values
		MAXPD	X5, X0

		// Update indexes
		PADDQ	X2, X3

		SUBQ	$2, BP
		JGE		full_simd_loop	// There are 2 or more values to process

	JMP	hsum
	
with_stride:
	// Setup long stride
	MOVQ	AX, CX
	SALQ	$1, CX 	// CX = 16 * incX

	half_simd_loop:
		// Load two values
		MOVLPD	(SI), X5
		MOVHPD	(SI)(AX*1), X5

		// Clear sign on two values
		ANDPD	X4, X5

		// Update data pointer using long stride
		ADDQ	CX, SI

		// Compare first two values with max values
		MOVAPD	X0, X6
		CMPPD	X5, X6, 5	// NLT

		// Clear previous max indexes
		PAND	X6,	X1
		// Select indexes of max values
		PANDN	X3,	X6
		// Update max indexes
		POR		X6, X1

		// Update max values
		MAXPD	X5, X0

		// Update indexes
		PADDQ	X2, X3

		SUBQ	$2, BP
		JGE		half_simd_loop	// There are 2 or more values to process

hsum:
	// Increment register
	//PSRLQ	$1, X2

	// Uvectorize max values and indexes
	MOVHLPS X0, X5
	PSHUFL	$0xee, X1, X7

	// Compare max values
	MOVSD	X0, X6
	CMPSD	X5, X6, 5	// NLT

	// Clear previous max indexes
	PAND	X6,	X1
	// Select indexes of max values
	PANDN	X7,	X6
	// Update max indexes
	POR		X6, X1

	// Update max value
	MAXSD	X5, X0

rest:
	// Undo last SUBQ
	ADDQ	$2,	BP

	// Check that are there any value to process
	JE	end

//loop:
	// Load value
	MOVSD	(SI), X5
	// Clear sign
	ANDPD	X4, X5

	// Update data pointers
	//ADDQ	AX, SI

	// Compare current value with max value
	MOVSD	X0, X6
	CMPSD	X5, X6, 5	// NLT

	// Clear previous max indexes
	PAND	X6,	X1

	// Select indexes of max values
	PANDN	X3,	X6
	// Update max indexes
	POR		X6, X1

	// Update max value
	//MAXSD	X5, X0

	// Update indexes
	//PADDQ	X2, X3

	//DECQ	BP
	//JNE	loop

end:
	// Return the max index
	MOVSD	X1, r+32(FP)
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
