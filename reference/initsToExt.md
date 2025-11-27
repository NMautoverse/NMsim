# Convert inits elements to a parameter data.frame

Convert inits elements to a parameter data.frame

## Usage

``` r
initsToExt(elements)
```

## Arguments

- elements:

  The elements object produced by \`NMreadInits()\`.

## Details

initsToExt is misleading. It is not a reference to the initstab, but
actually the elements object returned by NMreadInits. The elements
object is more detailed as it contains information about where
information is found in control stream lines. The \`ext\` object is a
parameter \`data.frame\`, same format as returned by
\`NMdata::NMreadExt()\`.
