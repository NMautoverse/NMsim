#### testing NMdata::NMreadExt()
unloadNamespace("NMsim")
unloadNamespace("NMdata")
library(devtools)
library(here)
library(scales)
library(tidyverse)
library(stringr)


### lets try to make the directories in the script only depend on wdirs. And maybe one more for setwd if needed
wdirs <- "/data/sandbox/trunk/analysis/NMsim/wdirs"
setwd("/data/sandbox/trunk/analysis/NMsim/wdirs")
# wdirs <- "~/wdirs"
load_all(file.path(wdirs,"NMdata"))
load_all(file.path(wdirs,"NMsim"))


NMdataConf(path.nonmem="/data/sandbox/trunk/analysis/NMsim/nonmem_pre_releases/nm760/run/nmfe76",
           as.fun="data.table")
# NMdataConf(path.nonmem="/opt/NONMEM/nm75/run/nmfe75",
#            as.fun="data.table")


printSection <- function(section) {
    if(!is.list(section)) section <- list(section)
    res <- lapply(section,function(x){
        x <- x[!grepl("^ *$",section)]
        cat(paste(paste(x,collapse="\n"),"\n\n"))

    })
}

##### Choose a model

### The model shown in the NMsim-ParamUncertain vignette
file.project <- function(...)file.path(system.file("examples",package="NMsim"),...)
file.mod <- file.project("nonmem/xgxr032.mod")
## dat.sim <- read_fst(here::here("wdirs/NMsim/vignettes/simulate-results/dat_sim.fst"))
data.sim <- read_fst(file.path(wdirs,"NMsim/vignettes/simulate-results/dat_sim.fst"))


pars <- NMreadExt(file.mod,return="pars",as.fun="data.table")
pars[value!=0]
pars[, parlab := stringr::str_remove_all(string = parameter, pattern = "\\(|\\)") %>% stringr::str_replace(",", "\\_")]
pars1=pars

simres1 <- NMsim(
    file.mod=file.mod,              ## Path to estimation input control stream
    data=data.sim                    ## simulation input data
   ,dir.sims="NMsim/devel/simtmp_NWPRI_nm76" ## where to store temporary simulation files
    ##   ,dir.res="simulate-results"      ## where to store simulation results files
   ,modify.model = list(
        ## name the THETAS/OMEGAS/SIGMAS in $ERROR so we can compare
        ## the distributions to other methods.
        ERROR = add( paste0(pars$parlab, " = ", pars$par.name) )
    )
   ,table.vars = paste0( "PRED IPRED Y ", paste0(pars$parlab, collapse = " ") )   
   ,method.sim=NMsim_NWPRI         ## Var-Cov parameter sampling
   ,name.sim="NWPRI"               ## a recognizable directory name
   ,subproblems=250                 ## sampling multiple models
   ,sge=FALSE                      ## run simulations in parallel please
   ,nmquiet=T
   ,reuse.results=F
)
simres1 = NMreadSim(x = "/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/simtmp_NWPRI_nm76/xgxr032_NWPRI_MetaData.rds")


### lorlatinib model
file.mod <- file.path(wdirs,"NMsim/devel/example_nonmem_models/lorlatinib_sim_est/mod_lorlatinib_estimate.mod")
data.sim <- fread(file.path(wdirs,"NMsim/devel/example_nonmem_models/derived_data/simulated_nonmem_dataset_mod_lorlatinib.csv"))

pars <- NMreadExt(file.mod,return="pars",as.fun="data.table")
pars[value!=0]
pars[, parlab := stringr::str_remove_all(string = parameter, pattern = "\\(|\\)") %>% stringr::str_replace(",", "\\_")]
pars2=pars

simres2 <- NMsim(
    file.mod=file.mod,              ## Path to estimation input control stream
    data=data.sim                    ## simulation input data
    ,dir.sims="NMsim/devel/simtmp_NWPRI_nm76" ## where to store temporary simulation files
    ##   ,dir.res="simulate-results"      ## where to store simulation results files
    ,modify.model = list(
        ## name the THETAS/OMEGAS/SIGMAS in $ERROR so we can compare
        ## the distributions to other methods.
        ERROR = add( paste0(pars$parlab, " = ", pars$par.name) )
    )
    ,table.vars = paste0( "PRED IPRED Y ", paste0(pars$parlab, collapse = " ") )   
    ,method.sim=NMsim_NWPRI         ## Var-Cov parameter sampling
    ,name.sim="NWPRI"               ## a recognizable directory name
    ,subproblems=250                 ## sampling multiple models
    ,sge=FALSE                      ## run simulations in parallel please
    ,nmquiet=T
    ,reuse.results=F
)

simres2 = NMreadSim(x = "/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/simtmp_NWPRI_nm76/mod_lorlatinib_estimate_NWPRI_MetaData.rds")


# sim.lst = "/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/simtmp_NWPRI_nm76/mod_lorlatinib_estimate_NWPRI/mod_lorlatinib_estimate_NWPRI.lst"
# sim.lst = "/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/simtmp_NWPRI_nm76/xgxr032_NWPRI/xgxr032_NWPRI.lst"
# ## $PRIOR and $SIMULATION seem OK
# NMreadSection(sim.lst,section="prior")
# NMreadSection(sim.lst,section=c("simulation")) |> printSection()
# 
# #### Notice dist of OMEGA(2,2). It doesn't match the estimate. The
# #### estimate is 0.17. But mean of sim is ~0. I can't tell from the
# #### sim control stream that something should be wrong.
# ##sim.lst <- "simtmp_NWPRI/xgxr032_NWPRI/xgxr032_NWPRI.lst"
# sim.lst <- attributes( simres)$NMsimModTab$path.sim.lst
# 
# 
# pars[,parlab2:=paste(parlab,"Est =",signif(est,3),"SE =",signif(se,3))]
# pars[FIX==1,parlab2:=paste(parlab,"Est =",signif(est,3), "(Fixed)")]
# ## parameters as read by NMdata::NMreadExt()
# pars[par.type=="OMEGA"&FIX!=1,.(parameter,value)]
# 
# ## $OMEGA and $OMEGAP aligns with pars$value
# NMreadSection(sim.lst,section=c("omega")) |> printSection()
# NMreadSection(sim.lst,section=c("omegap")) |> printSection()
# ## OMEGAPD aligns wit DF2
# NMsim:::NWPRI_df(pars)
# NMreadSection(sim.lst,section=c("omegapd")) |> printSection()
# 
# NMreadSection(sim.lst,section=c("sigmapd")) |> printSection()



simres=simres1
pars=pars1
pars[,parlab2:=paste(parlab,"Est =",signif(est,3),"SE =",signif(se,3))]
pars[FIX==1,parlab2:=paste(parlab,"Est =",signif(est,3), "(Fixed)")]
vars <- intersect(colnames(simres),pars$parlab)

hists1 <- findCovs(simres,by="NMREP")[,c("NMREP",vars),with=F] |>
    melt(measure.vars=vars) |>
    mergeCheck(unique(pars[,.(parlab,est=value,parlab2)]),by.x="variable",by.y="parlab")|>
        ggplot(aes(x = value)) + 
    geom_histogram(bins=25)+
    facet_wrap(~ parlab2, scales = "free") +
    geom_vline(aes(xintercept=est),colour=2)+
    labs(subtitle="Simulated parameter distributions. Red line is param estimate from .ext file in estimated model")+
    theme_bw()
hists1

simres %>% 
    filter(EVID==2|EVID==0,NMREP<15) %>% #, TIME<12,ID==1) %>% 
    ggplot(aes(x=TIME,y=PRED,color=factor(NMREP)))+
    geom_line()


## table with estimates, se and sd. not sure this is needed
simpars.l <- findCovs(simres,by="NMREP") |>
    melt(measure.vars=pars$parlab)
sumpars <- simpars.l[,.(mean=mean(value),sd=sd(value),median=median(value)),by=.(parlab=variable)]
dt.pars <- mergeCheck(sumpars,pars[,.(parlab,val.ext=value,se.ext=se,FIX)],by="parlab")[
   ,diff.median:=percent(abs((median-val.ext)/val.ext))][
   ,diff.mean:=percent(abs((mean-val.ext)/val.ext))]
dt.pars[FIX!=1,!("FIX")]


## manual edits of the sim control stream
NMexec("NMsim/devel/simtmp_NWPRI_nm76/mod_lorlatinib_estimate_NWPRI/mod_lorlatinib_estimate_NWPRI_2.mod",sge=F)
NMexec("NMsim/devel/simtmp_NWPRI_nm76/xgxr032_NWPRI/xgxr032_NWPRI_2.mod",sge=F)
NMexec("NMsim/devel/simtmp_NWPRI_nm76/mod_dacomitinib_transit_iiv_testing_NWPRI.mod",sge=F)

simres <- NMscanData("NMsim/devel/simtmp_NWPRI_nm76/mod_lorlatinib_estimate_NWPRI/mod_lorlatinib_estimate_NWPRI_2.lst")
simres <- NMscanData("NMsim/devel/simtmp_NWPRI_nm76/xgxr032_NWPRI/xgxr032_NWPRI_2.lst")




# dacomitinib version:
file.mod = "NMsim/devel/simtmp_NWPRI_nm76/mod_dacomitinib_transit_iiv_testing_NWPRI.mod"
readRDS("/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/simtmp_NWPRI_nm76/mod_dacomitinib_transit_iiv_testing_NWPRI_input.rds") %>% 
    filter(TIME<24, ID==1) %>% 
    fwrite("/data/sandbox/trunk/analysis/NMsim/wdirs/NMsim/devel/example_nonmem_models/dacomitinib_sim_data.csv")
NMexec(file.mod,sge=F)
simres = NMscanData(file.mod)
simres %>% dplyr::select(THETA1:NMREP) %>% distinct() %>% 
    pivot_longer(!NMREP) %>% 
    ggplot(aes(x=value))+
    geom_histogram()+
    facet_wrap(~name, scales = "free")+
    theme_bw()
pars <- NMreadParsText(fnExtension(file.mod, ".lst"),format = ";init", spaces.split = TRUE)
pars[value!=0]
pars[, parlab := stringr::str_remove_all(string = parameter, pattern = "\\(|\\)") %>% stringr::str_replace(",", "\\_")]
pars[,parlab2:=paste(parlab,"Est =",signif(est,3),"SE =",signif(se,3))]
pars[FIX==1,parlab2:=paste(parlab,"Est =",signif(init,3), "(Fixed)")]
vars <- intersect(colnames(simres),pars$parlab)


# 2822 acute:
# acute
#TODO: add these lines to NMsim_NWPRI.R to start debugging that method:
# file.mod = "/data/prod_vx548_phase3_analysis/trunk/analysis/NDA/models/PK/2822/2822.mod"
# data.sim = NMdata::NMscanInput(file.mod,translate = T,recover.cols = FALSE) %>% filter(USUBJIDN==10001) %>% dplyr::select(USUBJIDN:WTBLI)
# file.sim="NMsim/devel/simtmp_NWPRI_nm76/2822_NWPRI/2822_NWPRI.mod"
# PLEV=0.999

file.mod = "/data/prod_vx548_phase3_analysis/trunk/analysis/NDA/models/PK/2822/2822.mod"
data.sim = NMdata::NMscanInput(file.mod,translate = T,recover.cols = FALSE) %>% filter(USUBJIDN==10001) %>% dplyr::select(USUBJIDN:WTBLI)
pars <- NMreadExt(file.mod,return="pars",as.fun="data.table")
#pars[value!=0]
pars[, parlab := stringr::str_remove_all(string = parameter, pattern = "\\(|\\)") %>% stringr::str_replace(",", "\\_")]

# # first generate the empty sim control stream:
# NMsim::NMsim(
#     file.mod=file.mod,              ## Path to estimation input control stream
#     data=data.sim                    ## simulation input data
#     ,dir.sims="NMsim/devel/simtmp_NWPRI_nm76" ## where to store temporary simulation files
#     ,modify.model = list(
#         ## name the THETAS/OMEGAS/SIGMAS in $ERROR so we can compare
#         ## the distributions to other methods.
#         ERROR = add( paste0(pars$parlab, " = ", pars$par.name) )
#     )
#     ,table.vars = paste0( "PRED IPRED Y ", paste0(pars$parlab, collapse = " ") )   
#     ,method.sim=stop         ## Var-Cov parameter sampling
#     ,name.sim="NWPRI"               ## a recognizable directory name
#     ,subproblems=250                 ## sampling multiple models
#     ,sge=FALSE                      ## run simulations in parallel please
#     ,nmquiet=F
#     ,reuse.results=F
# )
# 
# NMsim::NMsim_NWPRI(file.sim="NMsim/devel/simtmp_NWPRI_nm76/2822_NWPRI/2822_NWPRI.mod", file.mod = file.mod, data.sim = data.sim)

NMsim::NMsim(
    file.mod=file.mod,              ## Path to estimation input control stream
    data=data.sim                    ## simulation input data
    ,dir.sims="NMsim/devel/simtmp_NWPRI_nm76" ## where to store temporary simulation files
    ##   ,dir.res="simulate-results"      ## where to store simulation results files
    ,modify.model = list(
        ## name the THETAS/OMEGAS/SIGMAS in $ERROR so we can compare
        ## the distributions to other methods.
        ERROR = add( paste0(pars$parlab, " = ", pars$par.name) )
    )
    ,table.vars = paste0( "PRED IPRED Y ", paste0(pars$parlab, collapse = " ") )   
    ,method.sim=NMsim_NWPRI         ## Var-Cov parameter sampling
    ,name.sim="NWPRI"               ## a recognizable directory name
    ,subproblems=10                 ## sampling multiple models
    ,sge=FALSE                      ## run simulations in parallel please
    ,nmquiet=F
    ,reuse.results=F,wait = F
)
# need to add $SIZES LTH=500 LVR=500 to the control stream.
NMexec(files = "NMsim/devel/simtmp_NWPRI_nm76/2822_NWPRI/2822_NWPRI.mod", sge=F)

file.mod = "NMsim/devel/simtmp_NWPRI_nm76/2822_NWPRI/2822_NWPRI.mod"
simres = NMscanData(file.mod)
simres %>% dplyr::select(THETA1:NMREP) %>% distinct() %>% 
    pivot_longer(!NMREP) %>% 
    ggplot(aes(x=value))+
    geom_histogram()+
    facet_wrap(~name, scales = "free")+
    theme_bw()


# Try model 304:
file.mod = "/data/prod_vx548_dpn_phase2_analysis/trunk/analysis/popPK_preDBL/models_finaldata/br_models/304/304.mod"
data.sim = NMdata::NMscanInput(file.mod,translate = T,recover.cols = FALSE) %>% filter(ID==10001)
pars <- NMreadExt(file.mod,return="pars",as.fun="data.table")
#pars[value!=0]
pars[, parlab := stringr::str_remove_all(string = parameter, pattern = "\\(|\\)") %>% stringr::str_replace(",", "\\_")]

NMsim::NMsim(
    file.mod=file.mod,              ## Path to estimation input control stream
    data=data.sim                    ## simulation input data
    ,dir.sims="NMsim/devel/simtmp_NWPRI_nm76" ## where to store temporary simulation files
    ##   ,dir.res="simulate-results"      ## where to store simulation results files
    ,modify.model = list(
        ## name the THETAS/OMEGAS/SIGMAS in $ERROR so we can compare
        ## the distributions to other methods.
        ERROR = add( paste0(pars$parlab, " = ", pars$par.name) )
    )
    ,table.vars = paste0( "PRED IPRED Y ", paste0(pars$parlab, collapse = " ") )   
    ,method.sim=NMsim_NWPRI         ## Var-Cov parameter sampling
    ,name.sim="NWPRI"               ## a recognizable directory name
    ,subproblems=10                 ## sampling multiple models
    ,sge=FALSE                      ## run simulations in parallel please
    ,nmquiet=F
    ,reuse.results=F,wait = F
)
# need to add $SIZES LTH=500 LVR=500 to the control stream.
NMexec(files = "NMsim/devel/simtmp_NWPRI_nm76/304_NWPRI/304_NWPRI.mod", sge=F)

file.mod = "NMsim/devel/simtmp_NWPRI_nm76/2822_NWPRI/2822_NWPRI.mod"
simres = NMscanData(file.mod)
simres %>% dplyr::select(THETA1:NMREP) %>% distinct() %>% 
    pivot_longer(!NMREP) %>% 
    ggplot(aes(x=value))+
    geom_histogram()+
    facet_wrap(~name, scales = "free")+
    theme_bw()
