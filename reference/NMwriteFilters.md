# Write IGNORE/ACCEPT filters to NONMEM model

Write IGNORE/ACCEPT filters to NONMEM model

## Usage

``` r
NMwriteFilters(file = NULL, lines = NULL, filters, write)
```

## Arguments

- file:

  Path to control stream. Use \`file\` or \`lines\`.

- lines:

  Control stream as text lines. Use \`file\` or \`lines\`.

- filters:

  A data frome with filters, like returned by \`NMreadFilters()\`.

- write:

  If \`file\` is provided, write the results to file? If \`lines\` is
  used, \`write\` cannot be used.

## Value

Resulting control stream (lines) as character vector
