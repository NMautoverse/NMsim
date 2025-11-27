# Execute Nonmem inside a dedicated directory

Like PSN's execute with less features. But easier to control from
NMexec. NMexecDirectory is not intended to be run by the user. Use
`NMexec` or `NMsim` instead.

## Usage

``` r
NMexecDirectory(
  file.mod,
  path.nonmem,
  files.needed,
  dir.data = "..",
  system.type,
  clean,
  sge = nc > 1,
  nc = 1,
  pnm,
  nmfe.options,
  fun.post = NULL
)
```

## Arguments

- file.mod:

  Path to a Nonmem input control stream.

- path.nonmem:

  Path to Nonmem executable. You may want to control this with
  [`NMdata::NMdataConf`](https://nmautoverse.github.io/NMdata/reference/NMdataConf.html).

- files.needed:

  Files needed to run the control stream. This cold be a .phi file from
  which etas will be read. Notice, input data set will be handled
  automatically, you do not need to specify that.

- dir.data:

  If NULL, data will be copied into the temporary directory, and Nonmem
  will read it from there. If not NULL, dir.data must be the relative
  path from where Nonmem is run to where the input data file is stored.
  This would be ".." if the run directory is created in a directory
  where the data is stored.

- clean:

  The degree of cleaning (file removal) to do after Nonmem execution. If
  \`method.execute=="psn"\`, this is passed to PSN's \`execute\`. If
  \`method.execute=="nmsim"\` a similar behavior is applied, even though
  not as granular. NMsim's internal method only distinguishes between 0
  (no cleaning), any integer 1-4 (default, quite a bit of cleaning) and
  5 (remove temporary dir completely).

## Value

A bash shell script for execution of Nonmem
