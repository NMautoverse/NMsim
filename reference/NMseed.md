# Add seed string to simulation model data.table

This is an internal NMsim function.

## Usage

``` r
NMseed(models, nseeds, dist, values, fun.seed = seedFunDefault)
```

## Arguments

- models:

  A data.frame containing model paths etc as created by
  [`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- nseeds:

  Number of seeds in each simulation control stream. Default is to match
  length of dist.

- dist:

  Distribution of random sources. These character strings will be pasted
  directly into the Nonem control streams after the seed values. Default
  is "" which means one normal distribution. `dist=c("","UNIFORM")` will
  give two seeds with random sources following a normal and a uniform
  distribution.

- values:

  Optionally, seed values. This can be a data.frame with as many columns
  as random sources.

## Value

An updated data.table with simulation model information including seed
strings.
