// func Dcopy(N int, X []float64, incX int, Y []float64, incY int)
TEXT ·Dcopy(SB), 7, $0
	MOVL	N+0(FP), CX
	MOVQ	X_data+8(FP), SI
	MOVL	incX+24(FP), AX
	MOVQ	Y_data+32(FP), DI
	MOVL	incY+48(FP), BX

	// Check data bounaries
	MOVL	CX, BP
	DECL	BP
	MOVL	BP, DX
	IMULL	AX, BP	// BP = incX * (N - 1)
	IMULL	BX, DX	// DX = incY * (N - 1)
	CMPL	BP, X_len+16(FP)
	JGE		panic
	CMPL	DX, Y_len+40(FP)
	JGE		panic

	// Check if incX != 1 or incY != 1
	CMPQ	AX, $1
	JNE	with_stride
	CMPQ	BX, $1
	JNE	with_stride

	// Optimized copy for incX == incY == 1
	REP; MOVSQ
	RET

with_stride:
	// Setup strides
	SALQ	$3, AX	// AX = sizeof(float64) * incX
	SALQ	$3, BX	// BX = sizeof(float64) * incY

	CMPQ	CX, $0
	JE	end

	loop:
		MOVQ	(SI), DX
		MOVQ	DX, (DI)
		ADDQ	AX, SI
		ADDQ	BX, DI
		DECQ	CX
		JNE	loop

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
