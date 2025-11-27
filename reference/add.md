# Create function that adds text elements to vector

Namely used to feed functions to modify control streams using
\`NMsim()\` arguments such as \`modify\`. Those functions are often
onveniently passed a function. \`add\` and \`overwrite\` are simple
shortcuts to creating such functions. Make sure to see examples.

## Usage

``` r
add(..., .pos = "bottom")
```

## Arguments

- ...:

  Elements to add.

- .pos:

  Either "top" or "bottom". Decides if new text is prepended or appended
  to existing text.

## Value

A function that adds the specified text to character vectors

## Examples

``` r
myfun <- add("b","d")
myfun("a")
#> [1] "a" "b" "d"
## If more convenient, you can add a vector instead.
myfun2 <- add(c("b","d"))
myfun2("a")
#> [1] "a" "b" "d"
myfun3 <- add("b","d",.pos="top")
myfun3("a")
#> [1] "b" "d" "a"
```
