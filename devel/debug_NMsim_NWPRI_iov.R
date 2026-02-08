
#NMsim_NWPRI_withIOV 

library(data.table)
library(NMdata)
library(tidyverse)

packageVersion("NMdata")
## library(NMsim)
library(devtools)
setwd("~/wdirs/NMsim")
load_all("~/wdirs/NMsim", export_all=FALSE)
# load_all("~/wdirs/NMdata", export_all=FALSE)

NMdataConf(reset=TRUE)
NMdataConf(dir.psn=NULL)
NMdataConf(as.fun="data.table")



file.mod = "~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr057.mod"
# file.mod = "/data/home/brianrei/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr057.mod"




dt.dos <- NMsim::NMcreateDoses(AMT=300,TIME=0)
dt.sim <- NMsim::addEVID2(data=dt.dos,TIME=c(1,6,12,24,48),CMT=2,as.fun="data.table")
dt.sim[, ':='(
  DOSE = 300, FLAG = 0
)]

dt.sim[, ROW := .I]

data.sim=dt.sim

NMreadExt(file.mod)
NMsim:::NMreadInits(file = file.mod)
NMreadCov(file.mod)

pars = NMreadExt(file.mod, return="pars") #[FIX!=1]
pars[,par_label := paste0(par.type, i,ifelse(!is.na(j),j,""))]
set.seed(2456)
simres <- NMsim(file.mod,
                data=dt.sim,
                table.vars = paste0("PRED IPRED ", paste0(pars$par_label, collapse = " ")),
                modify = list(
                  ERROR = add(
                    # i.e. $ERROR .... THETA1 = THETA(1)
                    paste0(pars$par_label, " = ", pars$par.name)
                  )),
                name.sim="NWPRI_05",
                dir.sims="tests_manual/testthat/testOutput/simtmp",
                dir.res="tests_manual/testthat/testOutput/simres",
                path.nonmem = "~/nonmem760/nm760/run/nmfe76",
                sge=FALSE,
                method.sim=NMsim_NWPRI
                ,subproblems=200
)

tab = simres %>% 
  select(all_of(pars[par.type=="THETA" | i==j | (i!=j & value!=0 & FIX!=1)]$par_label)) %>% 
  distinct() %>% 
  mutate(NMREP = 1:n()) %>% 
  pivot_longer(!NMREP) %>% 
  left_join(pars %>% transmute(name = par_label, est_orig=est)) 
tab %>% 
  ggplot()+
  geom_histogram(aes(x=value))+
  geom_vline(data = function(x) distinct(x, name, est_orig), aes(xintercept = est_orig), color="red")+
  facet_wrap(~name, scales = "free")



# different model:
file.mod = "~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/run411.mod"
# file.edit(file.mod)
dt.sim = data.table(ID=1,FOLDEC50=NMcalc::seqlog(0.01,2000, 3) )
dt.sim <-
  dt.sim[, data.table(COMPN = c(150, 548, 993)), by = dt.sim]
dt.sim[, ':='(
  PSLOWBAS = 34, DVBL = 34,
  # PSLOWBAS = 38,
  FIBID = 0,
  TIME = 1,
  ID = 1,
  AFRLT = 0
)]
dt.sim[FOLDEC50 > 0, AFRLT := 1]
dt.sim[, RECSEQ := .I]
pars = NMreadExt(file.mod, return="pars") #[FIX!=1]
pars[,par_label := paste0(par.type, i,ifelse(!is.na(j),j,""))]
set.seed(2456)
simres <- NMsim(file.mod,
                data=dt.sim,
                table.vars = paste0("PRED IPRED ", paste0(pars$par_label, collapse = " ")),
                modify = list(
                  THETA = add(.pos = "top",
                    # i.e. $ERROR .... THETA1 = THETA(1)
                    paste0(pars$par_label, " = ", pars$par.name)
                  )),
                name.sim="NWPRI_05",
                dir.sims="tests_manual/testthat/testOutput/simtmp",
                dir.res="tests_manual/testthat/testOutput/simres",
                path.nonmem = "~/nonmem760/nm760/run/nmfe76",
                sge=FALSE,
                method.sim=NMsim_NWPRI
                ,subproblems=200
)

tab = simres %>% 
  select(all_of(pars[par.type=="THETA" | i==j | (i!=j & value!=0 & FIX!=1)]$par_label)) %>% 
  distinct() %>% 
  mutate(NMREP = 1:n()) %>% 
  pivot_longer(!NMREP) %>% 
  left_join(pars %>% transmute(name = par_label, est_orig=est)) 
tab %>% 
  ggplot()+
  geom_histogram(aes(x=value))+
  geom_vline(data = function(x) distinct(x, name, est_orig), aes(xintercept = est_orig), color="red")+
  facet_wrap(~name, scales = "free")

# test another standrad model: -----------
file.mod <- "~/wdirs/NMsim/tests/testthat/testData/nonmem/xgxr032.mod"

dt.amt <- data.table(DOSE=c(100,400))
dt.amt[,AMT:=DOSE*1000]
doses.sd <- NMcreateDoses(TIME=0,AMT=dt.amt,as.fun="data.table")
doses.sd[,dose:=paste(DOSE,"mg")]
doses.sd[,regimen:="SD"]
dat.sim.sd <- NMaddSamples(doses.sd,TIME=0:24,CMT=2,as.fun="data.table")
dat.sim <- copy(dat.sim.sd)
dat.sim[,ROW:=.I]
dat.sim[,BBW:=75]
dt.sim=dat.sim

pars = NMreadExt(file.mod, return="pars") #[FIX!=1]
pars[,par_label := paste0(par.type, i,ifelse(!is.na(j),j,""))]
simres = NMsim(file.mod,
      data=dt.sim,
      table.vars = paste0("PRED IPRED ", paste0(pars$par_label, collapse = " ")),
      modify = list(
        THETA = add(.pos = "top",
                    # i.e. $ERROR .... THETA1 = THETA(1)
                    paste0(pars$par_label, " = ", pars$par.name)
        )),      name.sim="NWPRI_04",
      dir.sims="tests_manual/testthat/testOutput/simtmp",
      dir.res="tests_manual/testthat/testOutput/simres",
      path.nonmem = "~/nonmem760/nm760/run/nmfe76",
      sge=FALSE,
      method.sim=NMsim_NWPRI,
      subproblems=200
)
tab = simres %>% 
  select(all_of(pars[par.type=="THETA" | i==j | (i!=j & value!=0 & FIX!=1)]$par_label)) %>% 
  distinct() %>% 
  mutate(NMREP = 1:n()) %>% 
  pivot_longer(!NMREP) %>% 
  left_join(pars %>% transmute(name = par_label, est_orig=est)) 
tab %>% 
  ggplot()+
  geom_histogram(aes(x=value))+
  geom_vline(data = function(x) distinct(x, name, est_orig), aes(xintercept = est_orig), color="red")+
  facet_wrap(~name, scales = "free")

# testing NMsim_NWPRI line-by-line ---------------------------------------------------
# run this before line by line running NMsim_NWPRI:
file.mod = "~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr057.mod"
file.mod = "~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/run411.mod"
NMsim(file.mod,
      data=dt.sim,
      table.var="PRED IPRED ETAS(1:LAST)",
      name.sim="default_04",
      dir.sims="tests_manual/testthat/testOutput/simtmp",
      dir.res="tests_manual/testthat/testOutput/simres",
      path.nonmem = "~/nonmem760/nm760/run/nmfe76",
      sge=FALSE,
      method.sim=NMsim_default,
      subproblems=2
)
file.sim = "~/wdirs/NMsim/tests_manual/testthat/testOutput/simtmp/run411_default_04/run411_default_04.mod"
data.sim = dt.sim

NMreadInits = NMsim:::NMreadInits
NWPRI_df = NMsim:::NWPRI_df
addParType = NMsim:::addParType
NMcreateMatLines = NMsim:::NMcreateMatLines
PLEV = 0.999
NMwriteSectionOne = NMsim:::NMwriteSectionOne


path.nonmem = "/opt/NONMEM/nm75/run/nmfe75"
path.nonmem = "~/nonmem760/nm760/run/nmfe76"

NMexec(files = file.sim, sge=FALSE, path.nonmem = path.nonmem, method.execute = "nmsim", path.nonmem = path.nonmem)