package blas

// Scalar product: X^T Y
func Sdot(N int, X []float32, incX int, Y []float32, incY int) float32

func sdot(N int, X []float32, incX int, Y []float32, incY int) float32 {
	var (
		a, b, c, d float32
		xi, yi     int
	)
	for ; N >= 4; N -= 4 {
		a += X[xi] * Y[yi]
		xi += incX
		yi += incY

		b += X[xi] * Y[yi]
		xi += incX
		yi += incY

		c += X[xi] * Y[yi]
		xi += incX
		yi += incY

		d += X[xi] * Y[yi]
		xi += incX
		yi += incY
	}
	for ; N > 0; N-- {
		a += X[xi] * Y[yi]
		xi += incX
		yi += incY
	}
	return (b + c) + (d + a)
}
