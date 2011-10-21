### Go implementation of BLAS (Basic Linear Algebra Subprograms)

Any function is implemented in generic Go and if it is justified, it is
optimized for AMD64 (using SSE2 SIMD instructions).

Any implemented function has its own unity test and benchmark.

#### Implemented functions

_Level 1_

Ddot, Dnrm2, Dasum

_Level 2_

not implemented

_Level 3_

not implemented

#### Documentation

http://gopkgdoc.appspot.com/pkg/github.com/ziutek/blas
