context("NMreadSim")

#### need a function to drop NMsimVersion and NMsimTime from table
fix.time <- function(x){
  meta.x <- attr(x,"NMsimModTab")
  ## meta.x$time.call <- as.POSIXct("2020-02-01 00:01:01",tz="UTC")
  toNull <- cc(NMsimVersion,NMsimTime,path.lst.read)
  toNull <- intersect(toNull,colnames(meta.x))
if(length(toNull)){
  meta.x[,(toNull) := NULL]
  }
  ## meta.x$NMsimVersion <- NULL
  ## meta.x$NMsimTime <- NULL

  ## meta.x$path.lst.read <- NULL
  
  setattr(x,"NMsimModTab",meta.x)
  invisible(x)
}

library(NMdata)
library(data.table)
data.table::setDTthreads(1)


## library(devtools)

NMdataConf(reset=TRUE)
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
dat.sim.sd <- NMaddSamples(doses.sd,TIME=2,CMT=2,as.fun="data.table")
dat.sim <- copy(dat.sim.sd)
## NMcheckData(dat.sim)
dat.sim[,ROW:=.I]
##head(dat.sim)
dat.sim[,BBW:=75]



if(F){
  ##### don't delete. This creates sims to be read in later tests

  ### case without table.vars
  
  ## testOutput/NMsim_xgxr021_sd1_NMreadSim_paths.rds
  file.mod <- "testData/nonmem/xgxr021.mod"

  dir.sims <- "testData/simtmp"
  dir.res <- "testData/simres"

  sim1 <- NMsim(file.mod=file.mod,
                data=dat.sim,
                ## dir.sims="testOutput",
                dir.sims=dir.sims,
                dir.res=dir.res,
                name.sim = "sd1_NMreadSim",
                seed.nm=2342
                ## ,reuse.results=TRUE
               ,nmquiet=F)


  
  simres <- NMreadSim(file.path(dir.res,"xgxr021_sd1_NMreadSim_MetaData.rds"))

  ## unlink("testOutput/xgxr021_sd1_NMreadSim",recursive=T)
}



test_that("Basic",{
  dir.sims <- "testData/simtmp"
  dir.res <- "testData/simres"

  fileRef <- "testReference/NMreadSim_01.rds"
  ## ref <- readRDS(fileRef)
  ##res1 <- NMreadSim("testData/simres/xgxr021_sd1_NMreadSim_MetaData.rds")
  res1 <- NMreadSim(file.path(dir.res,"xgxr021_sd1_NMreadSim_MetaData.rds"))
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

test_that("carry.out depends on fast.tables",{
  dir.sims <- "testData/simtmp"
  dir.res <- "testData/simres"

  file.rds <- file.path(dir.res,"xgxr021_sd1_NMreadSim_MetaData.rds")
  
## this warning should not come from within data.table

  res1 <- expect_warning(
    NMreadSim(file.rds,
                    read.tmp=TRUE
                   ,
                    carry.out=c("ID","EVID")
              )
  )

  expect_equal( dim(res1),c(4,29))

  if(F){
    ref <- readRDS(fileRef)
    res
    ref
  }
})



test_that("NMsim with carry.out",{
  fileRef <- "testReference/NMreadSim_04.rds"
  ### case dependent on table.vars 
  
  file.mod <- "testData/nonmem/xgxr032.mod"
  dir.sims <- "testData/simtmp"
  dir.res <- "testData/simres"

  if(FALSE){

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims=dir.sims,
                  dir.res=dir.res,
                  name.sim = "sd1_carryout",
                  carry.out=cc(ID,EVID,CMT),
                  seed.nm=2342,
                  execute=FALSE,
                  table.vars=cc(PRED,IPRED,Y)
                  )
  }

  ### need force reread
  ## res1 <- NMreadSim("testOutput/simres/xgxr032_sd1_carryout_MetaData.rds"
  ##                    ,
  ##                     carry.out=c("ID","EVID")
  ##                     )
  file.rds <- file.path(dir.res,"xgxr032_sd1_carryout_MetaData.rds")


  res1 <- NMreadSim(file.rds)

  ## not forcing reread
  res2 <- NMreadSim(file.rds
                   ,
                    carry.out=c("ID","EVID")
                    )


  
  ## delete fst to reapply carry.out
  unlink(file.path(dir.res,"xgxr032_sd1_carryout_ResultsData.fst"))

  res3 <- NMreadSim(file.rds
                   ,
                    carry.out=c("ID","EVID")
                    )

  ## forcing reread
  res4 <- NMreadSim(file.rds,read.tmp=TRUE,carry.out=c("ID","EVID","CMT"))
  
  ## colnames(res1)
  ## colnames(res2)

  res <- compareCols(res1,res2,res3,res4)

  ##res

  ## this should compare to _01 results instead
  expect_equal_to_reference(res,fileRef)

  
  if(F){
    ref <- readRDS(fileRef)
    res
    ref
  }

})

test_that("NMsim with table.vars. use carry.out when reading results",{
  fileRef <- "testReference/NMreadSim_05.rds"
  ### case dependent on table.vars 
  
  file.mod <- "testData/nonmem/xgxr032.mod"
  dir.sims <- "testData/simtmp"
  dir.res <- "testData/simres"

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims=dir.sims,
                  dir.res=dir.res,
                  name.sim = "sd1_tabvars",
                  seed.nm=2342,
                  ## execute=FALSE,
                  ## ,method.update.inits="nmsim",
                  ##wait=FALSE,
                  table.vars=cc(PRED,IPRED,Y)
                  )

  file.rds <- file.path(dir.res,"xgxr032_sd1_tabvars_MetaData.rds")

  ## passing sim object, expecting all column
  res1 <- NMreadSim(sim1)

    compareCols(sim1,res1)

    ## reading from rds. expecting identical to res1
    res2 <- NMreadSim(modTab(sim1)[,    path.rds.read])
    compareCols(res1,res2)
    
  ## not forcing reread. expected result identical to res1
  res3 <- NMreadSim(sim1
                   ,
                    carry.out=c("ID","EVID")
                    )

  
 compareCols(res1,res3)  
  ## delete fst to reapply carry.out
  unlink(file.path(dir.res,"xgxr032_sd1_tabvars_ResultsData.fst"))

  ### expect res3 narrower than res1 
  res4 <- NMreadSim(file.rds
                   ,
                    carry.out=c("ID","EVID")
                    )

  ## forcing reread
    ### expect res5 slightly wider than res4
  res5 <- NMreadSim(file.rds,read.tmp=TRUE,carry.out=c("ID","EVID","CMT"))
  
  res <- compareCols(res1,res2,res3,res4,res5)

  ##res

  ## this should compare to _01 results instead
  expect_equal_to_reference(res,fileRef)

  
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
