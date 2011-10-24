### Go implementation of BLAS (Basic Linear Algebra Subprograms)

Any function is implemented in generic Go and if it is justified, it is
optimized for AMD64 (using SSE2 SIMD instructions).

Any implemented function has its own unity test and benchmark.

#### Implemented functions

*Level 1*

Sdsdot, Sdot, Ddot, Dnrm2, Dasum

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

All benchmarks for stride == 1 (there is best optimization in assembler for
this special case). For other stride values optimized code will be 1.1-1.5
times slower.

#### Documentation

http://gopkgdoc.appspot.com/pkg/github.com/ziutek/blas
