context("NMcreateMatLines")

## unloadNamespace("NMsim")
## unloadNamespace("NMdata")
## load_all("~/wdirs/NMdata",export_all = FALSE)
## load_all("~/wdirs/NMsim",export_all = FALSE)

NMdataConf(as.fun="data.table")

test_that("basic",{
    fileRef <- "testReference/NMcreateMatLines_01.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"
    ext1 <- NMreadExt(file.mod)[par.type=="OMEGA"] 

    ext1[i==3&j==2,value:=.01]
    ext1[i%in%c(2,3)&j%in%c(2,3),iblock:=2]
    ext1[i%in%c(2,3)&j%in%c(2,3),blocksize:=2]
    ## ext1[iblock==2]

    res <- NMcreateMatLines(ext1,type="OMEGA")

    expect_equal_to_reference(res,fileRef)

    if(F){
        ext1
        res
        readRDS(fileRef)
    }
    
    
})


test_that("Fixed block",{

    fileRef <- "testReference/NMcreateMatLines_02.rds"
    
    file.mod <- "testData/nonmem/xgxr032.mod"
    ext1 <- NMreadExt(file.mod,as.fun="data.table")[par.type=="OMEGA"] 

    ext1[i==3&j==2,value:=.01]
    ext1[i%in%c(2,3)&j%in%c(2,3),iblock:=2]
    ext1[i%in%c(2,3)&j%in%c(2,3),blocksize:=2]
    ## ext1[iblock==2]
    
    ext1[i==2&j==2,FIX:=1]
    res <- NMcreateMatLines(ext1,type="OMEGA")

    expect_equal_to_reference(res,fileRef)
    
})


test_that("Full covariance matrix",{

    fileRef <- "testReference/NMcreateMatLines_03.rds"

    file.mod <- "testData/nonmem/xgxr032.mod"
    cov1 <- NMreadCov(file.mod)
    
    cov.l <- NMdata::mat2dt(cov1,as.fun="data.table")
    cov.l <- NMsim:::addParType(cov.l,suffix="i")
    cov.l <- NMsim:::addParType(cov.l,suffix="j")

    res <- cov.l[par.type.i=="THETA" & par.type.j=="THETA" ] 
    res <- NMsim:::NMcreateMatLines(res,as.one.block=TRUE,fix=TRUE)


    if(packageVersion("NMdata")>="0.2.1"){
        expect_equal_to_reference(res,fileRef)
    }
    
    if(F){
        res
        readRDS(fileRef)
    }

})
