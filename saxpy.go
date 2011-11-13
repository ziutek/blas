package blas

// Compute the sum Y = \alpha X + Y for the vectors X and Y 
func Saxpy(N int, alpha float32, X []float32, incX int, Y []float32, incY int) {
	var xi, yi int
	for ; N >= 2; N -= 2 {
		Y[yi] += alpha * X[xi]
		xi += incX
		yi += incY

		Y[yi] += alpha * X[xi]
		xi += incX
		yi += incY
	}
	if N != 0 {
		Y[yi] += alpha * X[xi]
	}
}
