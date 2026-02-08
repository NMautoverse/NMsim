setwd("/data/home/philipde/wdirs/NMdata/tests/testthat")

f1 <- "testData/nonmem/xgxr025.mod"

library(diffobj)


file.mod <- "testData/nonmem/xgxr025.mod"
sim1 <- NMsim(file.mod=file.mod,
              data=dat.sim,
              dir.sim="testOutput",
              name.sim = "sd1",
              seed.nm=2342,
              execute=FALSE
              ## ,method.update.inits="nmsim"
              )

f1.modif <- "testOutput/xgxr025_sd1/xgxr025_sd1.mod"

fun.diff.1 <- function(file1,file2){
    l1 <- readLines(file1,warn=F)
    l2 <- readLines(file2,warn=F)
    res.captured <- capture.output()
    diffobj::diffPrint(l1,l2)
    cat(res.captured)
}

res.diff <- fun.diff.1(f1,f1.modif)
res.diff

waldo::compare(readLines(f1),readLines(f1.modif))


diffr::diffr(f1,f1.modif)

?diffr
