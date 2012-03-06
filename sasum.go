package blas

// Absolute sum: \sum |X_i|
func Sasum(N int, X []float32, incX int) float32

func sasum(N int, X []float32, incX int) float32 {
	var (
		a  float32
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
