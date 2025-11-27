# Create text lines for OMEGA and SIGMA Nonmem sections

Create text lines for OMEGA and SIGMA Nonmem sections

## Usage

``` r
NMcreateMatLines(omegas, as.one.block = FALSE, fix = FALSE, type)
```

## Arguments

- omegas:

  A data.table with at least \`i\`, \`j\` and \`value\` columns. See
  \`NMdata::NMreadExt\` and the pars element returned by that function.
  Must at least have columns \`i\`, \`j\`, \`value\`, \`iblock\`,
  \`blocksize\`, \`FIX\`.

- as.one.block:

  If \`TRUE\`, all values are printed as one block. If \`FALSE\`
  (default), matrix will be separeted into blocks based on position
  non-zero off-diagonal values. Generally speaking, for \`OMEGA\`
  matrices (var-cov matrices for ETAs), this should be \`FALSE\`, and
  for variance-covariance matrices (like \`THETAP\`), this should be
  \`TRUE\`.

- fix:

  Include \`FIX\` for all lines? If \`FALSE\`, fixing will not be
  modified. Notice, \`fix=TRUE\` will fix everything - individual
  parameters cannot be controlled. For finer control and way more
  features, see \`NMdata::NMwriteInits()\`.

- type:

  The matrix type. \`OMEGA\` or \`SIGMA\` - case in-sensitive. Will be
  used to print say \`\$OMEGA\` in front of each line.

## Value

Character vector
