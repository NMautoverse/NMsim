# Generate a population based on a Nonmem model

Rather than simulating new subjects for each simulation, use this to
create eta's that can be (re-)used for simulations with \`NMsim_BEE()\`.
Although setting a seed for a simulation ensures reproducibility of a
specific simulation, changing details of the data set is likely to break
that reproducibility. Use \`simPopEtas()\` to ensure that a subject with
a specific ID will always be simulated with the same eta values. This
can also be used to reuse subjects between treatments in a simulation.

## Usage

``` r
simPopEtas(
  file,
  N,
  seed.R,
  pars,
  file.phi,
  overwrite = FALSE,
  as.fun,
  file.mod,
  seed,
  ...
)
```

## Arguments

- file:

  Passed to \`NMdata::NMreadExt()\`. Path to ext file. By default,
  \`NMreadExt()\` uses a\`auto.ext=TRUE\` which means that the file name
  extension is replaced by \`.ext\` (so you can normally specify a
  control stream path too). If your ext file name extension is not
  \`.ext\`, add \`auto.ext=FALSE\` (see ...).

- N:

  Number of subjects to generate

- seed.R:

  Optional seed. Will be passed to \`set.seed\`. Same thing as running
  \`set.seed\` just before calling \`simPopEtas()\`.

- pars:

  A long-format parameter table containing par.type and i columns. If
  this is supplied, the parameter values will not be read from an ext
  file, and file has no effect. If an ext file is available, it is most
  likely better to use the file argument.

- file.phi:

  An optional phi file to write the generated subjects to. This will
  generate a Nonmem-style \`.phi\` file that can be reused in
  combination with \`NMsim_EBE\`.

- overwrite:

  If \`file.phi\` exists already, overwrite it? Default is \`FALSE\`.

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

- file.mod:

  Deprecated. Use file instead.

- seed:

  Deprecated. Use seed.R instead.

- ...:

  Additional arguments passed to NMdata::NMreadExt().

## Value

A data.frame
