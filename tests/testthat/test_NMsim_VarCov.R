context("NMsim_VarCov.R")

library(data.table)
library(NMdata)
NMdataConf(reset=TRUE)
library(stringr)

### dir.sims may be different in these tests than in other test
### scripts. The reason is the control streams are the outputs to be
### compared.
NMdataConf(
    dir.sims="testOutput"
    ## dir.sims="testOutput/simtmp"
    ##   ,dir.res="testOutput/simres"
)


### so far disabled because test relies on NMdata 0.1.7

dt.amt <- data.table(DOSE=c(100,400))
dt.amt[,AMT:=DOSE*1000]
## dt.amt
doses.sd <- NMcreateDoses(TIME=0,AMT=dt.amt,as.fun="data.table")
doses.sd[,dose:=paste(DOSE,"mg")]
doses.sd[,regimen:="SD"]


dat.sim.sd <- addEVID2(doses.sd,time.sim=0:24,CMT=2,as.fun="data.table")
dat.sim <- copy(dat.sim.sd)

## NMcheckData(dat.sim)

dat.sim[,ROW:=.I]

##head(dat.sim)

dat.sim[,BBW:=75]


test_that("Basic",{

    fileRef_a <- "testReference/NMsim_VarCov_01a.rds"
    fileRef_b <- "testReference/NMsim_VarCov_01b.rds"
    fileRef_c <- "testReference/NMsim_VarCov_01c.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"

    
    sim1 <- NMsim(file.mod=file.mod,
                  data=dat.sim,
                  name.sim = "VarCov_1",
                  method.sim=NMsim_VarCov,
                  nsims=2,
                  seed.R=2342,
                  execute=FALSE,
                  method.update.inits="nmsim")

    file.mod.gen <- "testOutput/xgxr032_VarCov_1/xgxr032_VarCov_1_2.mod"
    mod <- NMreadSection(file.mod.gen)
    ## gsub("(\\d)","round()",mod$THETA)
    ## stringr::gsub("\\d+\\.\\d+",function(x)round(as.numeric(x)),mod$THETA)
    ## 
    theta <- stringr::str_replace_all(mod$THETA,"\\d+\\.\\d+",function(x) as.character(round(as.numeric(x),digits=3)))
    inits <- NMreadInits(file.mod.gen)
    ## omega <- stringr::str_replace_all(mod$OMEGA,"\\d+(\\.\\d+)*",function(x)round(as.numeric(x),digits=3))

    ##as.numeric(mod$THETA)

    mod <- mod[!names(mod)%in%c("THETA","OMEGA","SIGMA")]

    if(packageVersion("NMdata")>="0.2.1"){
        expect_equal_to_reference(mod,fileRef_a)
        
        ## expect_equal_to_reference(is.na(suppressWarnings(as.numeric(theta))),fileRef_b)
        expect_equal_to_reference(
            as.data.table(inits)[par.type=="THETA",is.na(init)]
           ,
            fileRef_b)
    }
    ## expect_equal_to_reference(omega,fileRef_c)

    if(F){
        ref_a <- readRDS(fileRef_a)
        ref_a

        ref <- readRDS(fileRef)
        ref$OMEGA
        mod$OMEGA 
        ref$SIGMA
        mod$SIGMA
        ref$SIMULATION
        mod$SIMULATION

        compareCols(ref,mod)

        ref_b <- readRDS(fileRef_b)
        ref_b

        ref_c <- readRDS(fileRef_c)
        ref_c



    }


})
