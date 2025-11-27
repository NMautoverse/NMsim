# Print OMEGA and SIGMA matrices for NONMEM sections in block format. Note: This function currently only works with fixed blocks as in the NMsim_NWPRI functionality for printing \$THETAPV.

Print OMEGA and SIGMA matrices for NONMEM sections in block format.
Note: This function currently only works with fixed blocks as in the
NMsim_NWPRI functionality for printing \$THETAPV.

## Usage

``` r
prettyMatLines(block_mat_string)
```

## Arguments

- block_mat_string:

  Output of NMsim::NMcreateMatLines. This is a string of OMEGA/SIGMA
  estimates that will be wrapped onto multiple lines for ease of reading
  in NONMEM control streams.

## Value

Character vector

## Details

This function is currently not used by any functions in NMsim and is for
now deprecated. NMcreateMatLines() handles this internally.
