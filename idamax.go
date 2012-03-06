package blas

// Index of largest (absoulute) element of the vector X
func Idamax(N int, X []float64, incX int) int

func idamax(N int, X []float64, incX int) int {
	var (
		max_x float64
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
