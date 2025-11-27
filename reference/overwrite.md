# Create function that modifies text elements in a vector Namely used to feed functions to modify control streams using \`NMsim()\` arguments such as \`modify\`. Those functions are often onveniently passed a function. \`add\` and \`overwrite\` are simple shortcuts to creating such functions. Make sure to see examples.

Create function that modifies text elements in a vector Namely used to
feed functions to modify control streams using \`NMsim()\` arguments
such as \`modify\`. Those functions are often onveniently passed a
function. \`add\` and \`overwrite\` are simple shortcuts to creating
such functions. Make sure to see examples.

## Usage

``` r
overwrite(..., fixed = TRUE)
```

## Arguments

- ...:

  Passed to \`gsub()\`

- fixed:

  This is passed to gsub(), but \`overwrite()\`'s default behavior is
  the opposite of the one of \`gsub()\`. Default is \`FALSE\` which
  means that strings that are exactly matched will be replaced. This is
  useful because strings like \`THETA(1)\` contains special characters.
  Use \`fixed=FALSE\` to use regular expressions. Also, see other
  arguments accepted by \`gsub()\` for advanced features.

## Value

A function that runs \`gsub\` to character vectors

## Examples

``` r
myfun <- overwrite("b","d")
myfun(c("a","b","c","abc"))
#> [1] "a"   "d"   "c"   "adc"
## regular expressions
myfun2 <- overwrite("b.*","d",fixed=FALSE)
myfun2(c("a","b","c","abc"))
#> [1] "a"  "d"  "c"  "ad"
```
