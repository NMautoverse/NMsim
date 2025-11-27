# Simulation method that uses the provided control stream as is

The simplest of all method. It does nothing (but again, `NMsim` handles
\`\$INPUT\`, \`\$DATA\`, \`\$TABLE\` and more. Use this for instance if
you already created a simulation (or estimation actually) control stream
and want NMsim to run it on different data sets.

## Usage

``` r
NMsim_asis(file.sim, file.mod, data.sim)
```

## Arguments

- file.sim:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- file.mod:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

- data.sim:

  See
  [`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.md).

## Value

Path to simulation control stream
