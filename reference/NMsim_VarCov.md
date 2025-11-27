# Simulate with parameter values sampled from a covariance step

Like `NMsim_default` but \`\$THETA\`, \`\$OMEGA\`, and \`SIGMA\` are
drawn from distribution estimated in covariance step. A successful
covariance step must be available from the estimation. In case the
simulation leads to negative diagonal elements in \$OMEGA and \$SIGMA,
those values are truncated at zero. For simulation with parameter
variability based on bootstrap results, use `NMsim_default`.

This function does not run any simulations. To simulate, using this
method, see \`NMsim()\`.

## Usage

``` r
NMsim_VarCov(
  file.sim,
  file.mod,
  data.sim,
  nsims,
  method.sample = "mvrnorm",
  ext,
  write.ext = NULL,
  ...
)
```

## Arguments

- file.sim:

  The path to the control stream to be edited. This function overwrites
  the contents of the file pointed to by file.sim.

- file.mod:

  Path to the path to the original input control stream provided as
  \`file.mod\` to \`NMsim()\`.

- data.sim:

  Included for compatibility with \`NMsim()\`. Not used.

- nsims:

  Number of replications wanted. The default is 1. If greater, multiple
  control streams will be generated.

- method.sample:

  When \`ext\` is not used, parameters are sampled, using
  \`samplePars()\`. \`method\` must be either \`mvrnorm\` or \`simpar\`.
  Only used when \`ext\` is not provided.

- ext:

  Parameter values in long format as created by \`readParsWide\` and
  \`NMdata::NMreadExt\`.

- write.ext:

  If supplied, a path to an rds file where the parameter values used for
  simulation will be saved.

- ...:

  Additional arguments passed to \`NMsim_default()\`.

## Value

Character vector of simulation control stream paths
