context("summary.NMsimRes")

test_that("Basic",{

  dir.res <- "testData/simres"

  fileRef <- "testReference/summaryNMsimRes_01.rds"


  simres1 <- NMreadSim(file.path(dir.res,"xgxr021_sd1_NMreadSim_MetaData.rds"))
  ## res2 <- NMreadSim(file.path(dir.res,"xgxr021_sd1_NMreadSim_MetaData.rds"),reread.tmp=TRUE)
  
res1 <- summary(simres1)

  
  expect_equal_to_reference(res1,fileRef)

  if(F){
    ref <- readRDS(fileRef)
    compareCols(res1,ref)

    head(ref)
    head(res1)

    compareCols(
      attributes(res1)$NMsimModTab
     ,
      attributes(ref)$NMsimModTab
     ,keep.names=FALSE)
  }

})
