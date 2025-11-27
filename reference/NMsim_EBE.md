# Use emperical Bayes estimates to simulate re-using ETAs

Simulation reusing ETA values from estimation run or otherwise specified
ETA values. For observed subjects, this is refered to as emperical Bayes
estimates (EBE). The .phi file from the estimation run must be found
next to the .lst file from the estimation.This means that ID values in
the (simulation) input data must be ID values that were used in the
estimation too. Runs an `$ESTIMATION MAXEVAL=0` but pulls in ETAs for
the ID's found in data. No `$SIMULATION` step is run which may affect
how for instance residual variability is simulated, if at all. You can
also specify a different `.phi` file which can be a simulation result.

## Usage

``` r
NMsim_EBE(file.sim, file.mod, data.sim, file.phi, return.text = FALSE)
```

## Arguments

- file.sim:

  The path to the control stream to be edited. This function overwrites
  the contents of the file pointed to by file.sim.

- file.mod:

  Path to the path to the original input control stream provided as
  \`file.mod\` to \`NMsim()\`.

- data.sim:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- file.phi:

  A phi file to take the known subjects from. The default is to replace
  the filename extension on file.mod with .phi. A different .phi file
  would be used if you want to reuse subjects simulated in a previous
  simulation.

- return.text:

  If TRUE, just the text will be returned, and resulting control stream
  is not written to file.

## Value

Path to simulation control stream

## See also

simPopEtas
