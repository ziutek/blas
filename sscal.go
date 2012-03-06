package blas

// Rescale the vector X by the multiplicative factor alpha
func Sscal(N int, alpha float32, X []float32, incX int)

func sscal(N int, alpha float32, X []float32, incX int) {
	var xi int
	for ; N >= 2; N -= 2 {
		X[xi] = alpha * X[xi]
		xi += incX
		X[xi] = alpha * X[xi]
		xi += incX
	}
	if N != 0 {
		X[xi] = alpha * X[xi]
	}
}
