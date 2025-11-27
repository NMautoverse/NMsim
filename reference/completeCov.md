# Expand a set of covariate values into a data.set with reference value

Expand a set of covariate values into a data.set with reference value

## Usage

``` r
completeCov(covlist, data, col.id = "ID", sigdigs = 2)
```

## Arguments

- covlist:

  A covariate specififed in a list. See ?expandCovLists.

- data:

  See ?expandCovLists.

- col.id:

  The subject ID column name. Necessary because quantiles sould be
  quantiles of distribution of covariate on subjects, not on
  observations (each subject contributes once).

- sigdigs:

  Used for rounding of covariate values if using quantiles or if using a
  function to find reference.

## Examples

``` r
    NMsim:::completeCov(covlist=list(covvar="WEIGHTB",values=c(30,60,90),ref=50),sigdigs=3)
#>     covvar covval covvalc covlabel covref   type
#>     <char>  <num>   <num>   <char>  <num> <char>
#> 1: WEIGHTB     30      30  WEIGHTB     50  value
#> 2: WEIGHTB     60      60  WEIGHTB     50  value
#> 3: WEIGHTB     90      90  WEIGHTB     50  value
#> 4: WEIGHTB     50      50  WEIGHTB     50    ref
```
