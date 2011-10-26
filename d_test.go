package blas

import (
	"testing"
	"rand"
	"math"
)

func iCheck(t *testing.T, inc, N, r, e int) {
	t.Logf("inc=%d N=%d : r=%d e=%d", inc, N, r, e)
	if r != e {
		t.FailNow()
	}
}

func dCheck(t *testing.T, inc, N int, r, e float64) {
	t.Logf("inc=%d N=%d : r=%f e=%f e-r=%g", inc, N, r, e, e-r)
	if r != e {
		t.FailNow()
	}
}

var (
	xd = []float64{1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9}
	yd = []float64{1e17, 1e16, 1e15, 1e14, 1e13, 1e12, 1e11, 1e10, 1e9, 1e8,
		1e7, 1e6, 1e5, 1e4, 1e3, 100, 10, 1}
)

func TestDdot(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		e := 0.0
		k := 0
		for N := 0; N <= len(xd) / inc; N++ {
			if N > 0 {
				e += xd[k] * yd[k]
				k += inc
			}
			r := Ddot(N, xd, inc, yd, inc)
			dCheck(t, inc, N, r, e)
		}
	}
}

func TestDnrm2(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd) / inc; N++ {
			e := math.Sqrt(Ddot(N, xd, inc, xd, inc))
			r := Dnrm2(N, xd, inc)
			dCheck(t, inc, N, r, e)
		}
	}
}

func TestDasum(t *testing.T) {
	xd := []float64{-1, -2, 3, -4, -5, -6, 7, -8, 9, 1, -2, 3, -4, 5, -6, -7, 8}
	for inc := 1; inc < 9; inc++ {
		e := 0.0
		k := 0
		for N := 0; N <= len(xd) / inc; N++ {
			if N > 0 {
				e += math.Abs(xd[k])
				k += inc
			}
			r := Dasum(N, xd, inc)
			dCheck(t, inc, N, r, e)
		}
	}
}

func TestIdamax(t *testing.T) {
	xd := []float64{-1, -2, 3, -4, -5, 0, -5, 0, 4, 2, 3, -1, 4, 2}
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd) / inc; N++ {
			i_max := -1
			x_max := 0.0
			for i := 0; i < N; i++ {
				x := math.Abs(xd[i * inc])
				if x > x_max {
					x_max = x
					i_max = i
				}
			}
			r := Idamax(N, xd, inc)
			iCheck(t, inc, N, r, i_max)
		}
	}
}

func TestDswap(t *testing.T) {
	a := make([]float64, len(xd))
	b := make([]float64, len(yd))
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd) / inc; N++ {
			copy(a, xd)
			copy(b, yd)
			Dswap(N, a, inc, b, inc)
			for i := 0; i < len(a); i++ {
				if i <= inc * (N-1) && i % inc == 0 {
					if a[i] != yd[i] || b[i] != xd[i] {
						t.Fatalf("inc=%d N=%d", inc, N)
					}
				} else {
					if a[i] != xd[i] || b[i] != yd[i] {
						t.Fatalf("inc=%d N=%d", inc, N)
					}
				}
			}
		}
	}
}

var vd, wd []float64

func init() {
	vd = make([]float64, 514)
	wd = make([]float64, len(vd))
	for i := 0; i < len(vd); i++ {
		vd[i] = rand.Float64()
		wd[i] = rand.Float64()
	}
}

func BenchmarkDdot(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Ddot(len(vd), vd, 1, wd, 1)
	}
}

func BenchmarkDnrm2(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Dnrm2(len(vd), vd, 1)
	}
}

func BenchmarkDasum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Dasum(len(vd), vd, 1)
	}
}

func BenchmarkIdamax(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Idamax(len(vd), vd, 1)
	}
}

func BenchmarkDswap(b *testing.B) {
	b.StopTimer()
	x := make([]float64, len(vd))
	y := make([]float64, len(vd))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Dswap(len(x), x, 1, y, 1)
	}
}
