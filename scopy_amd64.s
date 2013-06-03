// func Scopy(N int, X []float32, incX int, Y []float32, incY int)
TEXT ·Scopy(SB), 7, $0
	MOVQ	N+0(FP), CX
	MOVQ	X_data+8(FP), SI
	MOVQ	incX+32(FP), AX
	MOVQ	Y_data+40(FP), DI
	MOVQ	incY+64(FP), BX

	// Check data bounaries
	MOVQ	CX, BP
	DECQ	BP
	MOVQ	BP, DX
	IMULQ	AX, BP	// BP = incX * (N - 1)
	IMULQ	BX, DX	// DX = incY * (N - 1)
	CMPQ	BP, X_len+16(FP)
	JGE		panic
	CMPQ	DX, Y_len+48(FP)
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
