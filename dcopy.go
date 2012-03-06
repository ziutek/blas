package blas

// Copy the  elements of the vectors X and Y.
func Dcopy(N int, X []float64, incX int, Y []float64, incY int)

func dcopy(N int, X []float64, incX int, Y []float64, incY int) {
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
