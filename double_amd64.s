// func Ddot(N int, X []float64, incX int, Y []float64, incY int) float64
TEXT ·Ddot(SB), 7, $0
	MOVL	N+0(FP), CX
	MOVQ	X+4(FP), SI	// X.data
	MOVL	incX+20(FP), AX
	MOVQ	Y+24(FP), DI	// Y.data
	MOVQ	incY+40(FP), BX	// Y.data

	RET
