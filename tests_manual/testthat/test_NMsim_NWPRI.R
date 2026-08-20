## install.packages("NMsim",repos="https://cloud.r-project.org")
library(data.table)
library(NMdata)

packageVersion("NMdata")
## library(NMsim)
library(devtools)
load_all(export_all=FALSE)

NMdataConf(reset=TRUE)
NMdataConf(dir.psn=NULL)
NMdataConf(as.fun="data.table")
NMdataConf(dir.sims="testOutput/simtmp")
NMdataConf(dir.res="testOutput/simres")

dt.dos <- NMcreateDoses(AMT=300,TIME=0)
dt.sim <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2)
dt.sim[,BBW:=40][,ROW:=.I]


## NMdataConf(dir.psn="/opt/psn")
NMdataConf(path.nonmem ="C:/nm75g64/run/nmfe75.bat")
path.nonmem <- "/opt/nonmem/nm751/run/nmfe75"
## dir.psn <- "/opt/psn"
## NMdataConf(dir.psn=dir.psn)
##
path.nonmem <- "/opt/NONMEM/nm75/run/nmfe75"
file.exists(path.nonmem)

#### need a function to drop NMsimVersion and NMsimTime from table
fix.time <- function(x){
    meta.x <- attr(x,"NMsimModTab")
    ## meta.x$time.call <- as.POSIXct("2020-02-01 00:01:01",tz="UTC")
    meta.x$NMsimVersion <- NULL
    meta.x$NMsimTime <- NULL
    
    setattr(x,"NMsimModTab",meta.x)
    invisible(x)
}


#### get rid of ROWMODEL2. Not needed for NMreadSim.


context("NMsim_NWPRI")

test_that("Many thetas",{
    
    fileRef <- "testReference/NMsim_NWPRI_01.rds"

    file.mod <- "testData/nonmem/xgxr233.mod"

    dt.sim[,DOSE2:=50]

    NMreadExt(file.mod)
    NMreadCov(file.mod)

    set.seed(43)
## Fails. Need to insert $SIZES LTH=200 LVR=2000
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    name.sim="NWPRI_01",
                    method.sim=NMsim_NWPRI
                    )

## $SIZES inserted    
    NMexec("testOutput/simtmp/xgxr233_NWPRI_01/xgxr233_NWPRI_01_2.mod",sge=F)

    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref,keep.names=TRUE)
        compareCols(attributes(simres)$NMsimModTab,attributes(readRDS(fileRef))$NMsimModTab,keep.names=FALSE)
        simres.nometa <- copy(simres)
        unNMsimRes(simres.nometa)
        attributes(simres.nometa)
        expect_equal_to_reference(simres.nometa,fnAppend(fileRef,"noMeta"))
    }

})




test_that("Two OMEGA blocks",{
    
    fileRef <- "testReference/NMsim_NWPRI_02.rds"

    file.mod <- "testData/nonmem/xgxr235.mod"

    dt.sim[,DOSE2:=50]
    dt.sim[,WEIGHTB:=60]

    NMreadExt(file.mod)
    NMreadCov(file.mod)

    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    name.sim="NWPRI_02",
                    method.sim=NMsim_NWPRI
                    )


    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref,keep.names=TRUE)
        compareCols(attributes(simres)$NMsimModTab,attributes(readRDS(fileRef))$NMsimModTab,keep.names=FALSE)
        simres.nometa <- copy(simres)
        unNMsimRes(simres.nometa)
        attributes(simres.nometa)
        expect_equal_to_reference(simres.nometa,fnAppend(fileRef,"noMeta"))
    }

})


test_that("MTIME",{
    
    fileRef <- "testReference/NMsim_NWPRI_03.rds"

    file.mod <- "testData/nonmem/xgxr236.mod"

    dt.sim[,DOSE2:=50]
    dt.sim[,WEIGHTB:=60]

    NMreadExt(file.mod)
    NMreadCov(file.mod)

    set.seed(43)
## Fails. Need to insert $SIZES LTH=200 LVR=2000
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    name.sim="NWPRI_03",
                    method.sim=NMsim_NWPRI
                    ,subproblems=2
                    )

    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref,keep.names=TRUE)
        compareCols(attributes(simres)$NMsimModTab,attributes(readRDS(fileRef))$NMsimModTab,keep.names=FALSE)
        simres.nometa <- copy(simres)
        unNMsimRes(simres.nometa)
        attributes(simres.nometa)
        expect_equal_to_reference(simres.nometa,fnAppend(fileRef,"noMeta"))
    }

})


test_that("typical",{

    fileRef <- "testReference/NMsim_NWPRI_04.rds"

    file.mod <- "testData/nonmem/xgxr233.mod"

    dt.sim[,DOSE2:=50]

    NMreadExt(file.mod)
    NMreadCov(file.mod)

    set.seed(43)
## Fails. Need to insert $SIZES LTH=200 LVR=2000
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    name.sim="NWPRI_01",
                    method.sim=NMsim_NWPRI,
                    typical=TRUE
                    )

    as.NMctl(modTab(simres)$path.sim.main)
## $SIZES inserted    
    
    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref,keep.names=TRUE)
        compareCols(attributes(simres)$NMsimModTab,attributes(readRDS(fileRef))$NMsimModTab,keep.names=FALSE)
        simres.nometa <- copy(simres)
        unNMsimRes(simres.nometa)
        attributes(simres.nometa)
        expect_equal_to_reference(simres.nometa,fnAppend(fileRef,"noMeta"))
    }

})
