package blas

// \alpha + X^T Y  computed using float64
func Sdsdot(N int, alpha float32, X []float32, incX int, Y []float32, incY int) float32

func sdsdot(N int, alpha float32, X []float32, incX int, Y []float32, incY int) float32 {
	var (
		a, b, c, d float64
		xi, yi     int
	)
	for ; N >= 4; N -= 4 {
		a += float64(X[xi]) * float64(Y[yi])
		xi += incX
		yi += incY

		b += float64(X[xi]) * float64(Y[yi])
		xi += incX
		yi += incY

		c += float64(X[xi]) * float64(Y[yi])
		xi += incX
		yi += incY

		d += float64(X[xi]) * float64(Y[yi])
		xi += incX
		yi += incY
	}
	for ; N > 0; N-- {
		a += float64(X[xi]) * float64(Y[yi])
		xi += incX
		yi += incY
	}
	return float32(float64(alpha) + (b + c) + (d + a))
}
