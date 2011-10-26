package blas

type Order int
const (
	RowMajor = Order(101)
	ColMajor = Order(102)
)

type Transpose int
const (
	NoTrans = Transpose(111)
	Trans   = Transpose(112)
)
