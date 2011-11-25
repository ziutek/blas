package blas

import (
	"math"
	"math/rand"
	"testing"
)

func fCheck(t *testing.T, inc, N int, r, e float32) {
	t.Logf("inc=%d N=%d : r=%f e=%f e-r=%g", inc, N, r, e, e-r)
	if r != e {
		t.FailNow()
	}
}

var (
	xf = []float32{1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7}
	yf = []float32{1e6, 1e5, 1e4, 1e3, 100, 10, 1,
		1e6, 1e5, 1e4, 1e3, 100, 10, 1}
)

func TestSdsdot(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		e := float64(0)
		k := 0
		for N := 0; N <= len(xf)/inc; N++ {
			if N > 0 {
				e += float64(xf[k]) * float64(yf[k])
				k += inc
			}
			r := Sdsdot(N, 10, xf, inc, yf, inc)
			fCheck(t, inc, N, r, float32(e+10))
		}
	}
}

func TestSdot(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		e := float32(0)
		k := 0
		for N := 0; N <= len(xf)/inc; N++ {
			if N > 0 {
				e += xf[k] * yf[k]
				k += inc
			}
			r := Sdot(N, xf, inc, yf, inc)
			fCheck(t, inc, N, r, e)
		}
	}
}

func TestSnrm2(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			e := float32(math.Sqrt(float64(Sdot(N, xf, inc, xf, inc))))
			r := Snrm2(N, xf, inc)
			fCheck(t, inc, N, r, e)
		}
	}
}

func TestSasum(t *testing.T) {
	xf := []float32{-1, -2, 3, -4, -5, -6, 7, -8, 9}
	for inc := 1; inc < 9; inc++ {
		e := float32(0)
		k := 0
		for N := 0; N <= len(xf)/inc; N++ {
			if N > 0 {
				e += float32(math.Abs(float64(xf[k])))
				k += inc
			}
			r := Sasum(N, xf, inc)
			fCheck(t, inc, N, r, e)
		}
	}
}

func TestIsamax(t *testing.T) {
	xf := []float32{-1, -2, 3, -4, -5, 0, -5, 0, 4, 2, 3, -1, 4, -2, -9, 0,
		-1, 0, 0, 2, 2, -8, 2, 1, 0, 2, 4, 5, 8, 1, -7, 2, 9, 0, 1, -1 }
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			i_max := 0
			x_max := float32(0.0)
			for i := 0; i < N; i++ {
				x := float32(math.Abs(float64(xf[i*inc])))
				if x > x_max {
					x_max = x
					i_max = i
				}
			}
			r := Isamax(N, xf, inc)
			iCheck(t, inc, N, r, i_max)
		}
	}
}

func TestSswap(t *testing.T) {
	a := make([]float32, len(xf))
	b := make([]float32, len(yf))
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			copy(a, xf)
			copy(b, yf)
			Sswap(N, a, inc, b, inc)
			for i := 0; i < len(a); i++ {
				if i <= inc*(N-1) && i%inc == 0 {
					if a[i] != yf[i] || b[i] != xf[i] {
						t.Fatalf("inc=%d N=%d", inc, N)
					}
				} else {
					if a[i] != xf[i] || b[i] != yf[i] {
						t.Fatalf("inc=%d N=%d", inc, N)
					}
				}
			}
		}
	}
}

func TestScopy(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			a := make([]float32, len(xf))
			Scopy(N, xf, inc, a, inc)
			for i := 0; i < inc * N; i++ {
				if i % inc == 0 {
					if a[i] != xf[i] {
						t.Fatalf("inc=%d N=%d i=%d r=%f e=%f", inc, N, i, a[i],
							xf[i])
					}
				} else {
					if a[i] != 0 {
						t.Fatalf("inc=%d N=%d i=%d r=%f e=0", inc, N, i, a[i])
					}
				}
			}
		}
	}
}

func TestSaxpy(t *testing.T) {
	alpha := float32(3.0)
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			r := make([]float32, len(xf))
			e := make([]float32, len(xf))
			copy(r, xf)
			copy(e, xf)
			Saxpy(N, alpha, xf, inc, r, inc)
			for i := 0; i < N; i++ {
				e[i*inc] += alpha * xf[i*inc]
			}
			for i := 0; i < len(xf); i++ {
				if r[i] != e[i] {
					t.Fatalf("inc=%d N=%d i=%d r=%f e=%f", inc, N, i, r[i],
						e[i])
				}
			}
		}
	}
}

func TestSscal(t *testing.T) {
	alpha := float32(3.0)
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			r := make([]float32, len(xf))
			e := make([]float32, len(xf))
			copy(r, xf)
			copy(e, xf)
			Sscal(N, alpha, r, inc)
			for i := 0; i < N; i++ {
				e[i*inc] = alpha * xf[i*inc]
			}
			for i := 0; i < len(xf); i++ {
				if r[i] != e[i] {
					t.Fatalf("inc=%d N=%d i=%d r=%f e=%f", inc, N, i, r[i],
						e[i])
				}
			}
		}
	}
}

var vf, wf []float32

func init() {
	vf = make([]float32, 514)
	wf = make([]float32, len(vf))
	for i := 0; i < len(vf); i++ {
		vf[i] = rand.Float32()
		wf[i] = rand.Float32()
	}
}

func BenchmarkSdsdot(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Sdsdot(len(vf), 10, vf, 1, wf, 1)
	}
}

func BenchmarkSdot(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Sdot(len(vf), vf, 1, wf, 1)
	}
}

func BenchmarkSnrm2(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Snrm2(len(vf), vf, 1)
	}
}

func BenchmarkSasum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Sasum(len(vf), vf, 1)
	}
}

func BenchmarkIsamax(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Isamax(len(vf), vf, 1)
	}
}

func BenchmarkSswap(b *testing.B) {
	b.StopTimer()
	x := make([]float32, len(vd))
	y := make([]float32, len(vd))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Sswap(len(x), x, 1, y, 1)
	}
}

func BenchmarkScopy(b *testing.B) {
	b.StopTimer()
	y := make([]float32, len(vf))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Scopy(len(vf), vf, 1, y, 1)
	}
}

func BenchmarkSaxpy(b *testing.B) {
	b.StopTimer()
	y := make([]float32, len(vf))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Saxpy(len(vf), -1.0, vf, 1, y, 1)
	}
}

func BenchmarkSscal(b *testing.B) {
	b.StopTimer()
	y := make([]float32, len(vf))
	copy(y, vf)
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Sscal(len(y), -1.0, y, 1)
	}
}
