// func Dcopy(N int, X []float64, incX int, Y []float64, incY int)
TEXT ·Dcopy(SB), 7, $0
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
	CALL	·panicIndex(SB)
	RET
