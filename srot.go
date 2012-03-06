package blas

// Apply a Givens rotation (X', Y') = (c X + s Y, c Y - s X) to the vectors X, Y
func Srot(N int, X []float32, incX int, Y []float32, incY int, c, s float32)

func srot(N int, X []float32, incX int, Y []float32, incY int, c, s float32) {
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
