package blas

// Scalar product: x^T y
func Ddot(N int, X []float64, incX int, Y []float64, incY int) float64


// Euclidean norm: ||X||_2 = \sqrt {\sum X_i^2}
func Dnrm2(N int, X []float64, inxX int) float64

// Absolute sum: \sum |x_i
func Dasum(N int, X []float64, inxX int) float64


// Largest element of the vector X
func Idamax(N int, X []float64, inxX int) float64


// Exchange the elements of the vectors Y and Y
func Dswap(N int, X []float64, incX int, Y []float64, incY int)

// Copy the elements of the vector X into the vector Y
func Dcopy(N int, X []float64, incX int, Y []float64, incY int)

// Compute the sum: Y = \alpha X + Y
func Daxpy(N int, alpha float64, X []float64, incX int, Y []float64, incY int)
