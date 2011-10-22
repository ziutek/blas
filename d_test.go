package blas

import (
	"testing"
	"rand"
	"math"
)

func eqCheck(t *testing.T, inc, N int, r, e float64) {
	t.Logf("inc=%d N=%d : r=%f e=%f e-r=%g", inc, N, r, e, e-r)
	if r != e {
		t.FailNow()
	}
}

var (
	vx = []float64{1, 2, 3, 4, 5, 6, 7, 8, 9}
	vy = []float64{1e8, 1e7, 1e6, 1e5, 1e4, 1e3, 100, 10, 1}
)

func TestDdot(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		e := 0.0
		k := 0
		for N := 0; N <= len(vx) / inc; N++ {
			if N > 0 {
				e += vx[k] * vy[k]
				k += inc
			}
			r := Ddot(N, vx, inc, vy, inc)
			eqCheck(t, inc, N, r, e)
		}
	}
}

func TestDnrm2(t *testing.T) {
	for inc := 1; inc < 9; inc++ {
		for N := 0; N <= len(vx) / inc; N++ {
			e := math.Sqrt(Ddot(N, vx, inc, vx, inc))
			r := Dnrm2(N, vx, inc)
			eqCheck(t, inc, N, r, e)
		}
	}
}

func TestDasum(t *testing.T) {
	vx := []float64{-1, -2, 3, -4, -5, -6, 7, -8, 9}
	for inc := 1; inc < 9; inc++ {
		e := 0.0
		k := 0
		for N := 0; N <= len(vx) / inc; N++ {
			if N > 0 {
				e += math.Abs(vx[k])
				k += inc
			}
			r := Dasum(N, vx, inc)
			eqCheck(t, inc, N, r, e)
		}
	}
}


var rx, ry []float64

func init() {
	rx = make([]float64, 514)
	ry = make([]float64, len(rx))
	for i := 0; i < len(rx); i++ {
		rx[i] = rand.Float64()
		ry[i] = rand.Float64()
	}
}

func BenchmarkDdot(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Ddot(len(rx), rx, 1, ry, 1)
	}
}

func BenchmarkDnrm2(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Dnrm2(len(rx), rx, 1)
	}
}

func BenchmarkDasum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Dasum(len(rx), rx, 1)
	}
}
