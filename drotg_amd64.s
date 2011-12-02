// func Drotg(a, b float64) (c, s, r, z float64)
TEXT ·Drotg(SB), 7, $0
	MOVSD   a+0(FP), X0
	MOVSD   b+8(FP), X1

	// Setup mask for sign bit clear
	PCMPEQL	X6, X6
	PSRLQ	$1, X6

	// Setup 0
	XORPD	X8, X8

	// Setup 1
	PCMPEQL	X7, X7
	PSLLQ	$54, X7
	PSRLQ	$2, X7 

	// Compute |a|, |b|
	MOVSD	X0, X2
	MOVSD	X1, X3
	ANDPD	X6, X2
	ANDPD	X6, X3

	// Compute roe
	MOVSD	X1, X4	// roe = b
	UCOMISD	X3,	X2	// cmp(abs_b, abs_a)
	JBE	roe_b

	MOVSD	X0, X4	// roe = a

roe_b:

	// Compute scale
	MOVSD	X2, X5
	ADDSD	X3, X5

	UCOMISD	X8,	X5	// cmp(0, scale)
	JNE	scale_NE_zero
	
	MOVSD	X7, c+16(FP)	// c = 1
	MOVHPD	X8,	s+24(FP)	// s = 0
	MOVSD	X8,	r+32(FP)	// r = 0
	MOVSD	X8, z+40(FP)	// z = 0
	RET

scale_NE_zero:

	MOVLHPS	X5, X5	// (scale, scale)
	MOVLHPS	X1, X0	// (a, b)
	MOVAPD	X0, X1	// (a, b)
	DIVPD	X5, X0	// (a/scale, b/scale)
	MULPD	X0, X0	// ((a/scale)^2, (b/scale)^2)
	MOVHLPS	X0, X6
	ADDSD	X6, X0	// (a/scale)^2 + (b/scale)^2
	SQRTSD	X0, X0
	MULSD	X5, X0	// r
	MOVLHPS	X0, X0	// (r, r)

	UCOMISD	X8, X4 // cmp(0, roe)
	JAE	roe_GE_zero

	PCMPEQL X4, X4
	PSLLQ	$63, X4 // Sign bit
	XORPD	X4, X0	// (r, r) = (-r, -r)

roe_GE_zero:

	DIVPD	X0, X1			// (a/r, b/r) 	
	MOVLPD	X1, c+16(FP)	// c = a/r
	MOVHPD	X1,	s+24(FP)	// s = b/r
	MOVSD	X0,	r+32(FP)

	MOVSD	X7, X4	// z = 1

	UCOMISD	X3,	X2	// cmp(abs_b, abs_a)
	JBE	abs_a_LE_abs_b

	MOVHLPS	X1, X4	// z = s

	JMP end
	
abs_a_LE_abs_b:

	UCOMISD	X8, X1
	JE	end

	DIVSD	X1, X4	// z /= c

end:
	MOVSD	X4, z+40(FP)
	RET
