package blas

// Absolute sum: \sum |x_i|
func Dasum(N int, X []float64, incX int) float64 {
	var (
		a float64
		xi int
	)
	for ; N > 0; N-- {
		x := X[xi]
		if x < 0 {
			a -= x
		} else {
			a += x
		}
		xi += incX
	}
	return a
}
