package main

import (
	"fmt"
	"blas"
)

func main() {
	a := []float64{1, 2, 3, 4, 5, 6, 7, 8, 9}
	b := []float64{1e8, 1e7, 1e6, 1e5, 1e4, 1e3, 100, 10, 1}

	r := blas.Ddot(4, a, 1, b, 2)
	fmt.Printf("Ddot: %f\n", r)


	r = blas.Dnrm2(1, a, 1)
	fmt.Printf("Ddot: %f\n", r)
}
