package main

import (
	"fmt"
	"blas"
)

func main() {
	a := []float32{1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7}
	b := []float32{1e6, 1e5, 1e4, 1e3, 100, 10, 1,
		1e6, 1e5, 1e4, 1e3, 100, 10, 1}

	r := blas.Sdsdot(5, 10, a, 1, b, 1)
	fmt.Printf("Ddot: %f\n", r)


	//r = blas.Dnrm2(1, a, 1)
	//fmt.Printf("Dnrm2: %f\n", r)
}
