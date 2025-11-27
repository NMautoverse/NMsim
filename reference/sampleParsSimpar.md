# Sample model parameters using the \`simpar\` package

Sample model parameters using the \`simpar\` package

## Usage

``` r
sampleParsSimpar(file.mod, nsim, format = "ext", seed.R, as.fun)
```

## Arguments

- file.mod:

  Path to model control stream. Will be used for both \`NMreadExt()\`
  and \`NMreadCov()\`, and extension will automatically be replaced by
  \`.ext\` and \`.cov\`.

- nsim:

  Number of sets of parameter values to generate. Passed to \`simpar\`.

- format:

  "ext" (default) or "wide".

- seed.R:

  seed value passed to set.seed().

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

## Value

A table with sampled model parameters

## Author

Sanaya Shroff, Philip Delff
