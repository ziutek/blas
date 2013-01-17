package blas

import (
	"math"
	"math/rand"
	"testing"
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
		for N := 0; N <= len(xd)/inc; N++ {
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
		for N := 0; N <= len(xd)/inc; N++ {
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
		for N := 0; N <= len(xd)/inc; N++ {
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
	xd := []float64{-1, -2, 3, -4, -5, 0, -5, 0, 4, 2, 3, -1, 4, -2, -9, 0,
		-1, 0, 0, 2, 2, -8, 2, 1, 0, 2, 4, 5, 8, 1, -7, 2, 9, 0, 1, -1}
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd)/inc; N++ {
			i_max := 0
			x_max := 0.0
			for i := 0; i < N; i++ {
				x := math.Abs(xd[i*inc])
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
		for N := 0; N <= len(xd)/inc; N++ {
			copy(a, xd)
			copy(b, yd)
			Dswap(N, a, inc, b, inc)
			for i := 0; i < len(a); i++ {
				if i <= inc*(N-1) && i%inc == 0 {
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

func TestDcopy(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd)/inc; N++ {
			a := make([]float64, len(xd))
			Dcopy(N, xd, inc, a, inc)
			for i := 0; i < inc*N; i++ {
				if i%inc == 0 {
					if a[i] != xd[i] {
						t.Fatalf("inc=%d N=%d i=%d r=%f e=%f", inc, N, i, a[i],
							xd[i])
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

func TestDaxpy(t *testing.T) {
	for _, alpha := range []float64{0, -1, 1, 3} {
		for inc := 1; inc < 9; inc++ {
			for N := 0; N <= len(xd)/inc; N++ {
				r := make([]float64, len(xd))
				e := make([]float64, len(xd))
				copy(r, xd)
				copy(e, xd)
				Daxpy(N, alpha, xd, inc, r, inc)
				for i := 0; i < N; i++ {
					e[i*inc] += alpha * xd[i*inc]
				}
				for i := 0; i < len(xd); i++ {
					if r[i] != e[i] {
						t.Fatalf("alpha=%f inc=%d N=%d i=%d r=%f e=%f",
							alpha, inc, N, i, r[i], e[i])
					}
				}
			}
		}

		/* This works only with assembler version.
		TODO: Write general test for bounds checking
		// Test bounds checks.
		panicked := func(f func()) (panicked bool) {
			panicked = false
			defer func() {
				if recover() != nil {
					panicked = true
				}
			}()
			f()
			return panicked
		}
		d2 := []float64{1.0, 1.0}
		d3 := []float64{1.0, 1.0, 1.0}
		if !panicked(func() { Daxpy(3, alpha, d2, 1, d2, 1) }) {
			t.Fatalf("Expected panic on index out of range.")
		}
		if !panicked(func() { Daxpy(2, alpha, d2, 2, d2, 1) }) {
			t.Fatalf("Expected panic on index out of range.")
		}
		if !panicked(func() { Daxpy(2, alpha, d2, 1, d2, 2) }) {
			t.Fatalf("Expected panic on index out of range.")
		}
		if !panicked(func() { Daxpy(3, alpha, d3, 1, d2, 1) }) {
			t.Fatalf("Expected panic on index out of range.")
		}
		if !panicked(func() { Daxpy(3, alpha, d2, 1, d3, 2) }) {
			t.Fatalf("Expected panic on index out of range.")
		}*/
	}
}

func TestDscal(t *testing.T) {
	alpha := 3.0
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xd)/inc; N++ {
			r := make([]float64, len(xd))
			e := make([]float64, len(xd))
			copy(r, xd)
			copy(e, xd)
			Dscal(N, alpha, r, inc)
			for i := 0; i < N; i++ {
				e[i*inc] = alpha * xd[i*inc]
			}
			for i := 0; i < len(xd); i++ {
				if r[i] != e[i] {
					t.Fatalf("inc=%d N=%d i=%d r=%f e=%f", inc, N, i, r[i],
						e[i])
				}
			}
		}
	}
}

func dEq(a, b, p float64) bool {
	eps := math.SmallestNonzeroFloat64 * 2
	r := math.Abs(a) + math.Abs(b)
	if r <= eps {
		return true
	}
	return math.Abs(a-b)/r < p
}

// Reference implementation of Drotg
func refDrotg(a, b float64) (c, s, r, z float64) {
	roe := b
	if math.Abs(a) > math.Abs(b) {
		roe = a
	}
	scale := math.Abs(a) + math.Abs(b)
	if scale == 0 {
		c = 1
	} else {
		r = scale * math.Sqrt((a/scale)*(a/scale)+(b/scale)*(b/scale))
		if math.Signbit(roe) {
			r = -r
		}
		c = a / r
		s = b / r
		z = 1
		if math.Abs(a) > math.Abs(b) {
			z = s
		}
		if math.Abs(b) >= math.Abs(a) && c != 0 {
			z = 1 / c
		}
	}
	return
}

func TestDrotg(t *testing.T) {
	vs := []struct{ a, b float64 }{
		{0, 0}, {0, 1}, {0, -1},
		{1, 0}, {1, 1}, {1, -1},
		{-1, 0}, {-1, 1}, {-1, -1},
		{2, 0}, {2, 1}, {2, -1},
		{-2, 0}, {-2, 1}, {-2, -1},
		{0, 2}, {1, 2}, {-1, 2},
		{0, -2}, {1, -2}, {-1, 2},
	}
	for _, v := range vs {
		c, s, _, _ := Drotg(v.a, v.b)
		ec, es, _, _ := refDrotg(v.a, v.b)
		if !dEq(c, ec, 1e-30) || !dEq(s, es, 1e-30) {
			t.Fatalf("a=%g b=%g c=%g ec=%g s=%g es=%g", v.a, v.b, c, ec, s, es)
		}
	}
}

func TestDrot(t *testing.T) {
	s2 := math.Sqrt(2)
	vs := []struct{ c, s float64 }{
		{0, 0}, {0, 1}, {0, -1}, {1, 0}, {-1, 0},
		{s2, s2}, {s2, -s2}, {-s2, s2}, {-s2, -s2},
	}
	x := make([]float64, len(xd))
	y := make([]float64, len(yd))
	ex := make([]float64, len(xd))
	ey := make([]float64, len(yd))
	for _, v := range vs {
		for inc := 1; inc < 9; inc++ {
			for N := 0; N <= len(xd)/inc; N++ {
				copy(x, xd)
				copy(y, yd)
				copy(ex, xd)
				copy(ey, yd)
				Dscal(N, v.c, ex, inc)          // ex *= c
				Daxpy(N, v.s, y, inc, ex, inc)  // ex += s*y
				Dscal(N, v.c, ey, inc)          // ey *= c
				Daxpy(N, -v.s, x, inc, ey, inc) // ey += (-s)*x

				// (x, y) = (c*x + s*y, c*y - s*x)
				Drot(N, x, inc, y, inc, v.c, v.s)

				for i, _ := range x {
					if !dEq(x[i], ex[i], 1e-20) || !dEq(y[i], ey[i], 1e-20) {
						t.Fatalf(
							"N=%d inc=%d c=%f s=%f i=%d x=%f ex=%f y=%f ey=%f",
							N, inc, v.c, v.s, i, x[i], ex[i], y[i], ey[i],
						)
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

func BenchmarkDcopy(b *testing.B) {
	b.StopTimer()
	y := make([]float64, len(vd))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Dcopy(len(vd), vd, 1, y, 1)
	}
}

func BenchmarkDaxpy(b *testing.B) {
	b.StopTimer()
	y := make([]float64, len(vd))
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Daxpy(len(vd), -1.0, vd, 1, y, 1)
	}
}

func BenchmarkDscal(b *testing.B) {
	b.StopTimer()
	y := make([]float64, len(vd))
	copy(y, vd)
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Dscal(len(y), -1.0, y, 1)
	}
}

func BenchmarkDrotg(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Drotg(0, 0)
		Drotg(0, 1)
		Drotg(0, -1)
		Drotg(1, 0)
		Drotg(1, 1)
		Drotg(1, -1)
		Drotg(-1, 0)
		Drotg(-1, 1)
		Drotg(-1, -1)
	}
}

func BenchmarkDrot(b *testing.B) {
	b.StopTimer()
	x := make([]float64, len(vd))
	y := make([]float64, len(vd))
	copy(x, vd)
	copy(y, vd)
	c := math.Sqrt(2)
	s := c
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Drot(len(x), x, 1, y, 1, c, s)
	}
}
