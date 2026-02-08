context("typicalize")

test_that("basic",{

    fileRef <- "testReference/typicalize_01.rds"

    file.mod="testData/nonmem/xgxr011.mod"
    lines.in <- readLines(file.mod,warn=FALSE)
    ## res.all <- NMsim:::typicalize(lines=lines.in,file.mod=file.mod,return.text = TRUE)
    res.all <- NMsim:::typicalize(lines=lines.in)
    res <- NMreadSection(lines=res.all,section="OMEGA")

    expect_equal_to_reference(res,fileRef)
    if(F){
        res
        readRDS(fileRef)
    }


})


test_that("Priors",{
    fileRef <- "testReference/typicalize_02.rds"

    ##file.mod="testData/nonmem/xgxr011.mod"
    file.mod="testData/nonmem/xgxr032_sd1_NWPRI.mod"

    newfile <- "testOutput/typicalize1.mod"

    res0 <- NMsim:::typicalize(file.mod)
    
    secs <- NMreadSection(lines=res0)
    
    res <- secs[c("OMEGA","OMEGAP","OMEGAPD")]
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        res
        ref
    }

    
})



test_that("zero sigma",{

    fileRef <- "testReference/typicalize_03.rds"

    file.mod="testData/nonmem/xgxr011.mod"
    lines.in <- readLines(file.mod,warn=FALSE)
    ## res.all <- NMsim:::typicalize(lines=lines.in,file.mod=file.mod,return.text = TRUE)
    res.all <- NMsim:::typicalize(lines=lines.in,section=c("omega","sigma"))
    res.o <- NMreadSection(lines=res.all,section="OMEGA")
    res.s <- NMreadSection(lines=res.all,section="SIGMA")
    res <- c(res.o,res.s)
    expect_equal_to_reference(res,fileRef)
    if(F){
        res
        readRDS(fileRef)
    }


})
