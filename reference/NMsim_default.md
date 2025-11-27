# Transform an estimated Nonmem model into a simulation control stream

The default behaviour of `NMsim`. Replaces any \$ESTIMATION and
\$COVARIANCE sections by a \$SIMULATION section.

## Usage

``` r
NMsim_default(
  file.sim,
  file.mod,
  data.sim,
  nsims = 1,
  onlysim = TRUE,
  replace.sim = TRUE,
  return.text = FALSE
)
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

- nsims:

  Number of replications wanted. The default is 1. If greater, multiple
  control streams will be generated.

- onlysim:

  Include \`ONLYSIM\` in \`\$SIMULATION\`? Default is \`TRUE\`. Only
  applied when \`replace.sim=\`TRUE\`.

- replace.sim:

  If there is a \$SIMULATION section in the contents of file.sim, should
  it be replaced? Default is yes. See the `list.section` argument to
  `NMsim` for how to provide custom contents to sections with `NMsim`
  instead of editing the control streams beforehand.

- return.text:

  If TRUE, just the text will be returned, and resulting control stream
  is not written to file.

## Value

Character vector of simulation control stream paths
