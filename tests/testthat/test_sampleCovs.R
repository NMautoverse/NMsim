library(NMdata)

context("sampleCovs")


test_that("basic",{

    fileRef <- "testReference/sampleCovs_01.rds"
    
    data.covs <- NMscanData("testData/nonmem/xgxr134.mod",quiet=TRUE)
    ## data.covs <- NMscanData(system.file("examples/nonmem/xgxr134.mod",package="NMsim"))
    dos.1 <- NMcreateDoses(TIME=0,AMT=100) 
    data.sim.1 <- NMaddSamples(dos.1,TIME=c(1,4),CMT=2)
    res <- sampleCovs(data=data.sim.1,Nsubjs=3,col.id.covs="ID",data.covs=data.covs,covs=c("WEIGHTB","eff0"),seed.R=1)

    expect_equal_to_reference(res,fileRef)
})
