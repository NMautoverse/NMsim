context("sampleParsSimpar")

### Needs NMdata 0.1.8 
test_that("basic",{
    file.mod <- "testData/nonmem/xgxr021.mod"

    loadres <- requireNamespace("simpar",quietly=TRUE)
    if(!loadres) {
        ## message("simpar not available. Please install from github or MPN.")
        expect_true(TRUE)
    } else {

        fileRef <- "testReference/sampleParsSimpar_01.rds"

        pars <- expect_warning(sampleParsSimpar(file.mod,nsim=10,format="wide",as.fun="data.table",seed.R=23))

        expect_equal_to_reference(pars,fileRef)

        pars.simpar.w <- samplePars(file.mod=file.mod,nsims=10,method="simpar",format="wide",as.fun="data.table",seed.R=23)
        
        expect_equal(pars,pars.simpar.w)
    }
})

test_that("simpar through samplePars()",{
    file.mod <- "testData/nonmem/xgxr021.mod"

    loadres <- requireNamespace("simpar",quietly=TRUE)
    if(!loadres) {
        ## message("simpar not available. Please install from github or MPN.")
        expect_true(TRUE)
    } else {

        fileRef <- "testReference/samplePars_02.rds"

        file.mod <- "testData/nonmem/xgxr021.mod"

        
        pars.simpar <- samplePars(file.mod=file.mod,nsims=10,method="simpar",format="ext",as.fun="data.table",seed.R=23)

        expect_equal_to_reference(pars.simpar,fileRef)
        if(F){
            pars.simpar
            readRDS(fileRef)
        }
    }
})


