# Drop spaces and odd characters. Use to ensure generated file names are usable.

Drop spaces and odd characters. Use to ensure generated file names are
usable.

## Usage

``` r
cleanStrings(x)
```

## Arguments

- x:

  a string to clean

## Value

A character vector

## Examples

``` r
NMsim:::cleanStrings("e w% # ff!l3:t,3?.csv")
#> [1] "ew%ffl3t3.csv"
NMsim:::cleanStrings("3!?:#;<>=, {}|=g+&-
.csv")
#> [1] "3g.csv"
```
