# first path that works

When using scripts on different systems, the Nonmem path may change from
run to run. With this function you can specify a few paths, and it will
return the one that works on the system in use.

## Usage

``` r
prioritizePaths(paths, must.work = FALSE)
```

## Arguments

- paths:

  vector of file paths. Typically to Nonmem executables.

- must.work:

  If TRUE, an error is thrown if no paths are valid.

## Examples

``` r
library(NMdata)
#> NMdata 0.2.3. Browse NMdata documentation at
#> https://NMautoverse.github.io/NMdata/
NMdataConf(path.nonmem = prioritizePaths(c(
  "/opt/NONMEM/nm75/run/nmfe75",
  "C:/nm75g64/run/nmfe75.bat")
))
#> No paths valid
```
