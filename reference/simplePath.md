# Simplify file paths by dropping .. and //

Simplify file paths by dropping .. and //

## Usage

``` r
simplePath(path)
```

## Arguments

- path:

  single or multiple file or dir paths as strings.

## Value

Simplified paths as strings

## Examples

``` r
if (FALSE) { # \dontrun{
path <- c("ds/asf.t","gege/../jjj.r")
NMsim:::simplePath(path)
} # }
```
