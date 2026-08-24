##' Sample subject-level covariates from an existing data set 
##'
##' Repeats a data set with just one subject by sampling covariates from
##' subjects (with replacement) in an existing data set. This can conveniently
##' be used to generate new subjects with covariate resampling from an studied
##' population.
##'
##' @param data A simulation data set with only one subject
##' @param Nsubjs The number of subjects to be sampled. This can be greater than
##'   the number of subjects in data.covs. If `replace=FALSE`, default is to
##'   sample all ID's in `data.covs` exactly once.
##' @param col.id Name of the subject ID column in `data` (default is "ID").
##' @param col.id.covs Name of the subject ID column in `data.covs` (default is
##'   "ID").
##' @param data.covs The data set containing the subjects to sample covariates
##'   from.
##' @param covs The name of the covariates (columns) to sample from `data.covs`.
##' @param replace Sample from subjects in `data.covs` with replacement? Default
##'   is TRUE.
##' @param col.idcgrp The name of the column distinguishing repeated samples of
##'   `IDCOVS`. This is only needed if there are such repetitions (not very
##'   common), and if there are no repetitions, the default (`col.idcgrp=NULL`)
##'   is to leave out the column. default name of the column when included is
##'   `IDCGRP`. See details too if you need this.
##' @param idcgrp.redist See details.
##' @param seed.R If provided, passed to `set.seed()`.
##' @param as.fun The default is to return data as a data.frame. Pass a function
##'   (say `tibble::as_tibble`) in as.fun to convert to something else. If
##'   data.tables are wanted, use as.fun="data.table". The default can be
##'   configured using NMdataConf.
##' @return A data.frame. Includes sampled covariates. The subject ID's the
##'   covariates are sampled from will be included in a column called `IDCOVS`.
##' @details Columns will be added in addition to covariates requested in
##'   `covs`: IDCOVS, and `IDCGRP`. `IDCOVS` is the subject id (`col.id.covs`)
##'   from the covariate data set, for reference. `IDCGRP` is only needed when
##'   covariates are sampled with replacement, and a subsequent Nonmem
##'   simulation is done with `NMsim_EBE`. `NMsim_EBE` reuses the etas (from
##'   estimation or another `.phi` file). Hence for such simulation you will
##'   need to used IDCVOVS as ID in order to match the etas against the relevant
##'   subject ID's. However, since IDCOVS are repeated (due to sampling with
##'   replacement), the easiest is to split the data set so one subject is never
##'   reused within one subset. `IDCGRP` holds a variable to split by so this
##'   will work. By default, IDCGRP is simply the counter of the occurrence of a
##'   (`IDCOVS`) subject. This is simple but impractical for splitting into sub
##'   simulations because the group sizes will tend to be quite uneven.
##'   `idcgrp.redist=TRUE` will reassign `IDCGRP` to balance the group sizes.
##' @examples
##' library(NMdata)
##' data.covs <- NMscanData(system.file("examples/nonmem/xgxr134.mod",package="NMsim"))
##' dos.1 <- NMcreateDoses(TIME=0,AMT=100) 
##' data.sim.1 <- NMaddSamples(dos.1,TIME=c(1,4),CMT=2)
##' sampleCovs(data=data.sim.1,Nsubjs=3,col.id.covs="ID",data.covs=data.covs,covs=c("WEIGHTB","eff0"))
##' @import data.table
##' @import NMdata
##' @export

sampleCovs <- function(data,
                       Nsubjs,
                       col.id= "ID",
                       col.id.covs = "ID",
                       data.covs,
                       covs,
                       replace=TRUE,
                       col.idcgrp,
                       idcgrp.redist=FALSE,
                       seed.R,
                       as.fun
                       ){

    IDCOVS <- NULL
  ID <- NULL
  id <- NULL
  IDCGRP <- NULL
    TIME <- NULL
    EVID <- NULL

    data <- as.data.table(data)
    
    if(missing(seed.R)) seed.R <- NULL
    if(!is.null(seed.R)) set.seed(seed.R)

    if(missing(covs)) covs <- NULL
    if(is.null(covs)) {
        message("No covariates requested.")
    }

  if(!col.id.covs%in%colnames(data.covs)) stop("col.id.covs must denote a column existing in data.covs")
  if(!is.data.table(data.covs)) data.covs <- as.data.table(data.covs)
  
  if(missing(Nsubjs)){
    if(replace) {
      Nsubjs <- NULL
    } else {
      Nsubjs <- as.data.table(data.covs)[,uniqueN(id),env=list(id=col.id.covs)]
    }
  }

  

    if(is.null(Nsubjs)) {
        stop("Nsubjs must be supplied.")
    }

    ## as.fun
    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

### data checks
    ## check if covs are present in data.covs
    cols.miss <- setdiff(covs,colnames(data.covs))
    if(length(cols.miss)){
        stop("Covs missing in data.covs:",paste(cols.miss,collapse=",\n"))
    }

    ## check if covs are already present in data.sim.1subj
    if(any(covs%in%colnames(data))){
        stop("One or more of covs are already in `data`. These columns must be deleted before running `sampleCovs()`.")
    }

    ## check if ther is only one subject in data.sim.1subj
    if(!col.id%in%colnames(data)){
        stop("`col.id` must be the name of an exisiting column in `data`.")
    }
    if(data[,uniqueN(get(col.id))!=1]){
        stop("There must be exactly one subject in `data`.")
    }
    
### calcs
    dt.covs <- findCovs(data.covs  ,by=c(col.id.covs),as.fun="data.table")
    dt.covs <- dt.covs[,c(col.id.covs,covs),with=FALSE]
    setnames(dt.covs,col.id.covs,"IDCOVS")
    dt.ids <- data.table(ID=1:Nsubjs)
    setnames(dt.ids,"ID",col.id)
    dt.ids[,IDCOVS:=sample(dt.covs[,IDCOVS],size=.N,replace=replace)]
    dt.ids <- mergeCheck(dt.ids,dt.covs,by="IDCOVS",as.fun="data.table",quiet=TRUE)

    dt.sim.covs <- dt.ids[,
                          data[,setdiff(colnames(data),c(col.id,covs)),with=FALSE]
                         ,by=dt.ids]
    setorderv(dt.sim.covs,cols=intersect(c("ID","TIME","EVID"),colnames(dt.sim.covs)))

  if(missing(col.idcgrp)) col.idcgrp <- NULL
  if(is.null(col.idcgrp)) {
    col.idcgrp <- "IDCGRP"
    keep.idcgrp <- FALSE
  } else {
    keep.idcgrp <- TRUE
  }

  dt.sim.covs[,(col.idcgrp) := match(ID,unique(ID)),by=IDCOVS]

  if( idcgrp.redist ){
    NO <- dt.sim.covs[,get(col.idcgrp)]
    if(NO>1){
      
      dt.sim.covs[,IDCGRP := sample(1:NO,size=uniqueN(IDCGRP),replace=FALSE)[IDCGRP],by=ID,
                  env=list(IDCGRP=col.idcgrp)]
      ## dt.sim.covs[,.(uniqueN(ID),.N),keyby=IDOCC]
      keep.idcgrp <- TRUE
    }
  }
  ## dt.sim.covs[,IDCGRP.0 := NULL]
  if(!keep.idcgrp){
    dt.sim.covs[,(col.idcgrp) := NULL]
  }

  ## return dt.sim.covs
  as.fun(dt.sim.covs)
}
