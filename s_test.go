package blas

import (
	"testing"
	"rand"
	"math"
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
		for N := 0; N <= len(xf) / inc; N++ {
			if N > 0 {
				e += float64(xf[k]) * float64(yf[k])
				k += inc
			}
			r := Sdsdot(N, 10, xf, inc, yf, inc)
			fCheck(t, inc, N, r, float32(e + 10))
		}
	}
}

func TestSdot(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		e := float32(0)
		k := 0
		for N := 0; N <= len(xf) / inc; N++ {
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
		for N := 0; N <= len(xf) / inc; N++ {
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
		for N := 0; N <= len(xf) / inc; N++ {
			if N > 0 {
				e += float32(math.Abs(float64(xf[k])))
				k += inc
			}
			r := Sasum(N, xf, inc)
			fCheck(t, inc, N, r, e)
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
