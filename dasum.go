package blas

// Absolute sum: \sum |X_i|
func Dasum(N int, X []float64, incX int) float64

func dasum(N int, X []float64, incX int) float64 {
	var (
		a  float64
		xi int
	)
	for ; N > 0; N-- {
		x := X[xi]
		if x < 0 {
			x = -x
		}
		a += x
		xi += incX
	}
	return a
}
