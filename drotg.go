package blas

import "math"

// Compute a Givens rotation (c,s) which zeroes the vector (a,b)
func Drotg(a, b float64) (c, s, r, z float64)

func drotg(a, b float64) (c, s, r, z float64) {
	abs_a := a
	if a < 0 {
		abs_a = -a
	}
	abs_b := b
	if b < 0 {
		abs_b = -b
	}
	roe := b
	if abs_a > abs_b {
		roe = a
	}
	scale := abs_a + abs_b
	if scale == 0 {
		c = 1
	} else {
		sa := a / scale
		sb := b / scale
		r = scale * math.Sqrt(sa*sa+sb*sb)
		if roe < 0 {
			r = -r
		}
		c = a / r
		s = b / r
		z = 1
		if abs_a > abs_b {
			z = s
		} else {
			if c != 0 {
				z /= c
			}
		}
	}
	return
}
