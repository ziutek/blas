### Go implementation of BLAS (Basic Linear Algebra Subprograms)

Any function is implemented in generic Go and if it is justified, it is
optimized for AMD64 (using SSE2 SIMD instructions).

Any implemented function has its own unity test and benchmark.

####Example benchmarks

Generic Go code:

    blas.BenchmarkDdot	 1000000	      2895 ns/op
    blas.BenchmarkDnrm2	 1000000	      2745 ns/op
    blas.BenchmarkDasum	  500000	      3180 ns/op

Optimized AMD64 code:

    blas.BenchmarkDdot	 2000000	       898 ns/op
    blas.BenchmarkDnrm2	 5000000	       598 ns/op
    blas.BenchmarkDasum	 5000000	       567 ns/op

#### Implemented functions

*Level 1*

Ddot, Dnrm2, Dasum

*Level 2*

not implemented

*Level 3*

not implemented

#### Documentation

http://gopkgdoc.appspot.com/pkg/github.com/ziutek/blas
