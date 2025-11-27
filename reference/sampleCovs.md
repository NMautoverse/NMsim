# Sample subject-level covariates from an existing data set

Repeats a data set with just one subject by sampling covariates from
subjects in an existing data set. This can conveniently be used to
generate new subjects with covariate resampling from an studied
population.

## Usage

``` r
sampleCovs(
  data,
  Nsubjs,
  col.id = "ID",
  col.id.covs = "ID",
  data.covs,
  covs,
  seed.R,
  as.fun
)
```

## Arguments

- data:

  A simulation data set with only one subject

- Nsubjs:

  The number of subjects to be sampled. This can be greater than the
  number of subjects in data.covs.

- col.id:

  Name of the subject ID column in \`data\` (default is "ID").

- col.id.covs:

  Name of the subject ID column in \`data.covs\` (default is "ID").

- data.covs:

  The data set containing the subjects to sample covariates from.

- covs:

  The name of the covariates (columns) to sample from \`data.covs\`.

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
#> 1  1    124 115.370 51.224    0    1   1 100   1
#> 2  1    124 115.370 51.224    1    2   2  NA   1
#> 3  1    124 115.370 51.224    4    2   2  NA   1
#> 4  2    125 148.110 41.539    0    1   1 100   1
#> 5  2    125 148.110 41.539    1    2   2  NA   1
#> 6  2    125 148.110 41.539    4    2   2  NA   1
#> 7  3    179  89.308 55.116    0    1   1 100   1
#> 8  3    179  89.308 55.116    1    2   2  NA   1
#> 9  3    179  89.308 55.116    4    2   2  NA   1
```
