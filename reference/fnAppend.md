# paste something before file name extension.

Append a file name like file.mod to file_1.mod or file_pk.mod. If it's a
number, we can pad some zeros if wanted. The separator (default is
underscore) can be modified.

## Usage

``` r
fnAppend(
  fn,
  x,
  pad0 = 0,
  sep = "_",
  collapse = sep,
  position = "append",
  allow.noext = FALSE
)
```

## Arguments

- fn:

  The file name or file names to modify.

- x:

  A character string or a numeric to add to the file name. If a vector,
  the vector is collapsed to a single string, using \`sep\` as separator
  in the collapsed string.

- pad0:

  In case x is numeric, a number of zeros to pad before the appended
  number. This is useful if you are generating say more than 10 files,
  and your counter will be 01, 02,.., 10,... and not 1, 2,...,10,...

- sep:

  The separator between the existing file name (until extension) and the
  addition.

- collapse:

  If \`x\` is of length greater than 1, the default is to collapse the
  elements to a single string using \`sep\` as separator. See the
  \`collapse\` argument to \`?paste\`. If you want to treat them as
  separate strings, use \`collapse=NULL\` which will lead to generation
  of separate file names. However, currently \`fn\` or \`x\` must be of
  length 1.

- position:

  "append" (default) or "prepend".

- allow.noext:

  Allow \`fn\` to be string(s) without extensions? Default is \`FALSE\`
  in which case an error will be thrown if \`fn\` contains strings
  without extensions. If \`TRUE\`, \`x\` will be appended to fn in these
  cases.

## Value

A character (vector)
