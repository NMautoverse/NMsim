##' Add simulation (sample) records to dosing records
##'
##' Adds simulation events to all subjects in a data set. Copies over
##' columns that are not varying at subject level (i.e. non-variying
##' covariates). Can add simulation events relative to previous dosing
##' time. This function was previously called `addEVID2()`.
##' 
##' @param data Nonmem-style data set. If using `TAPD` an `EVID`
##'     column must contain 1 for dosing records.
##' @param TIME A numerical vector with simulation times. Can also be
##'     a data.frame in which case it must contain a `TIME` column and
##'     is merged with `data`.
##' @param TAPD A numerical vector with simulation times, relative to
##'     previous dose. When this is used, `data` must contain rows
##'     with `EVID=1` events and a `TIME` column. `TAPD` can also be a
##'     data.frame in which case it must contain a `TAPD` column and
##'     is merged with `data`.
##' @param CMT The compartment in which to insert the EVID=2
##'     records. Required if `CMT` is a column in `data`. If longer
##'     than one, the records will be repeated in all the specified
##'     compartments. If a data.frame, covariates can be specified.
##' @param EVID The value to put in the `EVID` column for the created
##'     rows. Default is 2 but 0 may be prefered even for simulation.
##' @param DV Optionally provide a single value to be assigned to the
##'     `DV` column. The default is to assign nothing which will
##'     result in `NA` as samples are stacked (`rbind`) with
##'     `data`. If you assign a different value in `DV`, the default
##'     value of `EVID` changes to `0`, and `MDV` will be `0` instead
##'     of `1`. An example where this is useful is when generating
##'     datasets for `$DESIGN` where `DV=0` is often used.
##' @param col.id The name of the column in `data` that holds the
##'     unique subject identifier. Currently, this is needed to be
##'     non-`NULL`.
##' @param args.NMexpandDoses Only relevant - and likely not needed -
##'     if data contains ADDL and II columns. If those columns are
##'     included, `NMaddSamples()` will use `NMdata::NMexpanDoses()`
##'     to evaluate the time of each dose. Other than the `data`
##'     argument, `NMaddSamples()` relies on the default
##'     `NMexpanDoses()` argument values. If this is insufficient, you
##'     can specify other argument values in a list, or you can call
##'     `NMdata::NMexpanDoses()` manually before calling
##'     `NMaddSamples()`.
##' @param unique If `TRUE` (default), events are reduced to unique
##'     time points before insertion. Sometimes, it's easier to
##'     combine sequences of time points that overlap (maybe across
##'     `TIME` and `TAPD`), and let `NMaddSamples()` clean them. If
##'     you want to keep your duplicated events, use `unique=FALSE`.
##' @param by If \code{TIME} and/or `TAPD` are `data.frame`s and
##'     contain other columns than `TIME` and/or `TAPD`, those will by
##'     default follow the `TIME`/`TAPD` records. Think of them as
##'     record-level variables, like `VISIT`. The exception is
##'     `col.id` - if the subject identifier is present, it will be
##'     merged by. If additional columns should be used to merge by,
##'     you can use the `by` argument. This is useful to generate
##'     differentiated sampling schemes for subsets of subjects (like
##'     regimen="SAD" and regimen="MAD"). If no columns in `TIME`
##'     and/or `TAPD` should not be merged by, use `by=FALSE`. You can
##'     also specify selected `by` variables like `by="ID"` or
##'     `by=c("ID","regimen")` See examples.
##' @param quiet Suppress messages? Default is `FALSE`.
##' @param as.fun The default is to return data as a
##'     `data.frame`. Pass a function (say `tibble::as_tibble`) in
##'     as.fun to convert to something else. If data.tables are
##'     wanted, use `as.fun="data.table"`. The default can be
##'     configured using `NMdataConf()`.
##' @param extras.are.covs Deprecated. Use `by`.
##' @param doses Deprecated. Use `data`.
##' @param time.sim Deprecated. Use `TIME`.
##' @details The resulting data set is ordered by ID, TIME, and
##'     EVID. You may have to reorder for your specific needs.
##' @examples
##' (doses1 <- NMcreateDoses(TIME=c(0,12,24,36),AMT=c(2,1)))
##' NMaddSamples(doses1,TIME=seq(0,28,by=4),CMT=2)
##'
##' ## two named compartments
##' dt.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' dt.cmt <- data.frame(CMT=c(2,3),analyte=c("parent","metabolite"))
##' res <- NMaddSamples(dt.doses,TIME=seq.time,CMT=dt.cmt)
##' 
##' ## Separate sampling schemes depending on covariate values
##' dt.doses <- NMcreateDoses(TIME=data.frame(regimen=c("SD","MD","MD"),TIME=c(0,0,12)),AMT=10,CMT=1)
##'
##' seq.time.sd <- data.frame(regimen="SD",TIME=seq(0,3))
##' seq.time.md <- data.frame(regimen="MD",TIME=c(0,12,24))
##' seq.time <- rbind(seq.time.sd,seq.time.md)
##' NMaddSamples(dt.doses,TIME=seq.time,CMT=2,by="regimen")
##'
##' ## All subjects get all samples
##' NMaddSamples(dt.doses,TIME=seq.time,by=FALSE,CMT=2)
##'
##' ## an observed sample scheme and additional simulation times
##' df.doses <- NMcreateDoses(TIME=0,AMT=50,addl=list(ADDL=2,II=24))
##' dense <- c(seq(1,3,by=.1),4:6,seq(8,12,by=4),18,24)
##' trough <- seq(0,3*24,by=24)
##' sim.extra <- seq(0,(24*3),by=2)
##' time.all <- c(dense,dense+24*3,trough,sim.extra)
##' time.all <- sort(unique(time.all))
##' dt.sample <- data.frame(TIME=time.all)
##' dt.sample$isobs <- as.numeric(dt.sample$TIME%in%c(dense,trough))
##' dat.sim <- NMaddSamples(dt.doses,TIME=dt.sample,CMT=2)
##'
##' ## TAPD - time after previous dose
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' NMaddSamples(df.doses,TAPD=seq.time,CMT=2)
##'
##' ## TIME and TAPD
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' NMaddSamples(df.doses,TIME=seq.time,TAPD=3,CMT=2)
##'
##' ## Using a custom DV value affects EVID and MDV 
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(4)
##' NMaddSamples(df.doses,TAPD=seq.time,CMT=2,DV=0)
##' @import data.table
##' @import NMdata
##' @export
##' @return A data.frame with dosing records



NMaddSamples <- function(data,TIME,TAPD,CMT,EVID,DV,col.id="ID",args.NMexpandDoses,unique=TRUE,
                         by,quiet=FALSE,as.fun,doses,time.sim,extras.are.covs){

    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    . <- NULL
    DOSN <- NULL
    ##    ID <- NULL
    MDV <- NULL
    PDOSN <- NULL
    TDOS <- NULL

### Section end: Dummy variables, only not to get NOTE's in pacakge checks
    
    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

    if(missing(doses)) doses <- NULL
    if(missing(time.sim)) time.sim <- NULL
    if(missing(TIME)) TIME <- NULL
    if(missing(TAPD)) TAPD <- NULL
    if(missing(args.NMexpandDoses)) args.NMexpandDoses <- NULL

    if(missing(CMT)) CMT <- NULL

    if(missing(by)) by <- NULL
    ## by default, merge by col.id
    if(is.null(by)) by <- col.id
    if(isFALSE(by)) by <- NULL
    
    if("CMT"%in%colnames(data) && is.null(CMT)) {
        stop("`CMT` column is present in `data`. In this case, the `CMT` argument must be provided.")
    }

    if(!missing(extras.are.covs) && !is.null(extras.are.covs)) warning("extras.are.covs have been deprecated and is not working. Use `by` instead.")
    
    col.evid <- "EVID"
    col.time <- "TIME"
    
### this requires NMdata 0.1.7
    ## args <- NMdata:::getArgs(sys.call(),parent.frame())
    ## data <- NMdata:::deprecatedArg("doses","data",args=args)
    ## TIME <- NMdata:::deprecatedArg("time.sim","TIME",args=args)
    if(!quiet && !is.null(doses)){
        message("Argument doses is deprecated. Please use data instead.")
        data <- doses
    }
    if(!quiet && !is.null(time.sim)){
        message("Argument time.sim is deprecated. Use TIME and/or TAPD instead.")
        TIME <- time.sim
    }

    if(missing(DV)) DV <- NULL
    ..DV <- DV
    
    if(missing(EVID)||is.null(EVID)){
        if(is.null(DV)){
            EVID <- 2
        } else {
            EVID <- 0
        }
    }
    ..EVID <- EVID
    
    if(is.data.table(data)) {
        data <- copy(data)
    } else {
        data <- as.data.table(data)
    }

    ## adds
    ##' only using column names in covs.data (from data) that are not in TIME.
    ##' 
    ##' All rows in TIME get reused for all matches by column names common with covs.data - the identified subject-level covariates (and col.id). This is with the exception of the TIME column itself, because in case of single dose, TIME would be carried over.
    
    cols.not.by <- c( col.evid,"AMT","RATE","CMT","DV","MDV","SS","ADDL","II")
    
    augment.covs <- function(TIME,col.time,covs.data,cols.time=c("TIME","TAPD")){
        
        if(is.null(TIME)) return(TIME)
        
        if(!is.data.frame(TIME)){
            TIME <- as.data.table(setNames(list(TIME),col.time))
        }

        if(!col.time%in%colnames(TIME)) stop(sprintf("When %s is a data.frame, it must contain a column called %s.",col.time,col.time))
        TIME <- as.data.table(TIME)
        
        ## merge by extra columns
### cols.by is the subset of by that can be merged by
        cols.by <- by
        cols.common <- intersect(colnames(TIME),colnames(covs.data))
        cols.by <- intersect(cols.by,cols.common)
        cols.by <- setdiff(cols.by,cols.not.by)
        
        if(length(cols.by) == 0){
            ## no by columns found
            ##if(length(cols.common)){
### drop common columns from covs.data. Since they are
### not in by they should not be inherited from
### covs.data.
            covs.data.add <- covs.data[,setdiff(colnames(covs.data),cols.common),with=FALSE]
            dt.obs <- egdt(TIME,covs.data.add,quiet=TRUE)

        } else {
            ## cols.by found. We need to merge by cols.by - but not other common columns            
            covs.data.add <- covs.data[
               ,c(setdiff(colnames(covs.data),setdiff(cols.common,cols.by))),with=FALSE]

            if(col.id%in%cols.by){
                ## since col.id is to be merged by, we merge covariates onto TIME and re-derive covariates. This is so that id's in TIME not in existing data will still be reused
                covs.data.add <- merge(unique(TIME[,cols.by,with=FALSE]),covs.data.add,by=cols.by,all.x=TRUE)
            }
            dt.obs <-
                merge(
                    covs.data.add
                   ,
                    TIME
                   ,by=cols.by,allow.cartesian = TRUE)
            if(!quiet && !nrow(dt.obs)) {
                message("No samples added. Covariates were found in sample time specifications but no matches found in `data`. Notice that extra columns (covariates) in `TIME` and `TAPD` must be matched in `data` for respective time values to be added.")
            }
        }
        return(dt.obs)

    }

    
    cols.covs.try <- setdiff(colnames(data),c("TIME",cols.not.by))
    covs.data <- findCovs(data[,cols.covs.try,with=FALSE],by=col.id,as.fun="data.table")
    dt.obs <- augment.covs(TIME,col.time="TIME",covs.data=covs.data)


    dt.tapd <- augment.covs(TAPD,col.time="TAPD",covs.data=covs.data)


    if(!is.null(TAPD)){

        if(is.null(args.NMexpandDoses)) args.NMexpandDoses <- list()
        args.NMexpandDoses$data <- data[get(col.evid)%in%c(1,4)]

        if(nrow(args.NMexpandDoses$data)==0){
            message(!quiet && "No doses in data. `TAPD` is ignored.")
            TAPD <- NULL
        }

        if(is.null(args.NMexpandDoses$quiet)) args.NMexpandDoses$quiet <- TRUE
        doses.tmp <- do.call(NMexpandDoses,args.NMexpandDoses)

        names.covs <- colnames(covs.data)
        doses.tmp <- doses.tmp[,c(colnames(covs.data),"TIME"),with=FALSE][,DOSN:=1:.N,by=names.covs]
        setnames(doses.tmp,"TIME","TDOS")
        
        
        
        dt.obs.1 <- merge(doses.tmp[,c(names.covs,"DOSN","TDOS"),with=FALSE],dt.tapd,by=c(names.covs),allow.cartesian=T)
        dt.obs.1[,TIME:=TDOS+TAPD]
        dt.obs.1[,(col.evid):=..EVID]
        doses.tmp[,(col.evid):=1][,TIME:=TDOS][,PDOSN:=DOSN] 
        dt.obs.2 <- rbind(doses.tmp,dt.obs.1,fill=TRUE)

        order.evid = rev(c(3,0,2,4,1))
        col.evidorder <- tmpcol(dt.obs.2,base="evidorder")
        dt.obs.2[,(col.evidorder):=match(get(col.evid),table=order.evid)]

        ## have to include covariates in sorting
        cols.common.not.time <- intersect(c(colnames(TIME),colnames(TAPD)),colnames(covs.data))
        
        setorderv(dt.obs.2,c(cols.common.not.time,col.time,col.evidorder))
        dt.obs.2[,(col.evidorder):=NULL]
        
        dt.obs.2[,PDOSN:=nafill(PDOSN,type="locf"),by=col.id]

        
        
        dt.obs.3 <- dt.obs.2[get(col.evid)==..EVID&DOSN==PDOSN]
        dt.obs.3 <- dt.obs.3[,c(col.time,intersect(colnames(dt.tapd),colnames(dt.obs.3))),with=FALSE]
        dt.obs <- rbind(dt.obs,dt.obs.3,fill=TRUE) 
        dt.obs <- setorderv(dt.obs,col.time)
    }

    if(unique){
        dt.obs <- unique(dt.obs)
    }

    
    dt.obs[
       ,(col.evid):=..EVID]

    
    if("MDV"%in%colnames(data)){
        if(!is.null(DV)){
            dt.obs[,MDV:=0]
        } else {
        dt.obs[,MDV:=1]
        }
    }

    if(!is.null(DV)){
        dt.obs[
           ,DV:=..DV]## [
           ## ,MDV:=0]
    }



### add CMT
    if(!is.null(CMT)){
        dt.obs <- dt.obs[,setdiff(colnames(dt.obs),colnames(CMT)),with=FALSE]
        if (!is.data.frame(CMT)){
            CMT <- data.table(CMT=CMT)
            
        } else if (!is.data.table(CMT)){
            CMT <- as.data.table(CMT)
        }
        
        dt.obs <- egdt(dt.obs,CMT,quiet=TRUE)
    }

    dat.sim <- rbind(data,dt.obs,fill=T)

#### not sure how to allow flexible sorting. For now, NB order is naive.
    c.times <- intersect(c("TIME","TAPD"),colnames(dat.sim))
    setorderv(dat.sim,cols=c(col.id,c.times,col.evid))

    as.fun(dat.sim)
}

