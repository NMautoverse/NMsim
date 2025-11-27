# NMsim and speed

The following points show ways to improve calculation speed with
`NMsim`. The list is somewhat prioritized, most important first.

- Reduce amount of data written to file
  - Almost always use the `table.vars` argument. Only include the
    variables you need out of Nonmem. There is no reason to list
    variables in input data since `NMsim` can merge those back on. NMsim
    versions after 0.1.6 have a `carry.out` argument to control which
    input data variables will be recovered. The default is
    `carry.out=TRUE` which means that all input data variables will be
    added back on the results. If your data set is very large, and your
    input data set has many columns, you can reduce this. You could do
    something as little as `table.vars=c(PRED, IPRED)` and
    `carry.out=c("ID", "TIME","TRT")`.
- If running multiple simulations, run them in parallel
  - Use `sge=TRUE` to submit all simulation runs to the cluster
- Break the simulation into multiple Nonmem runs
  - For example, instead of running `subproblems=1000`, you could do
    `subproblems=50, nsims=20, sge=TRUE`. In the first case, one Nonmem
    model is going through 1000 subproblems. In the second case, 20
    Nonmem runs are going through 50 subproblems each, and the Nonmem
    runs are executed in parellel. See example under “Speeding up large
    simulations” too.
- Use `data.table`
  - Depending on the data sets this can make a very large difference.
    Consider using `NMdataConf(as.fun="data.tabe")`
- Use `method.execute="nmsim"`
  - If you provide the path to the Nonmem executable using
    `path.nonmem`,
    [`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
    will be default use `method.execute="nmsim"`. Trick: configure this
    once and for all in the top of your script with something like
    `NMdata::NMdataConf(path.nonmem="/path/to/nmfe75")`.
- Parellilize individual runs
  - NMsim does support parellilization (performing a Nonmem run using
    multiple cores). For instance, use 16 cores for each Nonmem run by
    adding `nc=16`
  - However, this is rarely worth it for simulations. Most of the time,
    input/output (reading/writing to disk) is the bottleneck, and
    splitting the data set into multiple runs will most often reduce run
    times more.
  - Issues have been seen combining `nc` greater than 1 with
    `method.sim=NMsim_EBE` which should be avoided for now.

## Most common reasons for `NMsim` to fail or be slow

If `NMsim` fails or behaves unexpectedly, make sure to read the output
from Nonmem in the R console. If `NMsim` complains it cannot find the
output tables, it is likely because Nonmem failed and did not generate
them.

Any variable that is used in Nonmem must be defined either inside the
model or in the data set. There may be a covariate in the estimated
model that you did not include in your simulation data set - the
simulation will break. Sometimes the estimation models include variables
in output tables that were not used for anything else by Nonmem than
being read from the input data set and printed in output tables. Imagine
you cleverly included a unique row identifier called `ROW` in your
estimation data set and listed it in `$TABLE` to reliably combine input
and output data. It is not used for anything else in the data. If we do
not customize the output table in
[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
using the `table.vars` argument and the simulation input data set does
not include a numeric `ROW` column, we get this error:

    Starting NMTRAN
     
     AN ERROR WAS FOUND IN THE CONTROL STATEMENTS.
     
    AN ERROR WAS FOUND ON LINE 60 AT THE APPROXIMATE POSITION NOTED:
     $TABLE ROW TVKA TVV2 TVV3 TVCL KA V2 V3 CL Q PRED IPRED Y NOPRINT FILE=NMsim_xgxr021_noname.tab
             X  
     THE CHARACTERS IN ERROR ARE: ROW
      479  THIS ITEM IS NOT LISTED IN MODULE NMPRD4 AND MAY NOT BE DISPLAYED.
    cp: cannot stat 'NMsim_xgxr021_noname.tab': No such file or directory
    Error in NMscanTables(file, quiet = TRUE, as.fun = "data.table", col.row = col.row,  : 
      NMscanTables: File not found: /home/philip/R/x86_64-pc-linux-gnu-library/4.2/NMsim/examples/nonmem/NMsim/xgxr021_noname/NMsim_xgxr021_noname.tab. Did you copy the lst file but forgot table file?
    Results could not be read.

Nonmem gets to writing the `$TABLE` but cannot find a variable called
`ROW`. But remember, NMsim normally does not need a row identifier to
combine the input and output data. In many cases, the best way to fix
this is to reduce the `$TABLE` section using the `table.vars` argument.
All we need from the simulation results are population and individual
predictions anyway. We could have omitted `ROW` in the input data set
and done something as simple as

``` r
simres <- NMsim(file.mod=file.mod,
                data=dat.sim,
                table.vars="PRED IPRED Y")
```

`table.vars` can help avoid many of these problems. And if `NMsim` is
slow, this is a large low-hanging fruit. In a benchmark example, I
reduced a (very large) simulation run time from ~1.5 hours to ~7 minutes
this way.

## Speeding up large simulations

[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
offers a powerful way to parallellize mutually independent simulations.
This will typically be distinct subjects which can be simulated without
regard to each other. The simple way to do this is to split the data set
into a list of data sets and pass that list in the
[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
`data` argument.

``` r
library(NMsim)
library(data.table)

dose1 <- NMcreateDoses(TIME=c(0,24),AMT=c(300,150),
                       addl=list(ADDL=c(0,5),II=c(0,24)),CMT=1,col.id=NA,
                       as.fun="data.table")
doses <- dose1[,.(ID=1:1000),by=dose1]
dat.sim <- NMaddSamples(doses,TIME=0:(24*7),CMT=2)


## say dt.sim is a large data set with 1000 subjects. We want 10 data
## sets with 100 subjects in each.
dat.sim$IDGRP <- (dat.sim$ID-1)%/%100+1
## Now IDGRP is the grouping of the ID's
as.data.table(dat.sim)[,.(minID=min(ID),maxID=max(ID)),by=IDGRP]

### with data.table, we easily split the data in a list of data.tables based on that grouping variable
data.multiple <- split(dt.sim,by="IDGRP")

## using sge=TRUE we are now sending the run to the cluster as 10 parellel Nonmem runs.
path.multidata <- NMsim(file.mod,
                          data=data.multiple
                         ,table.vars=c("PRED","IPRED","Y"),
                         ,name.sim="datalist_01"
                         ,sge=TRUE
                          )
### If we want to wait and read the results when they are ready, use wait=TRUE. NMsim will automatically combine them into one data set as if they were from just one Nonmem run.
simres <- NMreadSim(path.multidata,wait=TRUE)
```
