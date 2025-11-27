# Create data set where each covariate is univariately varied

Each covariate is univariately varied while other covariates are kept at
reference values. This structure is often used for forest-plot type
simulations.

## Usage

``` r
forestDefineCovs(
  ...,
  data,
  col.id = "ID",
  sigdigs = 2,
  reduce.ref = TRUE,
  as.fun
)
```

## Arguments

- ...:

  Covariates provided as lists - see examples. The name of the arguement
  must match columns in data set. An element called ref must contain
  either a reference value or a function to use to derive the reference
  value from data (e.g. \`median\`). Provide either \`values\` or
  \`quantiles\` to define the covariate values of interest (typically,
  the values that should later be simulated and maybe shown in a forest
  plot). \`label\` is optional - if missing, the argument name will be
  used. If quantiles are requested, they are derived after requiring
  unique values for each subject.

- data:

  A data set needed if the reference(s) value of one or more covariates
  is/are provided as functions (like median), or if covariate values are
  provided as quantiles.

- col.id:

  The subject ID column name. Necessary because quantiles sould be
  quantiles of distribution of covariate on subjects, not on
  observations (each subject contributes once).

- sigdigs:

  Used for rounding of covariate values if using quantiles or if using a
  function to find reference.

- reduce.ref:

  If \`TRUE\` (default), only return one row with all reference values.
  If \`FALSE\` there will be one such row for each covariate. When
  reduced to one line, all columns related to covariate-level
  information such as covariate name will contain \`NA\` for the
  reference.

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

## Value

A data.frame

## Examples

``` r
if (FALSE) { # \dontrun{
file.mod <- system.file("examples/nonmem/xgxr134.mod",package="NMdata")
res <- NMdata::NMscanData(file.mod)
forestDefineCovs(
    WEIGHTB=list(ref=70,values=c(40,60,80,100),label="Bodyweight (kg)"),
## notice, values OR quantiles can be provided
    AGE=list(ref=median, quantiles=c(10,25,75,90)/100, label="Age (years)"
             ),
    data=res
)
} # }
```
