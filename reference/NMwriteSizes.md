# Create or update \$SIZES in a control stream

Update \$SIZES parameters in a control stream. The control stream can be
in a file or provided as a character vector (file lines).

## Usage

``` r
NMwriteSizes(
  file.mod = NULL,
  newfile,
  lines = NULL,
  wipe = FALSE,
  write = !is.null(newfile),
  ...
)
```

## Arguments

- file.mod:

  A path to a control stream. See also alternative \`lines\` argument.
  Notice, if \`write\` is \`TRUE\` (default) and \`newfile\` is not
  provided, \`file.mod\` will be overwritten.

- newfile:

  An optional path to write the resulting control stream to. If nothing
  is provided, the default is to overwrite \`file.mod\`.

- lines:

  Control stream lines as a character vector. If you already read the
  control stream - say using \`NMdata::NMreadSection()\`, use this to
  modify the text lines.

- wipe:

  The default behavior (\`wipe=FALSE\`) is to add the \`\$SIZES\` values
  to any existing values found. If SIZES parameter names are overlapping
  with existing, the values will be updated. If \`wipe=TRUE\`, any
  existing \`\$SIZES\` section is disregarded.

- write:

  Write results to \`newfile\`?

- ...:

  The \$SIZES parameters. Provided anything, like \`PD=40\` See
  examples.

## Value

Character lines with updated control stream

## Examples

``` r
## No existing SIZES in control stream
if (FALSE) { # \dontrun{
file.mod <- system.file("examples/nonmem/xgxr132.mod",package="NMdata")
newmod <- NMwriteSizes(file.mod,LTV=50,write=FALSE)
head(newmod)
} # }
## provide control stream as text lines
if (FALSE) { # \dontrun{
file.mod <- system.file("examples/nonmem/xgxr032.mod",package="NMdata")
lines <- readLines(file.mod)
newmod <- NMwriteSizes(lines=lines,LTV=50,write=FALSE)
head(newmod)
} # }
## By default (wipe=FALSE) variabels are added to SIZES 
if (FALSE) { # \dontrun{
lines.mod <- NMwriteSizes(file.mod,LTV=50,write=FALSE) 
newmod <- NMwriteSizes(lines=lines.mod,PD=51,write=FALSE)
head(newmod)
} # }
```
