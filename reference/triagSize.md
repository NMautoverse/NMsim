# Calculate number of elements for matrix specification

calculate number of elements in the diagonal and lower triangle of a
squared matrix, based on the length of the diagonal.

## Usage

``` r
triagSize(diagSize)
```

## Arguments

- diagSize:

  The length of the diagonal. Same as number of rows or columns.

## Value

An integer

## Examples

``` r
NMsim:::triagSize(1:5)
#> [1]  1  3  6 10 15
```
