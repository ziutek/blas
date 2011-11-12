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

	// Max value
	XORPD	X0, X0
	// Index
	XORQ	DI, DI
	// Max index
	XORQ	BX, BX

	// Mask for sign bit clear
	PCMPEQL	X4, X4 
	PSRLQ	$1, X4

	// Setup stride
	SALQ	$3, AX	// AX = sizeof(float64) * incX

loop:
	CMPQ	BP, DI
	JE	end

	// Load value
	MOVSD	(SI), X1
	// Clear sign of loaded value
	ANDPD	X4, X1

	// Is loaded value less or equal to max value?
	UCOMISD	X0,	X1
	JBE	less_or_equal

	// Save max index and value
	MOVQ	DI, BX
	MOVSD	X1, X0

less_or_equal:
	// Update data pointers
	ADDQ	AX, SI
	INCQ	DI
	JMP	loop

end:
	// Return the max index
	MOVL	BX, r+32(FP)
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
