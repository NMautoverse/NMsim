# Typical subject simiulation method

Like `NMsim_default` but with all ETAs=0, giving a "typical subject"
simulation. Do not confuse this with a "reference subject" simulation
which has to do with covariate values. Technically all ETAs=0 is
obtained by replacing `$OMEGA` by a zero matrix.

## Usage

``` r
NMsim_typical(file.sim, file.mod, data.sim, return.text = FALSE)
```

## Arguments

- file.sim:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- file.mod:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- data.sim:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- return.text:

  If TRUE, just the text will be returned, and resulting control stream
  is not written to file.

## Value

Path to simulation control stream
