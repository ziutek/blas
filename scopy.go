package blas

// Copy the  elements of the vectors X and Y.
func Scopy(N int, X []float32, incX int, Y []float32, incY int)

func scopy(N int, X []float32, incX int, Y []float32, incY int) {
	if incX == 1 && incY == 1 {
		copy(Y[:N], X[:N])
		return
	}
	var xi, yi int
	for ; N > 0; N-- {
		Y[yi] = X[xi]
		xi += incX
		yi += incY
	}
}
