# Generate a .phi file for further simulation with Nonmem

This will typically be used in a couple of different situations. One is
if a number of new subjects have been simulated and their ETAs should be
reused in subsequent simulations. Another is internally by NMsim when
simulating new subjects from models estimated with SAEM.

## Usage

``` r
genPhiFile(data, file, overwrite = FALSE)
```

## Arguments

- data:

  A dataset that contains "ID" and all \`ETA\`s. This can be obtained by
  \`NMdata::NMscanData\`.

- file:

  Path to the .phi file to be written.

- overwrite:

  If \`file\` exists already, overwrite it? Default is \`FALSE\`.

## Value

Invisibly, character lines (strings) optionally written to file

## See also

simPopEtas
