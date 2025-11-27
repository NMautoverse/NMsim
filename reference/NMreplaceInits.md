# Replace initial values in Nonmem control stream

Replace initial values in Nonmem control stream

## Usage

``` r
NMreplaceInits(inits, fix = FALSE, ...)
```

## Arguments

- inits:

  A data.frame with new initial estimates, same style as returned by
  NMdata::NMreadExt. Column\` par.type\` can contain elements THETA,
  OMEGA, SIGMA.

- ...:

  Passed to NMdata::NMwriteSection. This is important for NMreplaceInits
  to run at all.

## Value

The modified control stream
