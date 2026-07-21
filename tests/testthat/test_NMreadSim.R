## library(devtools)

#### need a function to drop NMsimVersion and NMsimTime from table
fix.time <- function(x){
    meta.x <- attr(x,"NMsimModTab")
    ## meta.x$time.call <- as.POSIXct("2020-02-01 00:01:01",tz="UTC")
    meta.x$NMsimVersion <- NULL
    meta.x$NMsimTime <- NULL

    meta.x$path.lst.read <- NULL
    
    setattr(x,"NMsimModTab",meta.x)
    invisible(x)
}

library(NMdata)
NMdataConf(reset=TRUE)
library(data.table)
data.table::setDTthreads(1)




context("NMreadSim")

## prepare a sim to read
dt.amt <- data.table(DOSE=c(100,400))
dt.amt[,AMT:=DOSE*1000]
dt.amt
doses.sd <- NMcreateDoses(TIME=0,AMT=dt.amt,as.fun="data.table")
doses.sd[,dose:=paste(DOSE,"mg")]
doses.sd[,regimen:="SD"]
doses.sd
dat.sim.sd <- addEVID2(doses.sd,time.sim=0:24,CMT=2,as.fun="data.table")
dat.sim <- copy(dat.sim.sd)
dat.sim[,ROW:=.I]
dat.sim[,BBW:=75]

if(F){

    ## testOutput/NMsim_xgxr021_sd1_NMreadSim_paths.rds
    file.mod <- "testData/nonmem/xgxr021.mod"

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  dir.res="testData/simres",
                  name.sim = "sd1_NMreadSim",
                  seed.nm=2342
                  ## ,reuse.results=TRUE
                 ,nmquiet=F)

    ## unlink("testOutput/xgxr021_sd1_NMreadSim",recursive=T)
}



## if(F){
test_that("Basic",{
    fileRef <- "testReference/NMreadSim_01.rds"
    ## ref <- readRDS(fileRef)
    res1 <- NMreadSim("testData/simres/xgxr021_sd1_NMreadSim_MetaData.rds")

    fix.time(res1)
    
    expect_equal_to_reference(res1,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(res1,ref)

        head(ref)
        head(res1)

        compareCols(
            attributes(res1)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
           ,keep.names=FALSE)
    }

})
## }

## if(F){
test_that("Reading fst directly",{
    ## NMdataConf(as.fun="data.table")
    
    fileRef <- "testReference/NMreadSim_02.rds"
    ## ref <- readRDS(fileRef)
    res1 <- NMreadSim("testData/simres/xgxr021_sd1_NMreadSim_ResultsData.fst")
    ## library(fst)
    ## res1 <- read_fst("testOutput/xgxr021_sd1_NMreadSim_paths_res.fst",as.data.table=T)

    fix.time(res1)
    
    expect_equal_to_reference(res1,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(res1,ref)

### attributes(res1)$NMsimModTab does not exist - thats why one should read the rds
        ## compareCols(
        ##     attributes(res1)$NMsimModTab
        ##    ,
        ##             attributes(ref)$NMsimModTab
        ##            ,keep.names=FALSE
        ##             )
    }

})

## }

## if(F){
test_that("From different wd",{
    ##    setwd("..")
    fileRef <- "testReference/NMreadSim_03.rds"
    ## ref <- readRDS(fileRef)
    res1 <- NMreadSim("testData/simres/xgxr021_sd1_NMreadSim_MetaData.rds")

    ## setwd("testthat")
    
    fix.time(res1)
    
    ## this should compare to _01 results instead
    expect_equal_to_reference(res1,fileRef)

    
    if(F){
        ref <- readRDS(fileRef)
        compareCols(res1,ref)

        head(res1)
        head(ref)
        
        compareCols(
            attributes(res1)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
           ,keep.names=FALSE)
    }


})
## }


test_that("use carry.out when reading results",{

NMdataConf(
    path.nonmem="/opt/NONMEM/nm75/run/nmfe75",
    dir.sims="testOutput/simtmp"
   ,dir.res="testOutput/simres")

dt.amt <- data.table(DOSE=c(100,400))
dt.amt[,AMT:=DOSE*1000]
doses.sd <- NMcreateDoses(TIME=0,AMT=dt.amt,as.fun="data.table")
doses.sd[,dose:=paste(DOSE,"mg")]
doses.sd[,regimen:="SD"]


## dat.sim.sd <- addEVID2(doses.sd,time.sim=0:24,CMT=2,as.fun="data.table")
dat.sim.sd <- NMaddSamples(doses.sd,TIME=0:24,CMT=2,as.fun="data.table")
dat.sim <- copy(dat.sim.sd)

## NMcheckData(dat.sim)

dat.sim[,ROW:=.I]

##head(dat.sim)

dat.sim[,BBW:=75]
  
file.mod <- "testData/nonmem/xgxr032.mod"
sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1_carryout",
                  seed.nm=2342,
              ## execute=FALSE
              ## ,method.update.inits="nmsim",
              ##wait=FALSE,
              table.vars=cc(PRED,IPRED,Y)
                  )

sim1 <- NMreadSim("testOutput/simres/xgxr032_sd1_carryout_MetaData.rds")


unlink("testOutput/simres/xgxr032_sd1_carryout_ResultsData.fst")

sim2 <- NMreadSim("testOutput/simres/xgxr032_sd1_carryout_MetaData.rds",carry.out=c("ID", "DOSE"))

names(sim1)
names(sim2)
 
  if(F){
    ref <- readRDS(fileRef)
    res
    ref
  }
})



if(F){
####### sim with dir.sims and dir.res being in ../

    file.mod <- "testData/nonmem/xgxr021.mod"

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="../testOutput2/simtmp",
                  dir.res="../testOutput2/simres",
                  name.sim = "NMreadSim_path..",
                  seed.nm=2342
                  ## ,reuse.results=TRUE
                 ,nmquiet=F)


    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="../testOutput2/simtmp",
                  dir.res="testOutput/simres",
                  name.sim = "NMreadSim_path..2",
                  seed.nm=2342
                  ## ,reuse.results=TRUE
                 ,nmquiet=F)

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput/simtmp",
                  dir.res="../testOutput2/simres",
                  name.sim = "NMreadSim_path..3",
                  seed.nm=2342
                  ## ,reuse.results=TRUE
                 ,nmquiet=F)



    ## unlink("testOutput/xgxr021_sd1_NMreadSim",recursive=T)
}
