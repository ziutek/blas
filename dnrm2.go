package blas

import "math"

// Euclidean norm: ||X||_2 = \sqrt {\sum X_i^2}
func Dnrm2(N int, X []float64, incX int) float64

func dnrm2(N int, X []float64, incX int) float64 {
	var (
		a, b, c, d float64
		xi         int
	)
	for ; N >= 4; N -= 4 {
		a += X[xi] * X[xi]
		xi += incX

		b += X[xi] * X[xi]
		xi += incX

		c += X[xi] * X[xi]
		xi += incX

		d += X[xi] * X[xi]
		xi += incX
	}
	for ; N > 0; N-- {
		a += X[xi] * X[xi]
		xi += incX
	}
	return math.Sqrt((b + c) + (d + a))
}
