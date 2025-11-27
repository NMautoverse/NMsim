# clean up temporary directories left by PSN and NMsim.

clean up temporary directories left by PSN and NMsim.

## Usage

``` r
deleteTmpDirs(dir, methods, recursive = FALSE, delete = TRUE)
```

## Arguments

- dir:

  The directory in which to look for contents to clean

- methods:

  The sources to delete temporary content from. This is a character
  vector, and the defailt is \`c("nmsim","psn","psnfit","backup")\`.
  Each of these correspond to a preconfigured pattern.

- recursive:

  Look recursively in folder? Notice, matches will be deleted
  recursively (they are often directories). \`recursive\` controls
  whether they are searched for recursively.

- delete:

  Delete the found matches? If not, the matches are just reported, but
  nothing deleted.

## Value

data.table with identified items for deletion
