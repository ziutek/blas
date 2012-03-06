package blas

// Index of largest (absoulute) element of the vector X
func Isamax(N int, X []float32, incX int) int

func isamax(N int, X []float32, incX int) int {
	var (
		max_x float32
		xi    int
	)
	max_n := 0
	for n := 0; n < N; n++ {
		x := X[xi]
		if x < 0 {
			x = -x
		}
		if x > max_x {
			max_x = x
			max_n = n
		}
		xi += incX
	}
	return max_n
}
