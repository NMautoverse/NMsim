# Add degrees of freedom by OMEGA/SIGMA block

Calculate and add degrees of freedom to be used for simulation using the
inverse Wishart distribution.

## Usage

``` r
NWPRI_df(pars)
```

## Arguments

- pars:

  Parameters in long format, as returned by \`NMreadExt()\`.

## Value

A data.table with DF2 added. See details.

## Details

The degrees of freedom are calculated as DF =
2\*((est\*\*2)/(se\*\*2)) + 1 -blocksize-1 DF2 is then adjusted to not
be greater than the blocksize, and the minumum degrees of freedom
observed in the block is applied to the full block. For fixed
parameters, DF2 equals the blocksize.

## References

[inverse-Wishart degrees of freedom calculation for OMEGA and SIGMA:
NONMEM tutorial part II, supplement 1, part
C.](https://ascpt.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fpsp4.12422&file=psp412422-sup-0001-Supinfo1.pdf)

## See also

NMsim_NWPRI
