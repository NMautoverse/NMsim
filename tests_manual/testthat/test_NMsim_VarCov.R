#### need a function to drop NMsimVersion and NMsimTime from table
fix.time <- function(x){
    meta.x <- attr(x,"NMsimModTab")
    ## meta.x$time.call <- as.POSIXct("2020-02-01 00:01:01",tz="UTC")
    meta.x$NMsimVersion <- NULL
    meta.x$NMsimTime <- NULL
    
    setattr(x,"NMsimModTab",meta.x)
    invisible(x)
}

## NMdataConf(as.fun="data.table")
## Need NMdata 0.1.8
## install.packages("NMdata",repos="https://cloud.r-project.org")

## library(devtools)
## load_all("~/wdirs/NMdata")

NMdataConf(dir.sims="testOutput",as.fun="data.table")

context("NMsim_VarCov")
test_that("VarCov simpar",{
    
    fileRef <- "testReference/NMsim_VarCov_01.rds"

    full.dt.sim <- NMcreateDoses(TIME=0, AMT=30,CMT=1) |>
        addEVID2(TAPD=1:24,CMT=2)

    ## file.mod <- "testData/nonmem/xgxr032.mod"
    file.mod <- system.file("examples/nonmem/xgxr021.mod",
                            package="NMsim")

    ## determine parameter space with simpar (see Appendix)
    ## ext.simpar <- sampleParsSimpar(file.mod=file.mod,nsim=10,seed.R = 1)
    ext.simpar <- samplePars(file.mod=file.mod,nsim=10,seed.R = 1,method="simpar")

    ## run NMsim (separate call for each dataset)
    simpar.sim <- 
        NMsim(file.mod=file.mod
             ,data=full.dt.sim
             ,ext=ext.simpar
             ,name.sim="ACOP2024_simpar"
             ,method.sim=NMsim_VarCov
             ,table.vars="PRED IPRED Y KA V2 V3 CL Q"
              ##,sge=TRUE
             ,seed.R=2,
              fast=FALSE
              )

    simpar.res <- NMreadSim(simpar.sim,wait=T)
    fix.time(simpar.res)
    
    expect_equal_to_reference(simpar.res,fileRef)

    simpar.sim.fast <- 
        NMsim(file.mod=file.mod
             ,data=full.dt.sim
             ,ext=ext.simpar
             ,name.sim="ACOP2024_simpar"
             ,method.sim=NMsim_VarCov
             ,table.vars="PRED IPRED Y KA V2 V3 CL Q"
              ##,sge=TRUE
             ,seed.R=2,
              fast=TRUE
              )

    simpar.res.fast <- NMreadSim(simpar.sim.fast,wait=TRUE)
    fix.time(simpar.res.fast)
    
    expect_equal_to_reference(simpar.res.fast,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        ref
        simpar.res
    }
})


