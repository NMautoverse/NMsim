# Read data filters from a NONMEM model

Read data filters from a NONMEM model

## Usage

``` r
NMreadFilters(file, lines, filters.only = TRUE, as.fun)
```

## Arguments

- file:

  Control stream path

- lines:

  Control stream lines if already read from file

- filters.only:

  Return the filters only or also return the remaining text in a
  separate object? If \`FALSE\`, a list with the two objects is
  returned.

- as.fun:

  Function to run on the tables with filters.

## Value

A \`data.frame\` with filters
