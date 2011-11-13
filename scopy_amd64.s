// func Scopy(N int, X []float32, incX int, Y []float32, incY int)
TEXT ·Scopy(SB), 7, $0
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
	REP; MOVSL
	RET

with_stride:
	// Setup strides
	SALQ	$2, AX	// AX = sizeof(float32) * incX
	SALQ	$2, BX	// BX = sizeof(float32) * incY

	CMPQ	CX, $0
	JE	end

	loop:
		MOVL	(SI), DX
		MOVL	DX, (DI)
		ADDQ	AX, SI
		ADDQ	BX, DI
		DECQ	CX
		JNE	loop

end:
	RET

panic:
	CALL	runtime·panicindex(SB)
	RET
