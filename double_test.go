package blas

import "testing"

func TestDdot(t *testing.T) {
	a := []float64{1, 2, 3, 4, 5, 6, 7, 8, 9}
	b := []float64{1e8, 1e7, 1e6, 1e5, 1e4, 1e3, 100, 10, 1}

	for inc := 1; inc < 9; inc++ {
		e := 0.0
		k := 0
		for N := 0; N <= len(a) / inc; N++ {
			if N > 0 {
				e += a[k] * b[k]
				k += inc
			}
			r := Ddot(N, a, inc, b, inc)
			t.Logf("inc=%d N=%d : r=%f e=%f", inc, N, r, e)
			if r != e {
				t.FailNow()
			}
		}
	}
}
