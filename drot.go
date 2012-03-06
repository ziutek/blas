package blas

// Apply a Givens rotation (X', Y') = (c X + s Y, c Y - s X) to the vectors X, Y
func Drot(N int, X []float64, incX int, Y []float64, incY int, c, s float64)

func drot(N int, X []float64, incX int, Y []float64, incY int, c, s float64) {
	var xi, yi int
	for ; N > 0; N-- {
		x := X[xi]
		y := Y[yi]
		X[xi] = c*x + s*y
		Y[yi] = c*y - s*x
		xi += incX
		yi += incY
	}
}
