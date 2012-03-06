package blas

// Exchange the elements of the vectors X and Y.
func Sswap(N int, X []float32, incX int, Y []float32, incY int)

func sswap(N int, X []float32, incX int, Y []float32, incY int) {
	var xi, yi int
	for ; N > 0; N-- {
		X[xi], Y[yi] = Y[yi], X[xi]
		xi += incX
		yi += incY
	}
}
