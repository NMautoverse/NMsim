## install.packages("NMsim",repos="https://cloud.r-project.org")
library(data.table)
library(NMdata)

packageVersion("NMdata")
library(NMsim)
library(testthat)
if(F){
    library(devtools)
    load_all(export_all=FALSE)
}
NMdataConf(reset=TRUE)
NMdataConf(dir.psn=NULL)
NMdataConf(as.fun="data.table")
NMdataConf(dir.sims="testOutput/simtmp")
NMdataConf(dir.res="testOutput/simres")

dt.dos <- NMcreateDoses(AMT=300,TIME=0)
dt.sim <- NMaddSamples(data=dt.dos,TIME=c(1,6,12),CMT=2)
dt.sim[,BBW:=40][,ROW:=.I]

dt.sim.known <- egdt(dt.sim[,!("ID")],data.table(ID=101:105))
setorder(dt.sim.known,ID,TIME,EVID,CMT)


## NMdataConf(dir.psn="/opt/psn")
## a manual linux setup
## path.nonmem.custom <- "/opt/nonmem/nm751/run/nmfe75"
## path.nonmem.custom <- "c:/nm75g64/run/nmfe75.bat"
dir.psn.custom= "/opt/psn"


identical_cols <- function(x,y){
    cols.x <- colnames(x)
    cols.y <- colnames(y)
    ##if(!identical(sort(cols.x),sort(cols.y))) stop("different")

    dt.diff <- c()
    
    if(identical(sort(cols.x),sort(cols.y))){
        if(!identical(cols.x,cols.y)){
            dt.diff <- c(dt.diff,"column ordering different")
        }
    } else {
        dt.diff <- c(dt.diff,"Different columns present in x and y")
    }

    res.ident <- sapply(cols.x,function(col){
        identical(x[[col]],y[[col]])
    })

    if(!all(res.ident)) {
        dt.diff <- c(dt.diff,"difference in columns")
        message("differences in",paste(cols.x[!res.ident],collapse=", "))
    }

    if(length(dt.diff)){
        compareCols(x,y)
    }
    if(length(dt.diff)==0){
        message("Columns identical!")
    } else {
        message(paste(dt.diff,collapse="\n"))
    }
    return(invisible(dt.diff))
    
}

## 
## path.nonmem <- "/opt/NONMEM/nm75/run/nmfe75"

## if(file.exists(path.nonmem.custom)) {
##     path.nonmem <- path.nonmem.custom
##     NMdataConf(dir.psn=dir.psn.custom)
## }

path.candidates <- c(## metworx
    "/opt/NONMEM/nm75/run/nmfe75"
    ## custom linux
   ,"/opt/nonmem/nm751/run/nmfe75"
    ## a win path
   ,"c:/nm75g64/run/nmfe75.bat"
)


(path.nonmem <- NMsim:::prioritizePaths(path.candidates))

## if psn is not available
## warning("running without psn - some tests will fail.")
## NMdataConf(path.nonmem=path.nonmem)


#### need a function to drop NMsimVersion and NMsimTime from table
fix.time <- function(x,extra=NULL){
    meta.x <- attr(x,"NMsimModTab")
    ## meta.x$time.call <- as.POSIXct("2020-02-01 00:01:01",tz="UTC")
    meta.x$NMsimVersion <- NULL
    meta.x$NMsimTime <- NULL

    if(!is.null(extra)){
        meta.x[,(extra):=NULL]
    }
    
    setattr(x,"NMsimModTab",meta.x)
    invisible(x)
}


#### get rid of ROWMODEL2. Not needed for NMreadSim.


context("NMsim")
test_that("basic - default",{

    fileRef <- "testReference/NMsim_01.rds"
    fileRef.noMeta <- fnAppend(fileRef,"noMeta")

    ## 025 doesn't seem stable. Got Q~1e7 and Nonmem didn't run
    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    ## NMdata:::NMreadExt( fnExtension(file.mod,"ext"))
    ## library(nonmem2R)
    ## extload(file.mod)

    ## load_all(export_all=FALSE)
    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_01"
                    )

    
    ##modTab(simres)
    simres.nometa <- copy(simres)
    unNMsimRes(simres.nometa)

    expect_equal_to_reference(simres.nometa,fileRef.noMeta)
    if(F){
        ref.nometa <- readRDS(fileRef.noMeta)
        simres.nometa
        ref.nometa
    }
    
    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)


    if(F){
        ref <- readRDS(fileRef)
        colnames(ref)
        colnames(simres)
        compareCols(simres,ref,keep.names=TRUE)
        ref
        simres
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(readRDS(fileRef))$NMsimModTab
           ,keep.names=FALSE)

        
    }

})


test_that("basic - sge - dont wait",{

### using the same reference in test 1. Only diff is using sge=TRUE
    fileRef <- "testReference/NMsim_01.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    ## simtab <- "testOutput/NMsim_xgxr021_default_01_paths.rds"
    ## if(doSims){
    simtab <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_01"
                   ,sge=TRUE
                    ## ,quiet=FALSE
                    ## ,path.nonmem=path.nonmem
                    ##,reuse.results=TRUE
                    ## ,file.res=simtab
                    )
    ## }
    simres2 <- NMreadSim(simtab,wait=T)
    ## simres3 <- NMreadSim(simtab,skip.missing = T)


    fix.time(simres2)
    
    expect_equal_to_reference(simres2,fileRef)
    

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres2,ref)
        simres2
        ref
        
        compareCols(
            attributes(simres2)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }

    
})

test_that("basic - sge - wait",{

### using the same reference in test 1. Only diff is using sge=TRUE and wait=TRUE
    fileRef <- "testReference/NMsim_01.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    ## simtab <- "testOutput/NMsim_xgxr021_default_01_paths.rds"
    ## if(doSims){
    simres3 <- NMsim(file.mod,
                     data=dt.sim,
                     table.vars="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_01"
                    ,sge=TRUE
                    ,wait=TRUE
                    ,reuse.results=FALSE
                     ## ,file.res=simtab
                     )

    simres3
    fix.time(simres3)
    
    expect_equal_to_reference(simres3,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres3,ref)
        simres3
        ref

        compareCols(
            attributes(simres3)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }

})


test_that("basic - typical",{

    fileRef <- "testReference/NMsim_02.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    
    set.seed(43)
    
    ## file.mod2 <- c(file.mod,  "testData/nonmem/xgxr032.mod")
    file.mod2 <- c(file.mod)
    simres2 <- NMsim(file.mod2,
                     data=dt.sim,
                     table.vars="PRED IPRED" ,
                     dir.sims="testOutput",
                     typical=TRUE,
                     name.sim="typsubj2"
                     )


    expect_equal(nrow(simres2),4)
    expect_true(simres2[,all(IPRED==PRED)])

    

    if(F){

        fix.time(simres2)
        expect_equal_to_reference(simres2,fileRef)


        ref <- readRDS(fileRef)
        compareCols(simres2,ref)

        compareCols(attributes(simres2)$NMsimModTab,
                    attributes(ref)$NMsimModTab,keep.names=FALSE)
    }

})



test_that("basic - known",{

    fileRef <- "testReference/NMsim_03.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    
    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim.known,
                    table.vars="PRED IPRED" ,
                    ## dir.sims="testOutput",
                    method.sim=NMsim_EBE,
                    name.sim="known_01",
                    method.execute="nmsim",
                    path.nonmem=path.nonmem
                    )

    fix.time(simres)
    expect_equal_to_reference(simres,fileRef)


    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref)
        ref
        simres
        compareCols(attributes(simres)$NMsimModTab,
                    attributes(ref)$NMsimModTab)

        attributes(simres)$NMsimModTab$path.sim
    }

    
})

if(F){ ##### NOT WORKING
    test_that("basic - known - psn not working",{

        fileRef <- "testReference/NMsim_03b.rds"

        file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
        
        set.seed(43)
        simres <- NMsim(file.mod,
                        data=dt.sim.known,
                        table.vars="PRED IPRED" ,
                        ## dir.sims="testOutput",
                        method.sim=NMsim_EBE,
                        name.sim="known_psn_01",
                        method.execute="psn",
                        path.nonmem=path.nonmem
                        )

        fix.time(simres)
        expect_equal_to_reference(simres,fileRef)


        if(F){
            ref <- readRDS(fileRef)
            compareCols(simres,ref)
            ref
            simres
            compareCols(attributes(simres)$NMsimModTab,
                        attributes(ref)$NMsimModTab)
        }

        
    })
}



test_that("basic - spaces in paths",{

    fileRef <- "testReference/NMsim_04.rds"

    file.mod <- "testData/nonmem/folder with space/xgxr021.mod"

    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_01"
                    )

    unNMsimRes(simres)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref)
        ref
        simres
    }

    
    file.mod <- "testData/nonmem/folder with space/xgxr021.mod"

    ## using PSN 
    set.seed(43)
    simres.psn <- NMsim(file.mod,
                        data=dt.sim,
                        table.vars="PRED IPRED",
                        dir.sims="testOutput",
                        name.sim="default_01",
                        method.execute="psn"
                        )

    ## no psn
    set.seed(43)
    simres.nm <- NMsim(file.mod,
                       data=dt.sim,
                       table.vars="PRED IPRED",
                       dir.sims="testOutput",
                       name.sim="default_01",
                       path.nonmem=path.nonmem,
                       method.update.inits="nmsim"
                       )

    fix.time(simres.psn,"path.mod.exec")
    fix.time(simres.nm,"path.mod.exec")

    expect_equal(simres.psn,simres.nm)

    if(F){
        compareCols(simres.psn,simres.nm)
        identical_cols(simres.psn,simres.nm)
        compareCols(attributes(simres.psn)$NMsimModTab,attributes(simres.nm)$NMsimModTab)
    }
})




test_that("SAEM - default",{

    fileRef <- "testReference/NMsim_05.rds"

    file.mod <- "testData/nonmem/xgxr032.mod"

    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_01"
                    )

    fix.time(simres)
    expect_equal_to_reference(simres,fileRef)

    
    if(F){
        ref <- readRDS(fileRef)
        ref
        simres
        identical_cols(ref,simres)
        
        
        attributes(simres)
        attributes(ref)
        
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }
})


test_that("SAEM - known",{

    fileRef <- "testReference/NMsim_06.rds"

    file.mod <- "testData/nonmem/xgxr032.mod"
    ## NMreadPhi(fnExtension(file.mod,"phi"))[,unique(ID)]

    ## source("~/wdirs/NMsim/devel/genPhiFile.R")
    ## res <- NMscanData(file.mod)
    ## genPhiFile(res,file="testOutput/tmp_etas.phi")

    
    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim.known,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="known_01"
                   ,method.sim=NMsim_EBE
                   ,method.execute="nmsim"
                   ,path.nonmem=path.nonmem
                    )

    ## simres.5
    fix.time(simres)
    expect_equal_to_reference(simres,fileRef)
    

    if(F){
        ref <- readRDS(fileRef)
        identical_cols(simres,ref)
        simres
        ref
        ref$IPRED
        simres$IPRED
        
        compareCols(attributes(simres)$NMsimModTab,
                    attributes(ref)$NMsimModTab)
        expect_equal(
            attributes(simres)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }


})



## rbind(simres.3,simres.5) |>
## ggplot(aes(TIME,IPRED,colour=model))+geom_line()+
## facet_wrap(~ID,scales="free")


test_that("VPC",{
    
    file.mod <- "testData/nonmem/xgxr032.mod"
    nsims <- 10
    ## nsims <- 2
    

    simres.vpc <- NMsim(file.mod,
                        table.vars="PRED IPRED Y",
                        dir.sims="testOutput",
                        name.sim="vpc01"
                       ,nsims=nsims
                       ,method.execute="nmsim"
                       ,path.nonmem=path.nonmem
                       ,seed.R=43
                        )

    ## simres.vpc <- NMreadSim("testOutput/simres/xgxr032_vpc01_MetaData.rds")

    simres.vpc[,.N,by=.(model,name.sim,model.sim)]
    expect_equal(length(unique(simres.vpc$model.sim)),nsims)

    expect_equal(nrow(simres.vpc),nsims*731)    

    ## derive PIs
    expect_equal(round(as.numeric(simres.vpc[EVID==0,quantile(Y,probs=.25)]),3),0.155)

    
})


test_that("VPC with complicated INPUT",{

    
    file.mod <- "testData/nonmem/xgxr033.mod"
    ## NMreadSection(file.mod,section="DATA")
    nsims <- 2
    ## NMexec(file.mod,sge=FALSE)
    
    set.seed(43)
    simres.vpc <- NMsim(file.mod,
                        table.vars="PRED IPRED Y",
                        dir.sims="testOutput",
                        name.sim="vpc_01"
                       ,nsims=nsims
                       ,method.execute="nmsim"
                       ,path.nonmem=path.nonmem
                        )

    ## library(ggplot2)
    ## dims(simres.vpc)
    expect_equal(length(unique(simres.vpc$model.sim)),nsims)

    expect_equal(nrow(simres.vpc),nsims*731)


})


test_that("multiple data sets",{

    fileRef <- "testReference/NMsim_07.rds"
    file.mod <- "testData/nonmem/xgxr032.mod"
    data.multiple <- split(dt.sim.known,by="ID")
    data.multiple.orig <- copy(data.multiple)

    set.seed(43)
    simres.multidata <- NMsim(file.mod,
                              data=data.multiple
                             ,table.vars="PRED IPRED Y",
                              dir.sims="testOutput"
                             ,name.sim="datalist_01"
                              ## ,method.execute="nmsim"
                             ,method.execute="psn"
                             ,sge=TRUE
                             ,wait=T
                             ,path.nonmem=path.nonmem
                              )

    expect_equal(data.multiple,data.multiple.orig)
    
    expect_equal(nrow(simres.multidata),nrow(dt.sim.known))


    
})

test_that("space in file name",{

    fileRef <- "testReference/NMsim_08.rds"
    
    fnroot <- "xgxr022"
    lapply(file.path("testData/nonmem",paste0(fnroot,".",cc(mod,lst,ext))),function(file){
        file.copy(file,file.path(dirname(file),paste0("xgxr 022.",fnExtension(file))))
    })
    file.mod <- "testData/nonmem/xgxr 022.mod"


    set.seed(43)
    simres1 <- NMsim(file.mod=c(file.mod),
                     data=dt.sim,
                     table.vars="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="space2"
                    ,path.nonmem=path.nonmem
                     )

    ## with psn
    set.seed(43)
    simres2 <- NMsim(file.mod=c("yo 3"=file.mod),
                     data=dt.sim,
                     table.vars="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="space2"
                     )

    ## name.sim has space
    set.seed(43)
    simres3 <- NMsim(file.mod=c(file.mod),
                     data=dt.sim,
                     table.vars="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="space 2"
                    ,path.nonmem=path.nonmem
                     )

### named file.mod - with space
    set.seed(43)
    simres4 <- NMsim(file.mod=c("yo 4"=file.mod),
                     data=dt.sim,
                     table.vars="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="space2"
                    ,path.nonmem=path.nonmem
                     )
    
    tab.covs <- findCovs(rbind(
        simres1[,N:=1],
        simres2[,N:=2],
        simres3[,N:=3],
        simres4[,N:=4]),by="N"
        )  

    fix.time(tab.covs)
    
    expect_equal_to_reference(tab.covs,fileRef)
    if(F){
        ref <- readRDS(fileRef)
        tab.covs

        expect_equal(modTab(ref),
                     modTab(tab.covs)
                     )
    }
    
    expect_equal(unique(
        nrow(simres1)
       ,
        nrow(simres2)
       ,
        nrow(simres3),
        nrow(simres4)
    ),4)
    

})




test_that("list of data sets - spaces in data names",{

    file.mod <- "testData/nonmem/xgxr032.mod"
    data.multiple <- split(dt.sim.known,by="ID")
    names(data.multiple) <- paste("1",names(data.multiple))

    set.seed(43)
    simres.multidata <- NMsim(file.mod,
                              data=data.multiple
                             ,table.vars="PRED IPRED Y",
                              dir.sims="testOutput"
                             ,name.sim="datalist_02"
                             ,method.execute="nmsim"
                             ,path.nonmem=path.nonmem
                              )

    simres.multidata[,.N,by=.(model,model.sim,name.sim)]
    
    expect_equal(nrow(simres.multidata),nrow(dt.sim.known))


    
})


test_that("multiple data sets on cluster",{
    file.mod <- "testData/nonmem/xgxr032.mod"
    data.multiple <- split(dt.sim.known,by="ID")
    
    set.seed(43)
    simres.multidata <- NMsim(file.mod,
                              data=data.multiple
                             ,table.vars="PRED IPRED Y",
                              dir.sims="testOutput"
                             ,name.sim="datalist_01"
                             ,method.execute="nmsim"
                             ,path.nonmem=path.nonmem
                             ,sge=TRUE
                              )

    list.files("testOutput/xgxr032_datalist_01")
    ## NMreadSim("testOutput/xgxr032_datalist_01/NMsim_paths.rds")
    class(simres.multidata)
    res <- NMreadSim(simres.multidata,wait=T)

    expect_equal(nrow(res),nrow(dt.sim.known))
    

})

test_that("default with renaming",{
    ##NMdataConf(as.fun="data.table")
    fileRef <- "testReference/NMsim_11.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"


    set.seed(43)
    simres <- NMsim(file.mod=c("ref"=file.mod),
                    data=dt.sim,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_01"
                    )

    expect_equal(unique(simres$model.sim),"ref_default_01")
    
    fix.time(simres)
    expect_equal_to_reference(simres,fileRef)
    


    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref)

        identical_cols(simres,ref)

        ref
        simres
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }


})

test_that("multiple data sets with renaming",{
    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    data.multiple <- split(dt.sim.known[ID<=103],by="ID")
    ## data.multiple

    set.seed(43)
    simres.multidata <- NMsim(c(ref=file.mod),
                              data=data.multiple
                             ,table.vars="PRED IPRED Y",
                              dir.sims="testOutput"
                             ,name.sim="datalist_01"
                             ,method.execute="nmsim"
                             ,path.nonmem=path.nonmem
                             ,sge=TRUE
                             ,wait=T
                              )

    expect_equal(unique(simres.multidata[,model.sim]),paste("ref_datalist_01",101:103,sep="_"))
    
    expect_equal(nrow(simres.multidata),nrow(dt.sim.known[ID<=103]))
    
})

test_that("default with nc>1",{


    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    ##     expect_warning(
    
    simtab <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_nc"
                   ,method.execute="nmsim"
                    ## ,method.execute="psn"
                   ,nc=32
                   ,sge=TRUE
                   ,path.nonmem="/opt/NONMEM/nm75/run/nmfe75"
                   ,wait=F
                    )
    
    ## )

##### it seems like for nc>1 we need to wait a little bit once Nonmem is done. This is not doing that and will most likely fail.
    ##Sys.sleep(5)
    ##expect_error(
    simres <- NMreadSim(simtab,wait=T)
    ##    )

    ## if(F){
    expect_equal(
        nrow(
            simres
        ),
        nrow(dt.sim)
    )
    ## }

    ## expect_equal_to_reference(simres,fileRef)

})


test_that("transform",{
    ## options(warn=2)
    NMdataConf(reset=TRUE)
    NMdataConf(dir.res=NULL,allow.unknown=TRUE)
    NMdataConf(dir.sims=NULL,allow.unknown=TRUE)
    NMdataConf(dir.psn=NULL)
    NMdataConf(as.fun="data.table")

    fileRef <- "testReference/NMsim_09.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_trans"
                   ,transform=list(IPRED=sqrt,PRED=function(x)x*1000)
                    )


    ## simres <- NMreadSim("testOutput/NMsim_xgxr021_default_trans_paths.rds")
    
    fix.time(simres)

    ## simres[,funs.transform:=NULL]
    meta.x <- attr(simres,"NMsimModTab")
    meta.x$funs.transform <- "removed"
    setattr(simres,"NMsimModTab",meta.x)

    ##     unlink(fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref)
        identical_cols(simres,ref)
        ref
        simres
        
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }


})

test_that("dir.sims and dir.res with NMdataConf",{

    NMdataConf(dir.sims="testOutput/NMdataConfSim",
               dir.res="testOutput/NMdataConfRes"
               )
    
    fileRef <- "testReference/NMsim_10.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    
    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    name.sim="default_dirconf"
                    )

    fix.time(simres)
    
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(simres,ref)
        identical_cols(simres,ref)

        ref
        simres
        
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(ref)$NMsimModTab
        )
    }

    
    NMdataConf(dir.sims=NULL,
               dir.res=NULL,
               allow.unknown=TRUE)

})


test_that("basic - a model that fails on NMTRAN",{

### This used to return an error. For now, it's returning NULL.
    
    ## fileRef <- "testReference/NMsim_01.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    dt.dos2 <- NMcreateDoses(AMT=300,TIME=0)
    dt.sim2 <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2)

    set.seed(43)

    simres <- NMsim(file.mod,
                    data=dt.sim2,
                    ## table.var="PRED IPRED",
                    ## dir.sims="testOutput",
                    name.sim="nmtranfail"
                   ,sge=F
                   ,seed.R=12
                   ,nmquiet=F
                   ,wait=TRUE,
                    path.nonmem=path.nonmem
                    )
    
    expect_equal(nrow(simres),0)

    expect_equal(
        nrow(NMreadSim(simres))
       ,0
    )

### rerunning the exact same sim with reuse.results to test how a failed sim is handled.
    simres2 <- NMsim(file.mod,
                     data=dt.sim,
                     ## table.var="PRED IPRED",
                     ## dir.sims="testOutput",
                     name.sim="nmtranfail"
                    ,sge=F
                    ,seed.R=12
                    ,nmquiet=F
                    ,wait=TRUE,
                     path.nonmem=path.nonmem
                    ,reuse.results=TRUE
                     )
    
    expect_equal(fix.time(simres),fix.time(simres2))
    
})


test_that("Two models on one rds",{

    file.mod.1 <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    file.mod.2 <- "testData/nonmem/xgxr032.mod"

    dt.dos2 <- NMcreateDoses(AMT=300,TIME=0)
    dt.sim2 <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2)

    set.seed(43)
    simres <- NMsim(c("m1"=file.mod.1,"m2"=file.mod.2),
                    data=dt.sim2,
                    ## table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="twomodels_01"
                   ,file.res="testOutput/twomodels_01_paths.rds"
                   ,table.vars=cc(PRED,IPRED)
                   ,sge=F
                   ,wait=TRUE
                   ,path.nonmem=path.nonmem
                    )

    ## readRDS("testOutput/twomodels_01_paths.rds")
    res <- NMreadSim("testOutput/twomodels_01_paths.rds")

    fix.time(simres)
    fix.time(res)
    
    expect_equal(simres,res)
    
})


test_that("Two named models on one rds",{

    files.mod <- c(model1="../../tests/testthat/testData/nonmem/xgxr021.mod",
                   model2="testData/nonmem/xgxr032.mod")

    dt.dos2 <- NMcreateDoses(AMT=300,TIME=0)
    dt.sim2 <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2)

    set.seed(43)
    simres <- NMsim(file.mod=files.mod,
                    data=dt.sim2,
                    ## table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="twomodels_01"
                   ,file.res="testOutput/twomodels_02_paths.rds"
                   ,table.vars=cc(PRED,IPRED)
                   ,sge=F
                   ,wait=TRUE
                    )

    simres[,.N,by=.(model,model.sim,name.sim)]
    attributes(simres)
    
    ## readRDS("testOutput/twomodels_01_paths.rds")
    res <- NMreadSim("testOutput/twomodels_02_paths.rds")

    fix.time(simres)
    fix.time(res)
    
    expect_equal(simres,res)
    
})


test_that("basic - ctl",{
    
    fileRef <- "testReference/NMsim_01_ctl.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    file.ctl <- fnExtension(file.mod,"ctl")
    file.copy(file.mod,file.ctl)
    
    set.seed(43)
    simres1 <- NMsim(file.ctl,
                     data=dt.sim,
                     table.var="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_ctl_01"
                     )

    NMdataConf(file.mod=function(file)fnExtension(file,"ctl"))

    set.seed(43)
    simres2 <- NMsim(file.ctl,
                     data=dt.sim,
                     table.var="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_ctl_01"
                     )

    simres <- NMreadSim("testOutput/simres/xgxr021_default_ctl_01_MetaData.rds")

    fix.time(simres1)
    fix.time(simres2)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal(simres1,simres2)

    NMdataConf(file.mod=NULL)

})


### todo sim with ETA correlations with both update methods

test_that("correlated etas",{
    
    fileRef <- "testReference/NMsim_12.rds"

    file.mod <- "testData/nonmem/xgxr022.mod"

    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED Y ETAS(1:LAST)",
                    name.sim="covetas_01",
                    path.nonmem=path.nonmem,
                    seed.R=43
                    )

    NMreadExt(file.mod)[par.type=="OMEGA" & i%in%c(2,3)&j%in%c(2,3)]
    omega.sim <- NMreadSection("testOutput/simtmp/xgxr022_covetas_01/xgxr022_covetas_01.mod",section="OMEGA")
    
### a check that nonmem uses te right dist is unnecessary
    ## cor(findCovs(simres,by="ID")[,.(ETA1,ETA2,ETA3,ETA4,ETA5)])
    ## cov2cor(dt2mat(NMreadExt(file.mod)[par.type=="OMEGA"]))

    expect_equal_to_reference(omega.sim,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        ref
        omega.sim
    }
    

})


test_that("Non-numeric DATE and TIME",{

    ## requires NMdata 0.1.7
    fileRef <- "testReference/NMsim_13.rds"
    outfile <- "testOutput/NMsim_13.csv"

    file.mod <- "testData/nonmem/xgxr022.mod"

    dt.dos <- NMcreateDoses(AMT=300,TIME=0)
    dt.sim2 <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2)
    dt.sim2[,BBW:=40][,ROW:=.I]

    dt.sim.known <- egdt(dt.sim[,!("ID")],data.table(ID=101:105))
    setorder(dt.sim.known,ID,TIME,EVID,CMT)

    dt.sim.char <- copy(dt.sim2)

    dt.sim.char[,time.tz:=as.POSIXct("2000/01/01")+TIME*3600]
    ## dt.sim.char[,DATE:=as.character(as.Date(time.tz),format="%y/%m/%d")]
    dt.sim.char[,TIME:=as.character(time.tz,format="%H:%M:%S")]
    
    simres <- NMsim(file.mod,
                    data=dt.sim.char,
                    table.var="TIME PRED IPRED",
                    name.sim="timeAsChar_01",
                    path.nonmem=path.nonmem,
                    seed.R=43
                    ##,quiet=TRUE
                    )


    ## TIME from input data
    simres.inp <- NMsim(file.mod,
                        data=dt.sim.char,
                        table.var="PRED IPRED",
                        name.sim="timeAsChar_02",
                        path.nonmem=path.nonmem,
                        seed.R=43,
                        quiet=TRUE
                        )

    ## TIME from input data because its in carry.out
    simres.inp2 <- NMsim(file.mod,
                         data=dt.sim.char,
                         table.var="PRED IPRED",
                         carry.out="TIME",
                         name.sim="timeAsChar_03",
                         path.nonmem=path.nonmem,
                         seed.R=43,
                         quiet=TRUE
                         )

    
    res <- list(
        timeout=simres[,lapply(.SD,NMisNumeric),.SDcols=cc(TIME)]==TRUE
       ,
        timein=simres.inp[,lapply(.SD,NMisNumeric),.SDcols=cc(TIME)]==FALSE
       ,
        timein2=simres.inp2[,lapply(.SD,NMisNumeric),.SDcols=cc(TIME)]==FALSE
    )

    expect_equal_to_reference(
        res
       ,
        fileRef
    )



### DATE is not allowed in $TABLE. We are not testing this because for some reason we are getting issues when DATE is in input data.
    if(F){
        expect_error(
            simres <- NMsim(file.mod,
                            data=dt.sim.char,
                            table.var="TIME PRED IPRED",
                            name.sim="timeAsChar_01",
                            path.nonmem=path.nonmem,
                            method.update.inits="nmsim",
                            seed.R=43
                            ##,quiet=TRUE
                            )
        )
    }
    
})

test_that("as.fun=data.table in function call",{
    NMdataConf(reset=TRUE)
    NMdataConf(path.nonmem = "/opt/NONMEM/nm75/run/nmfe75")
    
    fileRef <- "testReference/NMsim_01.rds"

    ## 025 doesn't seem stable. Got Q~1e7 and Nonmem didn't run
    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    dt.dos2 <- NMcreateDoses(AMT=300,TIME=0,as.fun="data.table")
    dt.sim2 <- addEVID2(data=dt.dos,TIME=c(1,6,12),CMT=2,as.fun="data.table")
    dt.sim2[,BBW:=40][,ROW:=.I]

    
    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim2,
                    table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="gjerkjng",
                    as.fun="data.table"
                    )

    expect_true(is.data.table(simres))

})



###### using nmsim2 update inits method

test_that("basic - nmsim update inits",{
    NMdataConf(reset=TRUE)
    NMdataConf(path.nonmem = "/opt/NONMEM/nm75/run/nmfe75",
               as.fun="data.table")
    NMdataConf(dir.sims="testOutput/simtmp")
    NMdataConf(dir.res="testOutput/simres")


    fileRef <- "testReference/NMsim_14.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED",
                    dir.sims="testOutput",
                    name.sim="default_14",
                    inits=list(update=TRUE),
                    path.nonmem=path.nonmem
                    )
    
    ## attributes(NMreadSim("testOutput/NMsim_xgxr021_default_01_paths.rds"))
    fix.time(simres)
    ## expect_equal_to_reference(simres[,!("sim")],fileRef)
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        identical_cols(ref,simres)
        ref
        simres
    }
    
})


###### using nmsim2 update inits method and modify parameter

test_that("basic - nmsim update inits",{
    
    fileRef <- "testReference/NMsim_15b.rds"

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"

    set.seed(43)
    simres2 <- NMsim(file.mod,
                     data=dt.sim,
                     table.var="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_15",
                     inits=list(update=TRUE,values=list("THETA(2)"=list(init=4))),
                     path.nonmem=path.nonmem
                     )

    simres3 <- NMsim(file.mod,
                     data=dt.sim,
                     table.var="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_16",
                     inits=list("THETA(2)"=list(init=4)),
                     path.nonmem=path.nonmem
                     )

    simres4 <- NMsim(file.mod,
                     data=dt.sim,
                     table.var="PRED IPRED",
                     dir.sims="testOutput",
                     name.sim="default_17",
                     inits=list("THETA(2)"=list(init=4,fix=1,upper=34)),
                     path.nonmem=path.nonmem
                     )

    res <- rbind(simres2,simres3,simres4)
    fix.time(res)
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        fix.time(ref)
        expect_equal(ref,res)
        res
    }
    
    expect_error(NMsim(file.mod,
                       data=dt.sim,
                       table.var="PRED IPRED",
                       dir.sims="testOutput",
                       name.sim="default_18",
                       inits=list("THETA(2)"=list(init=4,fix=1,uppwr=34)),
                       path.nonmem=path.nonmem
                       ))

    

})


test_that("fast tables",{
    NMdataConf(reset=TRUE)
    NMdataConf(as.fun="data.table")
    NMdataConf(dir.sims="testOutput/simtmp")
    NMdataConf(dir.res="testOutput/simres")
    

    dt.sim.this <- NMcreateDoses(TIME=0,ADDL=100,II=24,AMT=40) |>
        addEVID2(TAPD=seq(1,24,by=6),CMT=2)

    dt.sim.this[,WTBLI:=75]

    file.mod <- "~/wdirs/NMsim/tests/testthat/testData/nonmem/xgxr032.mod"
    ## readLines(file.mod)


    tabopts <- c("NOPRINT","NOPRINT NOAPPEND","NOPRINT NOAPPEND ONEHEADER")
    tabopts <- c("NOPRINT",
                 "NOPRINT NOAPPEND",
                 "NOPRINT NOAPPEND ONEHEADER",
                 "NOPRINT NOAPPEND ONEHEADER NOTITLE",
                 "NOPRINT NOAPPEND ONEHEADERALL NOTITLE"
                 )

    Iopts <- 5
    name.sim <- paste0("tabopts",Iopts)

    res1 <- NMsim(file.mod=file.mod,
                  data=dt.sim.this,
                  name.sim=name.sim,
                  table.vars=cc(PRED,IPRED,Y)
                  ## ,subproblems=2
                  ## ,modify.model=list(error=add("NMREP=IREP"))
                  ## ,table.options=tabopts[Iopts]
                 ,carry.out="TAPD"
                  )
    ## attributes(res1)$NMsimModTab
    
    res2 <- NMsim(file.mod=file.mod,
                  data=dt.sim.this,
                  name.sim="nmrep_subprob",
                  table.vars=cc(PRED,IPRED,Y,NMREP)
                 ,subproblems=2
                  ## modify.model=list(error=add("NMREP=IREP"))
                  ## ,table.options=tabopts[Iopts]
                 ,carry.out=c("TAPD","WTBLI")
                  )

    res1    
    res2    
})


test_that("subproblems and nsims",{
    
    fileRef <- "testReference/NMsim_16.rds"

    file.mod <- "testData/nonmem/xgxr022.mod"

    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars="PRED IPRED Y",
                    name.sim="subprob_nsims",
                    subproblems=5,
                    nsims=2,
                    path.nonmem=path.nonmem
                   ,
                    method.update.inits="nmsim",
                    seed.R=43
                   ,as.fun="data.table")

    simres[,ID:=.GRP,.(ID,NMREP)]
    fix.time(simres)
    
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        identical_cols(simres,ref)
        compareCols(attributes(simres)$NMsimModTab,
                    attributes(ref)$NMsimModTab)
        simres
        ref
        omega.sim
    }
    

})

test_that("commas in data set",{
    
    fileRef <- "testReference/NMsim_17.rds"

    file.mod <- "testData/nonmem/xgxr022.mod"

    dt.sim.tmp <- copy(dt.sim)
    dt.sim.tmp[
       ,comma:="a , comma"]
    
    simres <- NMsim(file.mod,
                    data=dt.sim.tmp,
                    table.vars="PRED IPRED Y",
                    name.sim="commas",
                    path.nonmem=path.nonmem
                   ,
                    seed.R=43
                   ,as.fun="data.table")

    fix.time(simres)
    
    expect_equal_to_reference(simres,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        identical_cols(simres,ref)
        compareCols(attributes(simres)$NMsimModTab,
                    attributes(ref)$NMsimModTab)
        simres
        ref
    }
    

})

test_that("1 subproblem - test NMREP",{
    
    fileRef <- "testReference/NMsim_18.rds"

    file.mod <- "testData/nonmem/xgxr022.mod"

    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.vars=cc(PRED,IPRED),
                    name.sim="subprob1",
                    subproblems=1,
                    path.nonmem=path.nonmem,
                    method.update.inits="nmsim",
                    seed.nm=43
                    )
    expect_true("NMREP"%in%colnames(simres))
    expect_true(simres[,unique(NMREP)]==1)

    ## modTab(simres)
    names(attributes(simres))
    NMreadSection(attributes(simres)$NMsimModTab$path.sim.lst)[c("ERROR","SIMULATION")]
})


## vpc with subproblems and table.vars - NMREP in output
test_that("vpc with subproblems - NMREP in output",{
    
    file.mod <- "testData/nonmem/xgxr022.mod"

    ## with table.vars
    simres <- NMsim(file.mod,
                    ## data=dt.sim,
                    table.vars=cc(PRED,IPRED),
                    name.sim="subprob_vpc1",
                    subproblems=3,
                    path.nonmem=path.nonmem,
                    seed.nm=43
                    )
    simres

    expect_true("NMREP"%in%colnames(simres))
    expect_true(all(simres[,unique(NMREP)]==c(1,2,3)))
    
})

## vpc with subproblems - no table.vars - NMREP in output
test_that("vpc with subproblems - NMREP in output",{
    
    file.mod <- "testData/nonmem/xgxr022.mod"

    ## with table.vars
    simres <- NMsim(file.mod,
                    ## data=dt.sim,
                    ## table.vars=cc(PRED,IPRED),
                    name.sim="subprob_vpc2",
                    subproblems=3,
                    path.nonmem=path.nonmem,
                    seed.nm=43
                    )
    simres

    expect_true("NMREP"%in%colnames(simres))
    expect_true(all(simres[,unique(NMREP)]==c(1,2,3)))
    
})


test_that("PRED model basic",{

    fileRef <- "testReference/NMsim_19.rds"    
    file.mod <- "../../tests/testthat/testData/nonmem/pred030.mod"

    dt.sim.pred <- data.table(X=1:4,ID=1)
    
    ## with table.vars
    simres <- NMsim(file.mod,
                    data=dt.sim.pred,
                    ## table.vars=cc(PRED,IPRED),
                    name.sim="pred1",
                    ## subproblems=3,
                    path.nonmem=path.nonmem,
                    seed.nm=43
                    )

    fix.time(simres)
    
    expect_equal_to_reference(simres,fileRef)

    
})

test_that("PRED model with subproblems",{

    fileRef <- "testReference/NMsim_20.rds"
    file.mod <- "../../tests/testthat/testData/nonmem/pred030.mod"

    dt.sim.pred <- data.table(X=1:4,ID=1)
    
    ## with table.vars
    simres <- NMsim(file.mod,
                    data=dt.sim.pred,
                    ## table.vars=cc(PRED,IPRED),
                    name.sim="pred1_subprob",
                    subproblems=2,
                    path.nonmem=path.nonmem,
                    seed.nm=43
                    )
    fix.time(simres)
    
    ## NMREP present
    simres    
    expect_equal_to_reference(simres,fileRef)

    
})


test_that("PRED model with subproblems table.vars",{

    fileRef <- "testReference/NMsim_21.rds"
    file.mod <- "../../tests/testthat/testData/nonmem/pred030.mod"

    dt.sim.pred <- data.table(X=1:4,ID=1)
    
    ## with table.vars
    simres <- NMsim(file.mod,
                    data=dt.sim.pred,
                    table.vars=cc(PRED),
                    name.sim="pred1_subprob_tabvars",
                    subproblems=2,
                    path.nonmem=path.nonmem,
                    seed.nm=43
                    )

    fix.time(simres)
    expect_equal_to_reference(simres,fileRef)
    
})


test_that("BLOCK(2) 0.1 FIX .1 .1",{
    
    fileRef <- "testReference/NMsim_22.rds"

    file.mod <- "testData/nonmem/xgxr059.mod"
    ##load_all(export_all=FALSE)

    NMreadExt(file.mod,as.fun="data.table")[par.type=="OMEGA"&i%in%c(2,3)&j%in%c(2,3)]
    
    simres <- NMsim(file.mod,
                    data=dt.sim,
                    table.var="PRED IPRED Y ETAS(1:LAST)",
                    name.sim="covetas_02",
                    path.nonmem=path.nonmem,
                    inits=list("omega(2,2)"=list(FIX=1)),
                    ## inits=list(method="none"),
                    seed.R=43
                    )

    NMreadExt(file.mod,as.fun="data.table")[par.type=="OMEGA" & i%in%c(2,3)&j%in%c(2,3)]
    omega.sim <- NMreadSection("testOutput/simtmp/xgxr059_covetas_02/xgxr059_covetas_02.mod",section="OMEGA")
    
### a check that nonmem uses te right dist is unnecessary
    ## cor(findCovs(simres,by="ID")[,.(ETA1,ETA2,ETA3,ETA4,ETA5)])
    ## cov2cor(dt2mat(NMreadExt(file.mod)[par.type=="OMEGA"]))

    expect_equal_to_reference(omega.sim,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        ref
        omega.sim
    }
    

})


test_that("basic - default - nmfe74",{
    

    file.mod <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    
    

    simres.74 <- NMsim(file.mod,
                       data=dt.sim,
                       table.var="PRED IPRED",
                       name.sim="default_01.74",
                       seed.nm=1,
                       path.nonmem="/opt/NONMEM/nm74gf/run/nmfe74",
                                        #path.nonmem="/opt/NONMEM/nm74gf_nmfe/run/nmfe74",
                       as.fun="data.table"
                       )

    simres.75 <- NMsim(file.mod,
                       data=dt.sim,
                       table.var="PRED IPRED",
                       name.sim="default_01.75",
                       seed.nm=1,
                       path.nonmem=path.nonmem,
                       ## path.nonmem="/opt/NONMEM/nm74gf_nmfe/run/nmfe74",
                       as.fun="data.table"
                       )

    expect_equal(unNMsimRes(simres.74)[,!(c("model.sim","name.sim"))],
                 unNMsimRes(simres.75)[,!(c("model.sim","name.sim"))]
                 )
    

### ONEHEADERALL not working with nmfe73
    simres.73a <- NMsim(file.mod,
                        data=dt.sim,
                        table.var="PRED IPRED",
                        name.sim="default_01_73",
                        path.nonmem="/opt/NONMEM/nm73gf/run/nmfe73"
                        ## path.nonmem="/opt/NONMEM/nm74gf_nmfe/run/nmfe74"
                        )
    expect_equal(nrow(simres.73a),0)

    ## this is not using fast tables so precision is different. But works with nonmem 7.3
    simres.73 <- NMsim(file.mod,
                       data=dt.sim,
                       ## table.var="PRED IPRED",
                       seed.nm=1,
                       name.sim="default_01_73b",
                       path.nonmem="/opt/NONMEM/nm73gf/run/nmfe73",
                       wait=TRUE
                       ## path.nonmem="/opt/NONMEM/nm74gf_nmfe/run/nmfe74"
                       )
    

    if(F){
        ref <- readRDS(fileRef)
        colnames(ref)
        colnames(simres)
        compareCols(simres,ref,keep.names=TRUE)
        ref
        simres
        compareCols(
            attributes(simres)$NMsimModTab
           ,
            attributes(readRDS(fileRef))$NMsimModTab
           ,keep.names=FALSE)

        
    }

})

if(FALSE){
### absolute paths, no dir.sims
    library(NMdata)
    library(NMsim)
    library(data.table)

    NMdataConf(reset=TRUE)
    NMdataConf(as.fun="data.table")

    path.candidates <- c(## metworx
        "/opt/NONMEM/nm75/run/nmfe75"
        ## custom linux
       ,"/opt/nonmem/nm751/run/nmfe75"
        ## a win path
       ,"c:/nm75g64/run/nmfe75.bat"
    )

    (path.nonmem <- NMsim:::prioritizePaths(path.candidates))


    ## file.mod <- "/home/philip/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr022.mod"
    file.mod <- "~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr022.mod"
    dt.dos <- NMcreateDoses(AMT=300,TIME=0)
    dt.sim <- NMaddSamples(data=dt.dos,TIME=c(1,6,12),CMT=2)
    dt.sim[,BBW:=40][,ROW:=.I]


    sres <- NMsim(file.mod,data=dt.sim,name.sim="nodirs",
                  path.nonmem=path.nonmem)

    modTab(sres)
}


test_that("model name incl .",{

    fileRef <- "testReference/NMsim_23.rds"

    file.mod.orig <- "../../tests/testthat/testData/nonmem/xgxr021.mod"
    file.mod <- "testData/nonmem/xgxr021.dot.mod"
    ## file.copy(file.mod.orig, file.mod)
    # file.copy(fnExtension(file.mod,"ext"),
    #           fnExtension("testData/nonmem/xgxr021.dot.mod","ext")
    #           )
    
    set.seed(43)
    
    ## file.mod2 <- c(file.mod,  "testData/nonmem/xgxr032.mod")
    
    simres2 <- NMsim(file.mod,
                     data=dt.sim,
                     table.vars="PRED IPRED" ,
                     dir.sims="testOutput",
                     typical=TRUE,
                     inits=list(update=FALSE),
                     name.sim="typ.subj"
                     )
    simres2

    expect_equal(nrow(simres2),4)
    expect_true(simres2[,all(IPRED==PRED)])

    

    if(F){

        fix.time(simres2)
        expect_equal_to_reference(simres2,fileRef)


        ref <- readRDS(fileRef)
        compareCols(simres2,ref)

        compareCols(attributes(simres2)$NMsimModTab,
                    attributes(ref)$NMsimModTab,keep.names=FALSE)
    }

})
