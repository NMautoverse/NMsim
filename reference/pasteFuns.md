# Paste string to start of vector only

paste(str,x) will prepend str to all values of x. use pasteBegin to only
paste it to the first value of x.

## Usage

``` r
pasteBegin(x, add, ...)

pasteEnd(x, add, ...)
```

## Arguments

- x:

  A vector of strings

- add:

  A string to add

- ...:

  Aditional arguments to \`paste()\`.
