context("NMrunLin")

test_that("basic",{

  fileRef <- "testReference/NMrunLin_01.rds"

  file.mod <- "testData/nonmem/xgxr032.mod"
res <- NMrunLin(fn.mod=file.mod,path.nonmem="/path/to/nonmem",sge=FALSE,meta.tables=NULL,
                 dir.mod.abs="dir/mod/abs",exts.cp="ext",clean=4)

expect_equal_to_reference(res,fileRef)
  
  if(F){
    ref <- readRDS(fileRef)
    res
    ref
  }
})

