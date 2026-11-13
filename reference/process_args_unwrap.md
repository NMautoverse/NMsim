# Process args.unwrap specification into unwrap functions

Converts the user-friendly args.unwrap specification into a list of
functions that can be applied to arguments. Handles the "function"
keyword and validates custom functions.

## Usage

``` r
process_args_unwrap(args.unwrap, args = NULL)
```

## Arguments

- args.unwrap:

  Named list with unwrap specifications. Values can be: - "function"
  (string) to unwrap functions by code only - A function to apply to the
  argument - NULL (ignored)

- args:

  Named list of actual argument values (used to auto-detect functions)

## Value

Named list of functions to apply to arguments
