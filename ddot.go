package blas

// Scalar product: X^T Y 
func Ddot(N int, X []float64, incX int, Y []float64, incY int) float64

func ddot(N int, X []float64, incX int, Y []float64, incY int) float64 {
	var (
		a, b, c, d float64
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
