# Set variability parameters to zero

Set variability parameters to zero

## Usage

``` r
typicalize(file.mod, lines, section, newfile)
```

## Arguments

- file.mod:

  path to control stream to edit

- lines:

  control stream as lines. Use either file.sim or lines.sim.

- section:

  The sections (parameter types) to edit. Default is \`c("OMEGA",
  "OMEGAP", "OMEGAPD")\`.

- newfile:

  path and filename to new run. If missing or NULL, output is returned
  as a character vector rather than written.
