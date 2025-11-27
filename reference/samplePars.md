# Sample model parameters using \`mvrnorm\` or the \`simpar\` package

Sample model parameters using \`mvrnorm\` or the \`simpar\` package

## Usage

``` r
samplePars(file.mod, nsims, method, seed.R, format = "ext", as.fun)
```

## Arguments

- file.mod:

  Path to model control stream. Will be used for both \`NMreadExt()\`
  and \`NMreadCov()\`, and extension will automatically be replaced by
  \`.ext\` and \`.cov\`.

- nsims:

  Number of sets of parameter values to generate. Passed to \`simpar\`.

- method:

  The sampling method. Options are "mvrnorm" and "simpar". Each have
  pros and cons. Notice that both methods are fully automated as long as
  ".ext" and ".cov" files are available from model estimation.

- seed.R:

  seed value passed to set.seed().

- format:

  The returned data set format "ext" (default) or "wide". "ext" is a
  long-format, similar to what \`NMdata::NMreadExt()\` returns.

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

## Value

A table with sampled model parameters

## Details

samplePars() uses internal methods to sample using mvrnorm or simpar.
Also be aware of NMsim_NWPRI which is based on the Nonmem-internal NWPRI
subroutine. NMsim_NWPRI is much faster to execute. Simulation with
paramater uncertainty on variance components (\`OMEGA\` and \`SIGMA\`)
is only reliable starting from Nonmem 7.6.0.

mvrorm: The multivariate normal distribution does not ensure
non-negative variances. Negative variances are not allowed and can not
be simulated. To avoid this, \`method=mvrnorm\` truncates negative
variance diagonal elements at zero.

simpar: simpar must be installed.

Please refer to publications and vignettes for more information on
sampling methods.

## Author

Sanaya Shroff, Philip Delff
