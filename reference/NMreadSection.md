# Extract sections of Nonmem control streams

This is a very commonly used wrapper for the input part of the model
file. Look NMextractText for more general functionality suitable for the
results part too.

## Usage

``` r
NMreadSection(
  file = NULL,
  lines = NULL,
  text = NULL,
  section,
  return = "text",
  keep.empty = FALSE,
  keep.name = TRUE,
  keep.comments = TRUE,
  as.one = TRUE,
  clean.spaces = FALSE,
  simplify = TRUE,
  keepEmpty,
  keepName,
  keepComments,
  asOne,
  ...
)
```

## Arguments

- file:

  A file path to read from. Normally a .mod or .lst. See lines also.

- lines:

  Text lines to process. This is an alternative to using the file
  argument.

- text:

  Deprecated, use \`lines\`. Use this argument if the text to process is
  one long character string, and indicate the line separator with the
  linesep argument (handled by NMextractText). Use only one of file,
  lines, and text.

- section:

  The name of section to extract without "\$". Examples: "INPUT", "PK",
  "TABLE", etc. Not case sensitive.

- return:

  If "text", plain text lines are returned. If "idx", matching line
  numbers are returned. "text" is default.

- keep.empty:

  Keep empty lines in output? Default is FALSE. Notice, comments are
  removed before empty lines are handled if \`keep.comments=TRUE\`.

- keep.name:

  Keep the section name in output (say, "\$PROBLEM") Default is FALSE.
  It can only be FALSE, if return="text".

- keep.comments:

  Default is to keep comments. If FALSE, the will be removed. See
  keep.empty too. Notice, there is no way for NMreadSection to keep
  comments and also drop lines that only contain comments.

- as.one:

  If multiple hits, concatenate into one. This will most often be
  relevant with name="TABLE". If FALSE, a list will be returned, each
  element representing a table. Default is TRUE. So if you want to
  process the tables separately, you probably want FALSE here.

- clean.spaces:

  If TRUE, leading and trailing are removed, and multiplied succeeding
  white spaces are reduced to single white spaces.

- simplify:

  If asOne=FALSE, do you want the result to be simplified if only one
  section is found? Default is TRUE which is desirable for interactive
  analysis. For programming, you probably want FALSE.

- keepEmpty:

  Deprecated. See keep.empty.

- keepName:

  Deprecated. See keep.name.

- keepComments:

  Deprecated. See keep.comments.

- asOne:

  Deprecated. See as.one.

- ...:

  Additional arguments passed to NMextractText

## Value

character vector with extracted lines.

## See also

Other Nonmem:
[`NMextractText()`](https://nmautoverse.github.io/NMsim/reference/NMextractText.md)

## Examples

``` r
library(NMdata)
NMreadSection(system.file("examples/nonmem/xgxr001.lst", package="NMdata"),section="DATA")
#> [1] "$DATA      xgxr1.csv IGNORE=@ IGNORE=(FLAG.NE.0)"
```
