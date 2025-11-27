# Versatile text extractor from Nonmem (input or output) control streams

If you want to extract input sections like \$PROBLEM, \$DATA etc, see
NMreadSection. This function is more general and can be used to extract
eg result sections.

## Usage

``` r
NMextractText(
  file,
  lines,
  text,
  section,
  char.section,
  char.end = char.section,
  return = "text",
  keep.empty = FALSE,
  keep.name = TRUE,
  keep.comments = TRUE,
  as.one = TRUE,
  clean.spaces = FALSE,
  simplify = TRUE,
  match.exactly = TRUE,
  type = "mod",
  linesep = "\n",
  keepEmpty,
  keepName,
  keepComments,
  asOne
)
```

## Arguments

- file:

  A file path to read from. Normally a .mod or .lst. See lines and text
  as well.

- lines:

  Text lines to process. This is an alternative to using the file and
  text arguments.

- text:

  Use this argument if the text to process is one long character string,
  and indicate the line separator with the linesep argument. Use only
  one of file, lines, and text.

- section:

  The name of section to extract. Examples: "INPUT", "PK", "TABLE", etc.
  It can also be result sections like "MINIMIZATION".

- char.section:

  The section denoted as a string compatible with regular expressions.
  "\$" (remember to escape properly) for sections in .mod files, "0" for
  results in .lst files.

- char.end:

  A regular expression to capture the end of the section. The default is
  to look for the next occurrence of char.section.

- return:

  If "text", plain text lines are returned. If "idx", matching line
  numbers are returned. "text" is default.

- keep.empty:

  Keep empty lines in output? Default is FALSE. Notice, comments are
  removed before empty lines are handled if \`keep.comments=TRUE\`.

- keep.name:

  Keep the section name in output (say, "\$PROBLEM") Default is TRUE. It
  can only be FALSE, if return="text".

- keep.comments:

  Default is to keep comments. If FALSE, the will be removed.

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
  table is found? Default is TRUE which is desirable for interactive
  analysis. For programming, you probably want FALSE.

- match.exactly:

  Default is to search for exact matches of \`section\`. If FALSE, only
  the first three characters are matched. E.G., this allows "ESTIMATION"
  to match "ESTIMATION" or "EST".

- type:

  Either mod, res or NULL. mod is for information that is given in .mod
  (.lst file can be used but results section is disregarded). If NULL,
  NA or empty string, everything is considered.

- linesep:

  If using the text argument, use linesep to indicate how lines should
  be separated.

- keepEmpty:

  Deprecated. See keep.empty.

- keepName:

  Deprecated. See keep.name.

- keepComments:

  Deprecated. See keep.comments.

- asOne:

  Deprecated. See as.one.

## Value

character vector with extracted lines.

## Details

This function is planned to get a more general name and then be called
by NMreadSection.

## See also

Other Nonmem:
[`NMreadSection()`](https://nmautoverse.github.io/NMsim/reference/NMreadSection.md)

## Examples

``` r
library(NMdata)
#> NMdata 0.2.2. Browse NMdata documentation at
#> https://NMautoverse.github.io/NMdata/
NMreadSection(system.file("examples/nonmem/xgxr001.lst", package = "NMdata"),section="DATA")
#> [1] "$DATA      xgxr1.csv IGNORE=@ IGNORE=(FLAG.NE.0)"
```
