## library(devtools)
## if(F){
library(NMdata)
### NMsim does not put "ROW" first with NMdata 0.1.5. Not sure why.
stopifnot(packageVersion("NMdata")>="0.1.6")
library(data.table)
data.table::setDTthreads(1)


## unloadNamespace("NMsim")
## unloadNamespace("NMdata")
## load_all("~/wdirs/NMdata",export_all = FALSE)
## load_all("~/wdirs/NMsim",export_all = FALSE)


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




context("NMsim")
test_that("Basic",{

###  On windows this gives and error that tmp.dat is not found.
    fileRef <- "testReference/NMsim_01.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1",
                  seed.nm=2342,
                  execute=FALSE
                  ## ,method.update.inits="nmsim"
                  )

    ## ref <- readRDS(fileRef)
    mod <- NMreadSection("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        mod
        ref
        
    }
    
    ## readLines("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    
})



if(FALSE){

    file.mod <- "testData/nonmem/xgxr021.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  suffix.sim = "sd1",
                  seed=2342,
                  ## execute=FALSE,
                  method.update.inits="nmsim"
                  )


}

test_that("modify.model",{

    fileRef <- "testReference/NMsim_02.rds"
    
    file.mod <- "testData/nonmem/xgxr021.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1_modify",
                  seed.nm=2342,
                  modify.model=list(pk=add("CL=CL/2","V2=V2*2"),
                                    error=overwrite("W=1","W=2")),
                  execute=FALSE,
                  method.update.inits="nmsim")

    mod <- NMreadSection("testOutput/xgxr021_sd1_modify/xgxr021_sd1_modify.mod")
    
    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        ref$PK

        ref$ERROR
        mod$ERROR
        
        mod$THETA
        ref$THETA

        mod$OMEGA
        ref$OMEGA

        mod$SIGMA
        ref$SIGMA
        
        mod$INPUT
        ref$INPUT
        
        mod$DATA
        ref$DATA

        mod$TABLE
        ref$TABLE
    }
})

## library(devtools)
## unloadNamespace("NMsim")
## unloadNamespace("NMdata")
## load_all("~/wdirs/NMdata")
## load_all("~/wdirs/NMsim")

test_that("modify.model with list",{

    fileRef <- "testReference/NMsim_02b.rds"
    
    file.mod <- "testData/nonmem/xgxr021.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1_modify2",
                  seed.nm=2342,
                  modify.model=list(problem=list(newlines="$SIZES LTV=200",location="before")),
                  ## modify.model=list(problem=list(newlines="$SIZES LTV=200",location="first")),
                  execute=FALSE,
                  method.update.inits="nmsim")

    mod <- NMreadSection("testOutput/xgxr021_sd1_modify2/xgxr021_sd1_modify2.mod")
    ## readLines("testOutput/xgxr021_sd1_modify2/xgxr021_sd1_modify2.mod")

    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        ref$PK
        ref$ERROR

        mod$THETA
        ref$THETA

        mod$OMEGA
        ref$OMEGA

        mod$SIGMA
        ref$SIGMA

        mod$INPUT
        ref$INPUT
        
        mod$DATA
        ref$DATA

        mod$TABLE
        ref$TABLE
    }
})



test_that("NMsim_EBE",{

    fileRef <- "testReference/NMsim_EBE_03.rds"
    
    file.mod <- "testData/nonmem/xgxr021.mod"
    res <- NMscanInput(file.mod,file.mod=file.mod,apply.filters=T)
    
    dat.sim.ebe <- dat.sim[ID==1]
    dat.sim.ebe[,ID:=unique(res$ID)[1]]

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim.ebe,
                  dir.sims="testOutput",
                  name.sim = "sd1_EBE",
                  method.sim=NMsim_EBE,
                  seed.nm=2342,
                  execute=FALSE,
                  method.update.inits="nmsim")

    mod <- NMreadSection("testOutput/xgxr021_sd1_EBE/xgxr021_sd1_EBE.mod")
    

    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        mod$PK

        ref$OMEGA
        mod$OMEGA 
        ref$SIGMA
        mod$SIGMA
        ref$SIMULATION
        mod$SIMULATION
        
        mod$INPUT
        ref$INPUT
        
        mod$DATA
        ref$DATA

        mod$TABLE
        ref$TABLE
    }


})


test_that("typical",{

    fileRef <- "testReference/NMsim_04.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1",
                  seed.nm=2342,
                  typical=TRUE,
                  execute=FALSE,
                  method.update.inits="nmsim")

    
    res1 <- readLines("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(res1,fileRef)

})

test_that("typical omega and sigma",{

    fileRef <- "testReference/NMsim_04b.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1",
                  seed.nm=2342,
                  typical=cc(omega,sigma),
                  execute=FALSE,
                  method.update.inits="nmsim")

    res1 <- readLines("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    expect_equal_to_reference(res1,fileRef)

    ## ref <- readRDS(fileRef)

})



if(F){
    test_that("NMsim_VarCov",{

        fileRef <- "testReference/NMsim_VarCov_04.rds"
        
        file.mod <- "testData/nonmem/xgxr032.mod"

        sim1 <- NMsim(file.mod=file.mod,
                      data=dat.sim,
                      dir.sims="testOutput",
                      name.sim = "sd1_VarCov",
                      method.sim=NMsim_VarCov,
                      seed.nm=2342,
                      seed.R=2,
                      execute=FALSE,
                      method.update.inits="nmsim")

        mod <- NMreadSection("testOutput/xgxr032_sd1_VarCov/xgxr032_sd1_VarCov_1.mod")
        

        ## ref <- readRDS(fileRef)
        expect_equal_to_reference(mod,fileRef)

    })
}

test_that("sizes",{

    fileRef <- "testReference/NMsim_sizes_05.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sizes_1",
                  ## method.sim=NMsim_VarCov,
                  sizes=list(LTV=30,PD=70),
                  seed.nm=2342,
                  seed.R=2,
                  execute=FALSE,
                  method.update.inits="nmsim")

    mod <- readLines("testOutput/xgxr032_sizes_1/xgxr032_sizes_1.mod")

## sometimes an empty line is included, sometimes not. I don't know why.
    mod <- mod[1:max(which(mod!=""))]

    
    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)
    
    if(F){
        ref <- readRDS(fileRef)
        ref
        mod
    }
})




test_that("inits - modify parameter",{

    fileRef <- "testReference/NMsim_inits_06.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"

    ## options(warn=2)
    
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "inits_1",
                  ## method.sim=NMsim_VarCov,
                  ## inits=list(method="nmsim","THETA(2)"=list(init=4,fix=1)),
                  inits=list("THETA(2)"=list(init=4,fix=1)),
                  seed.nm=2342,
                  seed.R=2,
                  execute=FALSE
                  )

    mod <- readLines("testOutput/xgxr032_inits_1/xgxr032_inits_1.mod")
## sometimes an empty line is included, sometimes not. I don't know why.
    mod <- mod[1:max(which(mod!=""))]


    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        mod
        ref
    }

    
})


test_that("inits - fix multiple parameters",{

    fileRef <- "testReference/NMsim_inits_06b.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "inits_2",
                  inits=list("THETA(1)"=list(fix=1),
                             "THETA(2)"=list(fix=1)),
                  seed.nm=2342,
                  seed.R=2,
                  execute=FALSE
                  )

    mod <- readLines("testOutput/xgxr032_inits_2/xgxr032_inits_2.mod")
## sometimes an empty line is included, sometimes not. I don't know why.
    mod <- mod[1:max(which(mod!=""))]


    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(mod,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        mod
        ref
    }

    
})



test_that("No ONLYSIM",{

###  On windows this gives and error that tmp.dat is not found.
    fileRef <- "testReference/NMsim_07.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "sd1",
                  seed.nm=2342,
                  onlysim=FALSE,
                  execute=FALSE,
                  method.update.inits="nmsim")

    ## ref <- readRDS(fileRef)
    expect_equal_to_reference(sim1,fileRef)

    res1 <- NMreadSection(readRDS(sim1)$path.sim,section="sim")
    res1 <- NMdata:::cleanSpaces(res1)

    expect_equal(res1,"$SIMULATION (2342)")

})


test_that("Named table variables",{

    fileRef <- "testReference/NMsim_08.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "tabvars1",
                  seed.nm=2342,
                  execute=FALSE,
                  method.update.inits="nmsim",
                  table.vars=c("PRED",TIMENEW="TIME")
                  )

    sim2 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "tabvars2",
                  seed.nm=2342,
                  execute=FALSE,
                  method.update.inits="nmsim",
                  table.vars=cc(PRED,TIMENEW=TIME)
                  )


    sim3 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "tabvars3",
                  seed.nm=2342,
                  execute=FALSE,
                  method.update.inits="nmsim",
                  table.vars=c("PRED TIMENEW=TIME")
                  )


    
    res1 <- NMreadSection("testOutput/xgxr025_tabvars1/xgxr025_tabvars1.mod",section="TABLE")
    res2 <- NMreadSection("testOutput/xgxr025_tabvars2/xgxr025_tabvars2.mod",section="TABLE")
    res3 <- NMreadSection("testOutput/xgxr025_tabvars3/xgxr025_tabvars3.mod",section="TABLE")
    res1
    res2
    res3

    expect_true(grepl("TIMENEW",res1))

    expect_equal(sub("tabvars[0-9]","",res1),
                 sub("tabvars[0-9]","",res2)
                 )

    expect_equal(sub("tabvars[0-9]","",res1),
                 sub("tabvars[0-9]","",res3)
                 )

    
    ## readLines("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    
})


test_that("seed, seed.R, seed.nm",{

    fileRef <- "testReference/NMsim_09.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "seed1nm",
                  seed.nm=2,
                  execute=FALSE
                  )

    res.nm <- NMreadSection("testOutput/xgxr025_seed1nm/xgxr025_seed1nm.mod",section="sim")
    res.nm

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "seed1r",
                  seed.R=2,
                  execute=FALSE
                  )

    res.r <- NMreadSection("testOutput/xgxr025_seed1r/xgxr025_seed1r.mod",section="sim")
    res.r

    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "seed1depr",
                  seed=2,
                  execute=FALSE
                  )
    
    res.depr <- NMreadSection("testOutput/xgxr025_seed1depr/xgxr025_seed1depr.mod",section="sim")
    res.depr

    res.all <- list(res.nm,res.nm,res.depr)

    expect_equal_to_reference(res.all,fileRef)


### dont use seed.nm and seed simultaneously
    expect_error(NMsim(file.mod=file.mod,
                       data=dat.sim,
                       dir.sims="testOutput",
                       seed.nm=3,
                       seed=2,
                       execute=FALSE
                       ))

    
})


test_that("Basic - deprecated update inits method",{

###  On windows this gives and error that tmp.dat is not found.
    fileRef <- "testReference/NMsim_10.rds"

    file.mod <- "testData/nonmem/xgxr025.mod"
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  dir.sims="testOutput",
                  name.sim = "inits_depr",
                  seed.nm=2342,
                  execute=FALSE,
                  method.update.inits="nmsim")

    ## ref <- readRDS(fileRef)
    mod <- NMreadSection("testOutput/xgxr025_inits_depr/xgxr025_inits_depr.mod")
    expect_equal_to_reference(sim1,fileRef)

    ## readLines("testOutput/xgxr025_sd1/xgxr025_sd1.mod")
    
})
