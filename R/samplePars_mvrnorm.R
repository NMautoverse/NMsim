

##' @keywords internal

samplePars_mvrnorm <- function(file.mod,nsims,format,as.fun){

    . <- NULL
    NMREP <- NULL
    model <- NULL
    parameter <- NULL
    par.type <- NULL
    i <- NULL
    j <- NULL
    value <- NULL
    FIX <- NULL
    iblock <- NULL
    blocksize <- NULL
    model.sim <- NULL
    value.est <- NULL
    
    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

    if(format!="ext") {
        stop("only format=\"ext\" supported for samplePars with method=\"mvrnorm\"")
    }

    covmat <- NMdata::NMreadCov(file.mod)
    ests <- NMreadExt(file.mod,as.fun="data.table")[NMREP==1,.(model,parameter,par.type,i,j,value.est=value,FIX,iblock,blocksize)]
    ests <- ests[par.type%in%c("THETA","SIGMA","OMEGA")]
    ests <- ests[match(colnames(covmat),parameter)]
    newpars <- mvrnorm(n=nsims,Sigma=covmat,mu=ests$value.est)
    newpars <- round(newpars,8)
### as.list first is because without it, this will fail for
### nsims=1. This is because a single-column data.table would be
### created in that case, and then SUBMODEL and further steps
### become wrong and will fail.
    if(nsims==1){
        newpars <- as.data.table(as.list(newpars))
    } else {
        newpars <- as.data.table(newpars)
    }
    
    newpars[,model.sim:=.I]

    newpars <- mergeCheck(
        melt(newpars,id.vars="model.sim",variable.name="parameter")
       ,
        ests
       ,by="parameter",quiet=TRUE)


    ## if the parameter was fixed, reset it to the estimate
    newpars[FIX==1,value:=value.est]
    ## if OMEGA or SIGMA diagonal elements are <0 set to 0.
    ##    if(F){
    newpars.invalid <- newpars[i==j&value<0]
    
    if(nrow(newpars.invalid )){
        sum.invalid <- newpars.invalid[,.("No of truncations"=.N),keyby=.(parameter)]
        message("Variance parameters have been truncated at 0 from their negative sampled values.")
        NMdata:::message_dt(sum.invalid)
        
        warning("Variance parameters have been truncated.")
    }
    ##    }
    newpars[i==j&value<0,value:=0]

    as.fun(newpars)

}

