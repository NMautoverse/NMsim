# Fill parameter names indexes in a data set

Add par.type, i, j to a data.table that has parameter already

## Usage

``` r
addParType(pars, suffix, add.idx, overwrite = FALSE)
```

## Arguments

- pars:

  Table of parameters to augment with additional columns

- suffix:

  Optional string to add to all new column names. Maybe except \`i\` and
  \`j\`.

- add.idx:

  Add \`i\` and \`j\`? Default is \`TRUE\` if no suffix is supplied, and
  \`FALSE\` if a suffix is specified.

- overwrite:

  Overwrite non-missing values? Default is \`FALSE\`.

## Details

\`addParType()\` fills in data sets of Nonmem parameter values to
include the following variables (columns):

- parameter: THETA1 , OMEGA(1,1), SIGMA(1,1), OBJ, SAEMOBJ

- par.name: THETA(1), OMEGA(1,1), SIGMA(1,1), OBJ, SAEMOBJ

- par.type THETA, OMEGA, SIGMA, OBJ

- i: 1, 1, 1, NA, NA (No indexes for OBJ)

- i: NA, 1, 1, NA, NA (j not defined for THETA)

As a last step, addParameter is called with overwrite=FALSE. This fills
parameter and par.name. Combined, if parameter is in pars, it is used.
If not, par.type, i, and j are used.

In the provided data set, parameter is allowed to have thetas as
THETA(1) (the par.name format). These will however be overwritten with
the described format above.
