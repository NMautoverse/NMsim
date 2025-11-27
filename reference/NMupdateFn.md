# Update file names in control stream to match model name

Update file names in control stream to match model name

## Usage

``` r
NMupdateFn(
  x,
  section,
  model,
  fnext,
  add.section.text,
  par.file,
  text.section,
  quiet = FALSE
)
```

## Arguments

- x:

  a control stream, path or \`NMctl\` object.

- section:

  What section to update

- model:

  Model name

- fnext:

  The file name extension of the file name to be updated (e.g., one of
  "tab", "csv", "msf").

- add.section.text:

  Addditional text to insert right after \$SECTION. It can be additional
  TABLE variables.

- par.file:

  The Nonmem parameter that specifies the file. In \$TABLE, this is
  FILE. In \$EST it's probably MSFO.

- text.section:

  This is used to overwrite the contents of the section. The section
  output file name will still handled/updated.

- quiet:

  Suppress messages? Default is \`FALSE\`.
