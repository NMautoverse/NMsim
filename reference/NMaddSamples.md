# Add simulation (sample) records to dosing records

Adds simulation events to all subjects in a data set. Copies over
columns that are not varying at subject level (i.e. non-variying
covariates). Can add simulation events relative to previous dosing time.
This function was previously called \`addEVID2()\`.

## Usage

``` r
NMaddSamples(
  data,
  TIME,
  TAPD,
  CMT,
  EVID,
  DV,
  col.id = "ID",
  args.NMexpandDoses,
  unique = TRUE,
  by,
  quiet = FALSE,
  as.fun,
  doses,
  time.sim,
  extras.are.covs
)
```

## Arguments

- data:

  Nonmem-style data set. If using \`TAPD\` an \`EVID\` column must
  contain 1 for dosing records.

- TIME:

  A numerical vector with simulation times. Can also be a data.frame in
  which case it must contain a \`TIME\` column and is merged with
  \`data\`.

- TAPD:

  A numerical vector with simulation times, relative to previous dose.
  When this is used, \`data\` must contain rows with \`EVID=1\` events
  and a \`TIME\` column. \`TAPD\` can also be a data.frame in which case
  it must contain a \`TAPD\` column and is merged with \`data\`.

- CMT:

  The compartment in which to insert the EVID=2 records. Required if
  \`CMT\` is a column in \`data\`. If longer than one, the records will
  be repeated in all the specified compartments. If a data.frame,
  covariates can be specified.

- EVID:

  The value to put in the \`EVID\` column for the created rows. Default
  is 2 but 0 may be prefered even for simulation.

- DV:

  Optionally provide a single value to be assigned to the \`DV\` column.
  The default is to assign nothing which will result in \`NA\` as
  samples are stacked (\`rbind\`) with \`data\`. If you assign a
  different value in \`DV\`, the default value of \`EVID\` changes to
  \`0\`, and \`MDV\` will be \`0\` instead of \`1\`. An example where
  this is useful is when generating datasets for \`\$DESIGN\` where
  \`DV=0\` is often used.

- col.id:

  The name of the column in \`data\` that holds the unique subject
  identifier. Currently, this is needed to be non-\`NULL\`.

- args.NMexpandDoses:

  Only relevant - and likely not needed - if data contains ADDL and II
  columns. If those columns are included, \`NMaddSamples()\` will use
  \`NMdata::NMexpanDoses()\` to evaluate the time of each dose. Other
  than the \`data\` argument, \`NMaddSamples()\` relies on the default
  \`NMexpanDoses()\` argument values. If this is insufficient, you can
  specify other argument values in a list, or you can call
  \`NMdata::NMexpanDoses()\` manually before calling \`NMaddSamples()\`.

- unique:

  If \`TRUE\` (default), events are reduced to unique time points before
  insertion. Sometimes, it's easier to combine sequences of time points
  that overlap (maybe across \`TIME\` and \`TAPD\`), and let
  \`NMaddSamples()\` clean them. If you want to keep your duplicated
  events, use \`unique=FALSE\`.

- by:

  If `TIME` and/or \`TAPD\` are \`data.frame\`s and contain other
  columns than \`TIME\` and/or \`TAPD\`, those will by default follow
  the \`TIME\`/\`TAPD\` records. Think of them as record-level
  variables, like \`VISIT\`. The exception is \`col.id\` - if the
  subject identifier is present, it will be merged by. If additional
  columns should be used to merge by, you can use the \`by\` argument.
  This is useful to generate differentiated sampling schemes for subsets
  of subjects (like regimen="SAD" and regimen="MAD"). If no columns in
  \`TIME\` and/or \`TAPD\` should not be merged by, use \`by=FALSE\`.
  You can also specify selected \`by\` variables like \`by="ID"\` or
  \`by=c("ID","regimen")\` See examples.

- quiet:

  Suppress messages? Default is \`FALSE\`.

- as.fun:

  The default is to return data as a \`data.frame\`. Pass a function
  (say \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use \`as.fun="data.table"\`. The default can
  be configured using \`NMdataConf()\`.

- doses:

  Deprecated. Use \`data\`.

- time.sim:

  Deprecated. Use \`TIME\`.

- extras.are.covs:

  Deprecated. Use \`by\`.

## Value

A data.frame with dosing records only using column names in covs.data
(from data) that are not in TIME.

All rows in TIME get reused for all matches by column names common with
covs.data - the identified subject-level covariates (and col.id). This
is with the exception of the TIME column itself, because in case of
single dose, TIME would be carried over.

## Details

The resulting data set is ordered by ID, TIME, and EVID. You may have to
reorder for your specific needs.

## Examples

``` r
(doses1 <- NMcreateDoses(TIME=c(0,12,24,36),AMT=c(2,1)))
#>   ID TIME EVID CMT AMT MDV
#> 1  1    0    1   1   2   1
#> 2  1   12    1   1   1   1
#> 3  1   24    1   1   1   1
#> 4  1   36    1   1   1   1
NMaddSamples(doses1,TIME=seq(0,28,by=4),CMT=2)
#>    ID TIME EVID CMT AMT MDV
#> 1   1    0    1   1   2   1
#> 2   1    0    2   2  NA   1
#> 3   1    4    2   2  NA   1
#> 4   1    8    2   2  NA   1
#> 5   1   12    1   1   1   1
#> 6   1   12    2   2  NA   1
#> 7   1   16    2   2  NA   1
#> 8   1   20    2   2  NA   1
#> 9   1   24    1   1   1   1
#> 10  1   24    2   2  NA   1
#> 11  1   28    2   2  NA   1
#> 12  1   36    1   1   1   1

## two named compartments
dt.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
seq.time <- c(0,4,12,24)
dt.cmt <- data.frame(CMT=c(2,3),analyte=c("parent","metabolite"))
res <- NMaddSamples(dt.doses,TIME=seq.time,CMT=dt.cmt)

## Separate sampling schemes depending on covariate values
dt.doses <- NMcreateDoses(TIME=data.frame(regimen=c("SD","MD","MD"),TIME=c(0,0,12)),AMT=10,CMT=1)

seq.time.sd <- data.frame(regimen="SD",TIME=seq(0,3))
seq.time.md <- data.frame(regimen="MD",TIME=c(0,12,24))
seq.time <- rbind(seq.time.sd,seq.time.md)
NMaddSamples(dt.doses,TIME=seq.time,CMT=2,by="regimen")
#>    ID TIME EVID CMT AMT MDV regimen
#> 1   1    0    1   1  10   1      SD
#> 2   1    0    2   2  NA   1      SD
#> 3   1    1    2   2  NA   1      SD
#> 4   1    2    2   2  NA   1      SD
#> 5   1    3    2   2  NA   1      SD
#> 6   2    0    1   1  10   1      MD
#> 7   2    0    2   2  NA   1      MD
#> 8   2   12    1   1  10   1      MD
#> 9   2   12    2   2  NA   1      MD
#> 10  2   24    2   2  NA   1      MD

## All subjects get all samples
NMaddSamples(dt.doses,TIME=seq.time,by=FALSE,CMT=2)
#>    ID TIME EVID CMT AMT MDV regimen
#> 1   1    0    1   1  10   1      SD
#> 2   1    0    2   2  NA   1      SD
#> 3   1    0    2   2  NA   1      MD
#> 4   1    1    2   2  NA   1      SD
#> 5   1    2    2   2  NA   1      SD
#> 6   1    3    2   2  NA   1      SD
#> 7   1   12    2   2  NA   1      MD
#> 8   1   24    2   2  NA   1      MD
#> 9   2    0    1   1  10   1      MD
#> 10  2    0    2   2  NA   1      SD
#> 11  2    0    2   2  NA   1      MD
#> 12  2    1    2   2  NA   1      SD
#> 13  2    2    2   2  NA   1      SD
#> 14  2    3    2   2  NA   1      SD
#> 15  2   12    1   1  10   1      MD
#> 16  2   12    2   2  NA   1      MD
#> 17  2   24    2   2  NA   1      MD

## an observed sample scheme and additional simulation times
df.doses <- NMcreateDoses(TIME=0,AMT=50,addl=list(ADDL=2,II=24))
dense <- c(seq(1,3,by=.1),4:6,seq(8,12,by=4),18,24)
trough <- seq(0,3*24,by=24)
sim.extra <- seq(0,(24*3),by=2)
time.all <- c(dense,dense+24*3,trough,sim.extra)
time.all <- sort(unique(time.all))
dt.sample <- data.frame(TIME=time.all)
dt.sample$isobs <- as.numeric(dt.sample$TIME%in%c(dense,trough))
dat.sim <- NMaddSamples(dt.doses,TIME=dt.sample,CMT=2)

## TAPD - time after previous dose
df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
seq.time <- c(0,4,12,24)
NMaddSamples(df.doses,TAPD=seq.time,CMT=2)
#>   ID TIME EVID CMT AMT MDV TAPD
#> 1  1    0    1   1  10   1   NA
#> 2  1    0    2   2  NA   1    0
#> 3  1    4    2   2  NA   1    4
#> 4  1   12    1   1  10   1   NA
#> 5  1   12    2   2  NA   1    0
#> 6  1   16    2   2  NA   1    4
#> 7  1   24    2   2  NA   1   12
#> 8  1   36    2   2  NA   1   24

## TIME and TAPD
df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
seq.time <- c(0,4,12,24)
NMaddSamples(df.doses,TIME=seq.time,TAPD=3,CMT=2)
#>   ID TIME EVID CMT AMT MDV TAPD
#> 1  1    0    1   1  10   1   NA
#> 2  1    0    2   2  NA   1   NA
#> 3  1    3    2   2  NA   1    3
#> 4  1    4    2   2  NA   1   NA
#> 5  1   12    1   1  10   1   NA
#> 6  1   12    2   2  NA   1   NA
#> 7  1   15    2   2  NA   1    3
#> 8  1   24    2   2  NA   1   NA

## Using a custom DV value affects EVID and MDV 
df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
seq.time <- c(4)
NMaddSamples(df.doses,TAPD=seq.time,CMT=2,DV=0)
#>   ID TIME EVID CMT AMT MDV TAPD DV
#> 1  1    0    1   1  10   1   NA NA
#> 2  1    4    0   2  NA   0    4  0
#> 3  1   12    1   1  10   1   NA NA
#> 4  1   16    0   2  NA   0    4  0
```
