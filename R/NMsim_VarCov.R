##' Simulate with parameter values sampled from a covariance step
##'
##' @description Like \code{NMsim_default} but `$THETA`, `$OMEGA`, and `SIGMA` are
##' drawn from distribution estimated in covariance step. A successful
##' covariance step must be available from the estimation. In case the
##' simulation leads to negative diagonal elements in $OMEGA and
##' $SIGMA, those values are truncated at zero. For simulation with
##' parameter variability based on bootstrap results, use
##' \code{NMsim_default}.
##'
##' This function does not run any simulations. To simulate, using
##' this method, see `NMsim()`.
##'
##' @param file.sim The path to the control stream to be edited. This
##'     function overwrites the contents of the file pointed to by
##'     file.sim.
##' @param file.mod Path to the path to the original input control
##'     stream provided as `file.mod` to `NMsim()`.
##' @param data.sim Included for compatibility with `NMsim()`. Not
##'     used.
##' @param nsims Number of replications wanted. The default is 1. If
##'     greater, multiple control streams will be generated.
##' @param ext Parameter values in long format as created by
##'     `readParsWide` and `NMdata::NMreadExt`.
##' @param method.sample When `ext` is not used, parameters are
##'     sampled, using `samplePars()`. `method` must be either
##'     `mvrnorm` or `simpar`. Only used when `ext` is not provided.
##' @param write.ext If supplied, a path to an rds file where the
##'     parameter values used for simulation will be saved.
##' @param ... Additional arguments passed to `NMsim_default()`.
##' @import NMdata
##' @import data.table
##' @importFrom MASS mvrnorm
##' @return Character vector of simulation control stream paths
##' @export

NMsim_VarCov <- function(file.sim,file.mod,data.sim,nsims,method.sample="mvrnorm",ext,write.ext=NULL,
                         ...){

#### Section start: Dummy variables, only not to get NOTE's in package checks ####

    . <- NULL
    blocksize <- NULL
    est <- NULL
    i <- NULL
    iblock <- NULL
    j <- NULL
    FIX <- NULL
    GRP <- NULL
    fn.sim <- NULL
    NMREP <- NULL
    parameter <- NULL
    par.type <- NULL
    path.sim <- NULL
    ROW <- NULL
    run.sim <- NULL
    submodel <- NULL
    model.sim <- NULL
    value <- NULL

### Section end: Dummy variables, only not to get NOTE's in package checks 
    

    files.needed.def <- NMsim_default(file.sim=file.sim,file.mod,data.sim,...)
    
    path.lst <- fnExtension(file.mod,"lst")
    path.cov <- fnExtension(path.lst,"cov")
    path.ext <- fnExtension(path.lst,"ext")

    ## define new files
    path.sim.0 <- file.sim
    run.sim.0 <- fnExtension(basename(path.sim.0),"")
    rm(file.sim)

    if(missing(ext)) ext <- NULL
    if(missing(nsims)) nsims <- NULL
    
    if(is.null(ext)){
        if(is.null(nsims)) nsims <- 1
        simulatePars <- TRUE
    } else {
        if(!is.null(nsims)) stop("nsims not supported in combination with ext")
        if(!is.data.table(ext)){
            ext <- as.data.table(ext)
        }
        ## nsims <- ext[,.N]
        simulatePars <- FALSE
    }

#### Section start: sampling new parameters from COV matrix ####
    if(simulatePars){
        newpars <- samplePars(file.mod=file.mod,nsims=nsims,
                              method=method.sample,format="ext",
                              as.fun="data.table")
        
###  Section end: sampling new parameters from COV matrix
    }
#### Section start: Parameter from provided table ####

    if(!simulatePars){
        
        newpars <- copy(ext)
        setDT(newpars)
        
        
        ## newpars[,model.sim:=.GRP,by=.(model)]
        ##setnames(newpars,"model","model.sim")
    }

### Section end: Parameter from provided table

    
    newpars[,ROW:=.I]
    ## length.num.char <- newpars[,ceiling(log10(uniqueN(model.sim)-1))+1]
    ndigs <- function(x) {
        x <- abs(x)
        y <- x
        y[x<=1] <- 1
        y[x>1] <- ceiling(log10(x[x>1]+1))
        y
    }

    bycols <- intersect(c("model","model.sim"),colnames(newpars))
    length.num.char <-
        newpars[,.GRP,by=bycols][,max(ndigs(GRP))]
    newpars[,submodel:=sprintf(fmt=paste0("%0",length.num.char,"d"),.GRP),by=bycols]
    newpars[,path.sim:=fnAppend(path.sim.0,submodel),by=.(ROW)]
    newpars[,fn.sim:=basename(path.sim)]
    newpars[,run.sim:=fnExtension(fn.sim,"")]


    if(!all(c("iblock","blocksize")%in%newpars)){
        newpars <- NMdata:::addBlocks(newpars,col.model="submodel")
    }

    
    if(!is.null(write.ext)){
        saveRDS(newpars,file=write.ext)
    }

    
### create control streams one by one

    fast <- TRUE
    if(!fast){
        ## message("NMsim_VarCov: Inits")
        res <- newpars[,
                       NMreplaceInits(files=unique(path.sim.0)
                                     ,fix=TRUE
                                     ,newfile=unique(path.sim)
                                     ,inits=.SD
                                     ,quiet=TRUE)
                      ,by="submodel"]

        
### output tables.
        ## message("NMsim_VarCov: Output tables")
        ## gsub the sim name string with a new subsetted simname string.
        sec.0 <- NMreadSection(file=path.sim.0,section="TABLE")

        newpars[,{
            sec.new <- gsub(run.sim.0,unique(run.sim),x=sec.0)
            NMwriteSection(files=path.sim,section="TABLE",newlines=sec.new,quiet=TRUE,backup=FALSE)
            "dummy"
        },by=.(submodel)]
    }
    
    if(fast){
        message("fast=TRUE is experimental.")
        message("NMsim_VarCov: Inits and output tables")
        ## writing files once instead of twice
### create control streams one by one
        ctls.0 <- lapply(unique(path.sim.0),readLines,warn=FALSE)
        ctls <- lapply(ctls.0,function(ctl0){
            res <- newpars[,
            {
                
### do we have to skip parameters that are not in control stream?
                ctl <- NMwriteInits(lines=ctl0,ext=.SD,update=FALSE)[[1]]
                tab.0 <- NMreadSection(lines=ctl0,section="TABLE")
                tab.new <- gsub(run.sim.0,unique(run.sim),x=tab.0)
                ctl <- NMwriteSectionOne(lines=ctl,section="TABLE",newlines=tab.new,quiet=TRUE,backup=FALSE)
                writeTextFile(ctl,file=unique(path.sim))
                ctl}
           ,by="submodel"]

            res
        })
### TODO write all control streams
    }
    

    invisible(unique(newpars$path.sim))
}
