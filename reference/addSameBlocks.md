# Create a variable in inital value table to keep track of SAME blocks i.e. parameters that are part of a single distribution

Create a variable in inital value table to keep track of SAME blocks
i.e. parameters that are part of a single distribution

## Usage

``` r
addSameBlocks(inits)
```

## Arguments

- inits:

  Table of initial values as created by NMreadInits().

## Details

sameblock:

if not part of a distribution repeated using SAME: 0

if part of a distribution repeated using SAME: counter (1,2,...) of the
unique distribution blocks that are being reused.

Nsameblock: The number of SAME calls used for a distribution block. If
SAME(N) notation is used, Nsameblock=N.

## Author

Brian Reilly
