# Sample subject-level covariates from an existing data set

Repeats a data set with just one subject by sampling covariates from
subjects (with replacement) in an existing data set. This can
conveniently be used to generate new subjects with covariate resampling
from an studied population.

## Usage

``` r
sampleCovs(
  data,
  Nsubjs,
  col.id = "ID",
  col.id.covs = "ID",
  data.covs,
  covs,
  replace = TRUE,
  col.idcgrp,
  idcgrp.redist = FALSE,
  seed.R,
  as.fun
)
```

## Arguments

- data:

  A simulation data set with only one subject

- Nsubjs:

  The number of subjects to be sampled. This can be greater than the
  number of subjects in data.covs. If \`replace=FALSE\`, default is to
  sample all ID's in \`data.covs\` exactly once.

- col.id:

  Name of the subject ID column in \`data\` (default is "ID").

- col.id.covs:

  Name of the subject ID column in \`data.covs\` (default is "ID").

- data.covs:

  The data set containing the subjects to sample covariates from.

- covs:

  The name of the covariates (columns) to sample from \`data.covs\`.

- replace:

  Sample from subjects in \`data.covs\` with replacement? Default is
  TRUE.

- col.idcgrp:

  The name of the column distinguishing repeated samples of \`IDCOVS\`.
  This is only needed if there are such repetitions (not very common),
  and if there are no repetitions, the default (\`col.idcgrp=NULL\`) is
  to leave out the column. default name of the column when included is
  \`IDCGRP\`. See details too if you need this.

- idcgrp.redist:

  See details.

- seed.R:

  If provided, passed to \`set.seed()\`.

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

## Value

A data.frame. Includes sampled covariates. The subject ID's the
covariates are sampled from will be included in a column called
\`IDCOVS\`.

## Details

Columns will be added in addition to covariates requested in \`covs\`:
IDCOVS, and \`IDCGRP\`. \`IDCOVS\` is the subject id (\`col.id.covs\`)
from the covariate data set, for reference. \`IDCGRP\` is only needed
when covariates are sampled with replacement, and a subsequent Nonmem
simulation is done with \`NMsim_EBE\`. \`NMsim_EBE\` reuses the etas
(from estimation or another \`.phi\` file). Hence for such simulation
you will need to used IDCVOVS as ID in order to match the etas against
the relevant subject ID's. However, since IDCOVS are repeated (due to
sampling with replacement), the easiest is to split the data set so one
subject is never reused within one subset. \`IDCGRP\` holds a variable
to split by so this will work. By default, IDCGRP is simply the counter
of the occurrence of a (\`IDCOVS\`) subject. This is simple but
impractical for splitting into sub simulations because the group sizes
will tend to be quite uneven. \`idcgrp.redist=TRUE\` will reassign
\`IDCGRP\` to balance the group sizes.

## Examples

``` r
library(NMdata)
data.covs <- NMscanData(system.file("examples/nonmem/xgxr134.mod",package="NMsim"))
#> Model: xgxr134
#> Number of rows, columns and distinct ID's
#> N's by source table, shown as used/available:
#>                       file     rows columns   IDs
#>   xgxr134_res.txt (output)  731/731   12/12 90/90
#>  xgxr134_etas.txt (output)  731/731     5/5 90/90
#>      xgxr2covs.rds (input) 731/1502   24/26 90/90
#>                   (result)      731    41+2    90
#> Input and output data merged by: ROW
#> 
#> Distribution of rows on event types
#> Shown for output tables and result:
#>  EVID CMT output result
#>     0   2    641    641
#>     1   1     90     90
#>   All All    731    731
dos.1 <- NMcreateDoses(TIME=0,AMT=100) 
data.sim.1 <- NMaddSamples(dos.1,TIME=c(1,4),CMT=2)
sampleCovs(data=data.sim.1,Nsubjs=3,col.id.covs="ID",data.covs=data.covs,covs=c("WEIGHTB","eff0"))
#>   ID IDCOVS WEIGHTB   eff0 TIME EVID CMT AMT MDV
#> 1  1    135  117.55 55.676    0    1   1 100   1
#> 2  1    135  117.55 55.676    1    2   2  NA   1
#> 3  1    135  117.55 55.676    4    2   2  NA   1
#> 4  2    113  114.26 49.663    0    1   1 100   1
#> 5  2    113  114.26 49.663    1    2   2  NA   1
#> 6  2    113  114.26 49.663    4    2   2  NA   1
#> 7  3    166  101.18 59.792    0    1   1 100   1
#> 8  3    166  101.18 59.792    1    2   2  NA   1
#> 9  3    166  101.18 59.792    4    2   2  NA   1
```
