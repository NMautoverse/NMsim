library(devtools)
load_all()
getwd()
setwd("~/wdirs/NMsim")

path.nonmem <- NMsim:::prioritizePaths(
                           "/opt/nonmem/nm751/run/nmfe75",
                           "/opt/NONMEM/nm75/run/nmfe75")
NMdataConf(path.nonmem=path.nonmem)
NMdataConf(dir.psn="/opt/psn")

NMexec("inst/examples/nonmem/xgxr014.mod",sge=FALSE)

NMexec("inst/examples/nonmem/xgxr114.mod",sge=FALSE)
NMexec("inst/examples/nonmem/xgxr021.mod",sge=FALSE)

setwd("~/wdirs/NMsim/inst/examples/nonmem/")
list.files()

## NMexec must test if psn is available before running
NMexec("xgxr021.mod",sge=FALSE)


## NMexec must test if nonmem is available before running
NMexec("xgxr021.mod",sge=FALSE,method.execute="directory")


## this is bad. directory doesn't work. How can we make that
## unavailable when not called by NMsim?
load_all()
NMexec("xgxr021.mod",sge=FALSE,method.execute="directory",path.nonmem="/opt/nonmem/nm751/run/nmfe75")



system("bootstrap -run_on_sge -samples=1000 -threads=250 -dir=bs1_021_N1000 -seed=99521 bs1_014.mod")


##NMsim:::NMupdateInits(newfile="xgxr022.mod",file.mod="xgxr021.mod",fix=FALSE)
system("/opt/psn/update_inits xgxr021.mod --output_model=xgxr022.mod")
NMwritePreamble(file.mod="xgxr022.mod",based.on="xgxr021.mod",desc="Est CL:V2 corr")
NMexec("xgxr022.mod",sge=FALSE)



###### manual testing models
NMexec("~/wdirs/NMsim/tests/testthat/testData/nonmem/xgxr021.mod",sge=FALSE)
NMexec("~/wdirs/NMsim/tests/testthat/testData/nonmem/xgxr025.mod",sge=FALSE)
NMexec("~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr022.mod",sge=FALSE)
NMexec("~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr032.mod",sge=FALSE)
NMexec("~/wdirs/NMsim/tests_manual/testthat/testData/nonmem/xgxr059.mod",sge=FALSE)

    
