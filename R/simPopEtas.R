##' Generate a population based on a Nonmem model
##'
##' Rather than simulating new subjects for each simulation, use this to create eta's that can be (re-)used for simulations with `NMsim_BEE()`. Although setting a seed for a simulation ensures reproducibility of a specific simulation, changing details of the data set is likely to break that reproducibility. Use `simPopEtas()` to ensure that a subject with a specific ID will always be simulated with the same eta values. This can also be used to reuse subjects between treatments in a simulation. 
##' 
##' @param file Passed to `NMdata::NMreadExt()`. Path to ext file. By
##'     default, `NMreadExt()` uses a`auto.ext=TRUE` which means that
##'     the file name extension is replaced by `.ext` (so you can normally specify a control stream path too). If your ext
##'     file name extension is not `.ext`, add `auto.ext=FALSE` (see
##'     ...).
##' @param N Number of subjects to generate
##' @param seed.R Optional seed. Will be passed to `set.seed`. Same
##'     thing as running `set.seed` just before calling
##'     `simPopEtas()`.
##' @param pars A long-format parameter table containing par.type and
##'     i columns. If this is supplied, the parameter values will not
##'     be read from an ext file, and file has no effect. If an ext
##'     file is available, it is most likely better to use the file
##'     argument.
##' @param file.phi An optional phi file to write the generated
##'     subjects to. This will generate a Nonmem-style `.phi` file that can be reused in combination with `NMsim_EBE`.
##' @param overwrite If `file.phi` exists already, overwrite it?
##'     Default is `FALSE`.
##' @param as.fun The default is to return data as a data.frame. Pass
##'     a function (say `tibble::as_tibble`) in as.fun to convert to
##'     something else. If data.tables are wanted, use
##'     as.fun="data.table". The default can be configured using
##'     NMdataConf.
##' @param file.mod Deprecated. Use file instead.
##' @param seed Deprecated. Use seed.R instead.
##' @param ... Additional arguments passed to NMdata::NMreadExt().
##' @return A data.frame
##' @import data.table
##' @import NMdata
##' @importFrom MASS mvrnorm
##' @export

simPopEtas <- function(file,N,seed.R,pars,file.phi,overwrite=FALSE,as.fun,file.mod,seed,...){

    par.type <- NULL
    i <- NULL
    ID <- NULL
    dt.res <- NULL
    TABLENO <- NULL
    
    if(missing(seed.R)) seed.R <- NULL
    if(missing(pars)) pars <- NULL
    if(missing(file)) file <- NULL
    if(missing(file.phi)) file.phi <- NULL

    if(!missing(file.mod)){
        if(!is.null(file)){
            stop("file and file.mod supplied. Use file and not the deprecated file.mod. ")
        }
        message("file.mod is deprecated. Use file.")
        file <- file.mod
    }

    ## seed deprecated with NMsim 0.1.6 2025-01-29 
    if(missing(seed)) seed <- NULL
    if(!is.null(seed)){
        if(!is.null(seed.R)){
            stop("`seed.R` and `seed` supplied. Use `seed.R` and not the deprecated seed. ")
        }
        message("seed is deprecated. Use `seed.R`.")
        seed.R <- seed
    }
    if(!is.null(seed.R)) set.seed(seed.R)
    
    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

    if(is.null(pars)){
        pars <- NMreadExt(file=file,return="pars",tableno="max",as.fun="data.table",...)
    }
    
    Netas <- pars[par.type=="OMEGA",max(i)]

    Sigma <- dt2mat(pars[par.type=="OMEGA"])
    dt.etas <- as.data.table(mvrnorm(n=N,mu=rep(0,Netas),Sigma=Sigma))
    colnames(dt.etas) <- paste0(substring("ETA",1,3-(1:Netas)%/%10),1:Netas)
    dt.etas[,ID:=1:N]
    setcolorder(dt.etas,"ID")
    
    if(!is.null(file.phi)){
        genPhiFile(data=dt.etas,file=file.phi,overwrite=overwrite)
        return(invisible(as.fun(dt.etas)))
    }
    return(as.fun(dt.etas))
    
}
