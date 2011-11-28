### Go implementation of BLAS (Basic Linear Algebra Subprograms)

Any function is implemented in generic Go and if it is justified, it is
optimized for AMD64 (using SSE2 instructions).

AMD64 implementation uses MOVUPS/MOVUPD instructions if all strides equal to 1
so it run fast on Nehalem, Sandy Bridge and newer processors but relatively
slow on older processors.

Any implemented function has its own unity test and benchmark.

#### Implemented functions

*Level 1*

Sdsdot, Sdot, Ddot, Snrm2, Dnrm2, Sasum, Dasum, Isamax, Idamax, Sswap, Dswap,
Scopy, Dcopy, Saxpy, Daxpy, Sscal, Dscal, Srotg, Drotg, Srot, Drot

*Level 2*

not implemented

*Level 3*

not implemented

####Example benchmarks

<table>
    <tr><th>Function</th><th>Generic Go</th><th>Optimized for AMD64</th></tr>
    <tr><td>Ddot</td><td>2825 ns/op</td><td>895 ns/op</td></tr>
    <tr><td>Dnrm2</td><td>2787 ns/op</td><td>597 ns/op</td></tr>
    <tr><td>Dasum</td><td>3145 ns/op</td><td>560 ns/op</td></tr>
    <tr><td>Sdsdot</td><td>3133 ns/op</td><td>1733 ns/op</td></tr>
    <tr><td>Sdot</td><td>2832 ns/op</td><td>508 ns/op</td></tr>
</table>

#### Documentation

http://gopkgdoc.appspot.com/pkg/github.com/ziutek/blas
