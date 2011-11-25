// func Drotg(a, b float64) (c, s, r, z float64)
TEXT ·Drotg(SB), 7, $0
	MOVSD   a+0(FP),X0
	MOVSD   b+8(FP),X1

	// Setup mask for sign bit clear
	PCMPEQL	X7, X7
	PSRLQ	$1, X7

	// Setup 0
	XORPD	X8, X8

	// Setup 1
	PCMPEQL	X9, X9
	PSLLQ	$54,X9
	PSRLQ	$2, X9

	// Compute |a|, |b|
	MOVSD	X0, X2
	MOVSD	X1, X3
	ANDPD	X7, X2
	ANDPD	X7, X3

	// Compute roe
	MOVSD	X1, X4	// roe = b
	UCOMISD	X2,	X3	// cmp(abs_a, abs_b)
	JBE	roe_b

	MOVSD	X0, X4	// roe = a

roe_b:

	// Compute scale
	MOVSD	X2, X5
	ADDSD	X3, X5

	UCOMISD	X5,	X8	// cmp(scale, 0)
	JNE	scale_NE_zero
	
	MOVSD	X9, c+16(FP)	// c = 1
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
	MULSD	X5, X0	// (r, r)

	UCOMISD	X4, X8 // cmp(roe, 0)
	JAE	roe_GE_zero

	PCMPEQL X4, X4
	PSLLQ	$63, X4 // Sign bit
	XORPD	X4, X0	// r == -r

roe_GE_zero:

	DIVPD	X0, X1			// (a/r, b/r) 	
	MOVLPD	X1, c+16(FP)	// c = a/r
	MOVHPD	X1,	s+24(FP)	// s = b/r
	MOVSD	X0,	r+32(FP)

	MOVSD	X9, X4	// z = 1

	UCOMISD	X2,	X3	// cmp(abs_a, abs_b)
	JBE	abs_a_LE_abs_b

	MOVHLPS	X1, X4	// z = s

	JMP end
	
abs_a_LE_abs_b:

	UCOMISD	X1, X8
	JE	end

	DIVSD	X1, X4

end:
	MOVSD	X4, z+40(FP)
	RET
