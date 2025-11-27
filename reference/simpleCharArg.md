# Check that a variable is a single character string meeting specified requirements

Check that a variable is a single character string meeting specified
requirements

## Usage

``` r
simpleCharArg(name.arg, val.arg, default, accepted, lower = TRUE, clean = TRUE)
```

## Arguments

- name.arg:

  Name of the argument

- val.arg:

  argument value

- default:

  If val.arg is NULL, what should be returned?

- accepted:

  What values are allowed

- lower:

  run tolower?

- clean:

  clean white spaces?

## Value

The resulting parameter value

## Details

Better options may be available in packages like checkmate. This
function doesn't only check the parameter value, it also sets it to the
default value if missing.
