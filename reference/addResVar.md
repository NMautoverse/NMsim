# Add residual variability based on parameter estimates

Add residual variability based on parameter estimates

## Usage

``` r
addResVar(
  data,
  path.ext,
  prop = NULL,
  add = NULL,
  log = FALSE,
  par.type = "SIGMA",
  trunc0 = TRUE,
  scale.par,
  subset,
  seed,
  col.ipred = "IPRED",
  col.ipredvar = "IPREDVAR",
  as.fun
)
```

## Arguments

- data:

  A data set containing indiviudual predictions. Often a result of
  NMsim.

- path.ext:

  Path to the ext file to take the parameter estimates from.

- prop:

  Parameter number of parameter holding variance of the proportional
  error component. If ERR(1) is used for proportional error, use prop=1.
  Can also refer to a theta number.

- add:

  Parameter number of parameter holding variance of the additive error
  component. If ERR(1) is used for additive error, use add=1. Can also
  refer to a theta number.

- log:

  Should the error be added on log scale? This is used to obtain an
  exponential error distribution.

- par.type:

  Use "sigma" if variances are estimated with the SIGMA matrix. Use
  "theta" if THETA parameters are used. See \`scale.par\` too.

- trunc0:

  If log=FALSE, truncate simulated values at 0? If trunc0, returned
  predictions can be negative.

- scale.par:

  Denotes if parmeter represents a variance or a standard deviation.
  Allowed values and default value depends on \`par.type\`.

  - if par.type="sigma" only "var" is allowed.

  - if par.type="theta" allowed values are "sd" and "var". Default is
    "sd".

- subset:

  A character string with an expression denoting a subset in which to
  add the residual error. Example: subset="DVID=='A'"

- seed:

  A number to pass to set.seed() before simulating. Default is to
  generate a seed and report it in the console. Use seed=FALSE to avoid
  setting the seed (if you prefer doing it otherwise).

- col.ipred:

  The name of the column containing individual predictions.

- col.ipredvar:

  The name of the column to be created by addResVar to contain the
  simulated observations (individual predictions plus residual error).

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

## Value

An updated data.frame

## Examples

``` r
if (FALSE) { # \dontrun{
## based on SIGMA
simres.var <- addResVar(data=simres,
                        path.ext = "path/to/model.ext",
                        prop = 1,
                        add = 2,
                        par.type = "SIGMA",
                        log = FALSE)

## If implemented using THETAs
simres.var <- addResVar(data=simres,
                        path.ext = "path/to/model.ext",
                        prop = 8, ## point to elements in THETA
                        add = 9,  ## point to elements in THETA
                        par.type = "THETA",
                        log = FALSE)

} # }
```
