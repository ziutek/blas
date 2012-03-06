package blas

import (
	"math"
	"math/rand"
	"testing"
)

func fabs(f float32) float32 {
	return float32(math.Abs(float64(f)))
}

func fsqrt(f float32) float32 {
	return float32(math.Sqrt(float64(f)))
}

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
			e := fsqrt(Sdot(N, xf, inc, xf, inc))
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
				e += fabs(xf[k])
				k += inc
			}
			r := Sasum(N, xf, inc)
			fCheck(t, inc, N, r, e)
		}
	}
}

func TestIsamax(t *testing.T) {
	xf := []float32{-1, -2, 3, -4, -5, 0, -5, 0, 4, 2, 3, -1, 4, -2, -9, 0,
		-1, 0, 0, 2, 2, -8, 2, 1, 0, 2, 4, 5, 8, 1, -7, 2, 9, 0, 1, -1}
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(xf)/inc; N++ {
			i_max := 0
			x_max := float32(0.0)
			for i := 0; i < N; i++ {
				x := fabs(xf[i*inc])
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
			for i := 0; i < inc*N; i++ {
				if i%inc == 0 {
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
	for _, alpha := range []float32{0, -1, 1, 3} {
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
						t.Fatalf("alpha=%f inc=%d N=%d i=%d r=%f e=%f",
							alpha, inc, N, i, r[i], e[i])
					}
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

func fEq(a, b, p float32) bool {
	eps := float32(math.SmallestNonzeroFloat32 * 2)
	r := fabs(a) + fabs(b)
	if r <= eps {
		return true
	}
	return fabs(a-b)/r < p
}

// Reference implementation of Srotg
func refSrotg(a, b float32) (c, s, r, z float32) {
	roe := b
	if fabs(a) > fabs(b) {
		roe = a
	}
	scale := fabs(a) + fabs(b)
	if scale == 0 {
		c = 1
	} else {
		r = scale * fsqrt((a/scale)*(a/scale)+(b/scale)*(b/scale))
		if math.Signbit(float64(roe)) {
			r = -r
		}
		c = a / r
		s = b / r
		z = 1
		if fabs(a) > fabs(b) {
			z = s
		}
		if fabs(b) >= fabs(a) && c != 0 {
			z = 1 / c
		}
	}
	return
}

func TestSrotg(t *testing.T) {
	vs := []struct{ a, b float32 }{
		{0, 0}, {0, 1}, {0, -1},
		{1, 0}, {1, 1}, {1, -1},
		{-1, 0}, {-1, 1}, {-1, -1},
		{2, 0}, {2, 1}, {2, -1},
		{-2, 0}, {-2, 1}, {-2, -1},
		{0, 2}, {1, 2}, {-1, 2},
		{0, -2}, {1, -2}, {-1, 2},
	}
	for _, v := range vs {
		c, s, _, _ := Srotg(v.a, v.b)
		ec, es, _, _ := refSrotg(v.a, v.b)
		if !fEq(c, ec, 1e-20) || !fEq(s, es, 1e-20) {
			t.Fatalf("a=%g b=%g c=%g ec=%g s=%g es=%g", v.a, v.b, c, ec, s, es)
		}
	}
}

func TestSrot(t *testing.T) {
	s2 := fsqrt(2)
	vs := []struct{ c, s float32 }{
		{0, 0}, {0, 1}, {0, -1}, {1, 0}, {-1, 0},
		{s2, s2}, {s2, -s2}, {-s2, s2}, {-s2, -s2},
	}
	x := make([]float32, len(xf))
	y := make([]float32, len(yf))
	ex := make([]float32, len(xf))
	ey := make([]float32, len(yf))
	for _, v := range vs {
		for inc := 1; inc < 9; inc++ {
			for N := 0; N <= len(xf)/inc; N++ {
				copy(x, xf)
				copy(y, yf)
				copy(ex, xf)
				copy(ey, yf)
				Sscal(N, v.c, ex, inc)          // ex *= c
				Saxpy(N, v.s, y, inc, ex, inc)  // ex += s*y
				Sscal(N, v.c, ey, inc)          // ey *= c
				Saxpy(N, -v.s, x, inc, ey, inc) // ey += (-s)*x

				// (x, y) = (c*x + s*y, c*y - s*x) 
				Srot(N, x, inc, y, inc, v.c, v.s)

				for i, _ := range x {
					if !fEq(x[i], ex[i], 1e-7) || !fEq(y[i], ey[i], 1e-7) {
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

func BenchmarkSrotg(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Srotg(0, 0)
		Srotg(0, 1)
		Srotg(0, -1)
		Srotg(1, 0)
		Srotg(1, 1)
		Srotg(1, -1)
		Srotg(-1, 0)
		Srotg(-1, 1)
		Srotg(-1, -1)
	}
}

func BenchmarkSrot(b *testing.B) {
	b.StopTimer()
	x := make([]float32, len(vf))
	y := make([]float32, len(vf))
	copy(x, vf)
	copy(y, vf)
	c := fsqrt(2)
	s := c
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		Srot(len(x), x, 1, y, 1, c, s)
	}
}
