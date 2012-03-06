package blas

import "math"

// Euclidean norm: ||X||_2 = \sqrt {\sum X_i^2}
func Snrm2(N int, X []float32, incX int) float32

func snrm2(N int, X []float32, incX int) float32 {
	var (
		a, b, c, d float32
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
	return float32(math.Sqrt(float64((b + c) + (d + a))))
}
