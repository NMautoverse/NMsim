# Tabulate information from parameter sections in control streams

Tabulate information from parameter sections in control streams

## Usage

``` r
NMreadInits(file, lines, section, return = "pars", as.fun)
```

## Arguments

- file:

  Path to a control stream. See \`lines\` too.

- lines:

  A control stream as text lines. Use this or \`file\`.

- section:

  The section to read. Typically, "theta", "omega", or "sigma". Default
  is those three.

- return:

  By default (when `return="pars"`, a parameter table with initial
  values, FIX, lower and upper bounds etc. In most cases, that is what
  is needed to derive information about parameter definitions. If
  `return="all"`, two additional tables are returned which can be used
  if the aim is to modify and write the resulting parameters to a
  control stream.

- as.fun:

  See ?NMscanData

## Value

A \`data.frame\` with parameter values. If \`return="all"\`, a list of
three tables.
