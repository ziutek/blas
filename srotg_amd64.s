// func Srotg(a, b float32) (c, s, r, z float32)
TEXT ·Srotg(SB), 7, $0
	MOVSS   a+0(FP), X0
	MOVSS   b+4(FP), X1

	// Setup mask for sign bit clear
	PCMPEQW	X6, X6
	PSRLL	$1, X6

	// Setup 0
	XORPS	X8, X8

	// Setup 1
	PCMPEQW	X7, X7
	PSLLL	$25, X7
	PSRLL	$2, X7 

	// Compute |a|, |b|
	MOVAPS	X0, X2
	MOVAPS	X1, X3
	ANDPS	X6, X2
	ANDPS	X6, X3

	// Compute roe
	MOVSS	X1, X4	// roe = b
	UCOMISS	X3,	X2	// cmp(abs_b, abs_a)
	JBE	roe_b

	MOVSS	X0, X4	// roe = a

roe_b:

	// Compute scale
	MOVSS	X2, X5
	ADDSS	X3, X5

	UCOMISS	X8,	X5	// cmp(0, scale)
	JNE	scale_NE_zero
	
	MOVSS	X7, c+8(FP)	// c = 1
	MOVSS	X8,	s+12(FP)	// s = 0
	MOVSS	X8,	r+16(FP)	// r = 0
	MOVSS	X8, z+20(FP)	// z = 0
	RET

scale_NE_zero:

	SHUFPS	$0, X5, X5	// (scale, scale, scale, scale)
	MOVLHPS	X1, X0	// (a, b)
	MOVAPS	X0, X1	// (a, b)
	DIVPS	X5, X0	// (a/scale, b/scale)
	MULPS	X0, X0	// ((a/scale)^2, (b/scale)^2)
	MOVHLPS	X0, X6
	ADDSS	X6, X0	// (a/scale)^2 + (b/scale)^2
	SQRTSS	X0, X0
	MULSS	X5, X0	// r
	SHUFPS	$0, X0, X0	// (r, r, r, r)

	UCOMISS	X8, X4 // cmp(0, roe)
	JAE	roe_GE_zero

	PCMPEQW X4, X4
	PSLLL	$31, X4 // Sign bit
	XORPS	X4, X0	// (r, r) = (-r, -r)

roe_GE_zero:

	DIVPS	X0, X1		// (a/r, b/r) 	
	MOVSS	X1, c+8(FP)	// c = a/r
	MOVHLPS	X1, X1
	MOVSS	X1,	s+12(FP)	// s = b/r
	MOVSS	X0,	r+16(FP)

	MOVSS	X7, X4	// z = 1

	UCOMISS	X3,	X2	// cmp(abs_b, abs_a)
	JBE	abs_a_LE_abs_b

	MOVSS	X1, X4	// z = s

	JMP end
	
abs_a_LE_abs_b:

	UCOMISS	X8, X1
	JE	end

	DIVSS	X1, X4	// z /= c

end:
	MOVSS	X4, z+20(FP)
	RET
