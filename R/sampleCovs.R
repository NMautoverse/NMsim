##' Sample subject-level covariates from an existing data set 
##'
##' Repeats a data set with just one subject by sampling covariates
##' from subjects in an existing data set. This can conveniently be
##' used to generate new subjects with covariate resampling from an
##' studied population.
##'
##' @param data A simulation data set with only one subject
##' @param Nsubjs The number of subjects to be sampled. This can be
##'     greater than the number of subjects in data.covs.
##' @param col.id Name of the subject ID column in `data` (default is
##'     "ID").
##' @param col.id.covs Name of the subject ID column in `data.covs`
##'     (default is "ID").
##' @param data.covs The data set containing the subjects to sample
##'     covariates from.
##' @param covs The name of the covariates (columns) to sample from
##'     `data.covs`.
##' @param seed.R If provided, passed to `set.seed()`.
##' @param as.fun The default is to return data as a data.frame. Pass
##'     a function (say `tibble::as_tibble`) in as.fun to convert to
##'     something else. If data.tables are wanted, use
##'     as.fun="data.table". The default can be configured using
##'     NMdataConf.
##' @return A data.frame. Includes sampled covariates. The subject
##'     ID's the covariates are sampled from will be included in a
##'     column called `IDCOVS`.
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
                       seed.R,
                       as.fun
                       ){

    IDCOVS <- NULL
    ID <- NULL
    TIME <- NULL
    EVID <- NULL

    
    data <- as.data.table(data)
    
    if(missing(seed.R)) seed.R <- NULL
    if(!is.null(seed.R)) set.seed(seed.R)

    if(missing(covs)) covs <- NULL
    if(is.null(covs)) {
        message("No covariates requested.")
    }

    if(missing(Nsubjs)) Nsubjs <- NULL
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
    dt.ids[,IDCOVS:=sample(dt.covs[,IDCOVS],size=.N,replace=TRUE)]
    dt.ids <- mergeCheck(dt.ids,dt.covs,by="IDCOVS",as.fun="data.table",quiet=TRUE)

    dt.sim.covs <- dt.ids[,
                          data[,setdiff(colnames(data),c(col.id,covs)),with=FALSE]
                         ,by=dt.ids]
    setorderv(dt.sim.covs,cols=intersect(c("ID","TIME","EVID"),colnames(dt.sim.covs)))

    ## return dt.sim.covs
    as.fun(dt.sim.covs)
}
