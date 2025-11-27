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
