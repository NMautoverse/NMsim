##' Add simulation records to dosing records
##'
##' Deprecated, use `NMaddSampples()`. Adds simulation events to all
##' subjects in a data set. Copies over columns that are not varying
##' at subject level (i.e. non-variying covariates). Can add
##' simulation events relative to previous dosing time.
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
##'     unique subject identifier.
##' @param args.NMexpandDoses Only relevant - and likely not needed -
##'     if data contains ADDL and II columns. If those columns are
##'     included, `addEVID2()` will use `NMdata::NMexpanDoses()` to
##'     evaluate the time of each dose. Other than the `data`
##'     argument, `addEVID2()` relies on the default `NMexpanDoses()`
##'     argument values. If this is insufficient, you can specify
##'     other argument values in a list, or you can call
##'     `NMdata::NMexpanDoses()` manually before calling `addEVID2()`.
##' @param unique If `TRUE` (default), events are reduced to unique
##'     time points before insertion. Sometimes, it's easier to
##'     combine sequences of time points that overlap (maybe across
##'     `TIME` and `TAPD`), and let `addEVID2()` clean them. If you
##'     want to keep your duplicated events, use `unique=FALSE`.
##' @param extras.are.covs If `TIME` and/or `TAPD` are `data.frame`s
##'     and contain other columns than `TIME` and/or `TAPD`, those are
##'     by default assumed to be covariates to be merged with
##'     data. More specifically, they will be merged by when the
##'     sample times are added. If `extras.are.covs=FALSE`, they will
##'     not be merged by. Instead, they will just be kept as
##'     additional columns with specified values, aligned with the
##'     sample times.
##' @param as.fun The default is to return data as a
##'     `data.frame`. Pass a function (say `tibble::as_tibble`) in
##'     as.fun to convert to something else. If data.tables are
##'     wanted, use `as.fun="data.table"`. The default can be
##'     configured using `NMdataConf()`.
##' @param doses Deprecated. Use `data`.
##' @param time.sim Deprecated. Use `TIME`.
##' @details The resulting data set is ordered by ID, TIME, and
##'     EVID. You may have to reorder for your specific needs.
##' @examples
##' (doses1 <- NMcreateDoses(TIME=c(0,12,24,36),AMT=c(2,1)))
##' addEVID2(doses1,TIME=seq(0,28,by=4),CMT=2)
##'
##' ## two named compartments
##' dt.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' dt.cmt <- data.frame(CMT=c(2,3),analyte=c("parent","metabolite"))
##' res <- addEVID2(dt.doses,TIME=seq.time,CMT=dt.cmt)
##' 
##' ## Separate sampling schemes depending on covariate values
##' dt.doses <- NMcreateDoses(TIME=data.frame(regimen=c("SD","MD","MD"),TIME=c(0,0,12)),AMT=10,CMT=1)
##'
##' seq.time.sd <- data.frame(regimen="SD",TIME=seq(0,6))
##' seq.time.md <- data.frame(regimen="MD",TIME=c(0,4,12,24))
##' seq.time <- rbind(seq.time.sd,seq.time.md)
##' addEVID2(dt.doses,TIME=seq.time,CMT=2)
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
##' dat.sim <- addEVID2(dt.doses,TIME=dt.sample,CMT=2)
##'
##' ## TAPD - time after previous dose
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' addEVID2(df.doses,TAPD=seq.time,CMT=2)
##'
##' ## TIME and TAPD
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(0,4,12,24)
##' addEVID2(df.doses,TIME=seq.time,TAPD=3,CMT=2)
##'
##' ## Using a custom DV value affects EVID and MDV 
##' df.doses <- NMcreateDoses(TIME=c(0,12),AMT=10,CMT=1)
##' seq.time <- c(4)
##' addEVID2(df.doses,TAPD=seq.time,CMT=2,DV=0)
##' @import data.table
##' @import NMdata
##' @return A data.frame with dosing records
##' @export 

## Deprecated since NMsim 0.2.1

addEVID2 <- function(data,TIME,TAPD,CMT,EVID,DV,col.id="ID",args.NMexpandDoses,unique=TRUE,
                     extras.are.covs=TRUE,as.fun,doses,time.sim){
    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    . <- NULL
    DOSN <- NULL
    ##    ID <- NULL
    MDV <- NULL
    PDOSN <- NULL
    TDOS <- NULL

### Section end: Dummy variables, only not to get NOTE's in pacakge checks

    message("`addEVID2()` is deprecated and is no longer maintained. Use `NMaddSamples()` instead.")


   
    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

    if(missing(doses)) doses <- NULL
    if(missing(time.sim)) time.sim <- NULL
    if(missing(TIME)) TIME <- NULL
    if(missing(TAPD)) TAPD <- NULL
    if(missing(args.NMexpandDoses)) args.NMexpandDoses <- NULL

    if(missing(CMT)) CMT <- NULL
    
    col.evid <- "EVID"
    col.time <- "TIME"
    
### this requires NMdata 0.1.7
    ## args <- NMdata:::getArgs(sys.call(),parent.frame())
    ## data <- NMdata:::deprecatedArg("doses","data",args=args)
    ## TIME <- NMdata:::deprecatedArg("time.sim","TIME",args=args)
    if(!is.null(doses)){
        if(!is.null(data)){
            stop("doses argument cannot be used together with data argument. Just use data.")
        }
        ## Not saying anything - addEVID2 is a deprecated function altogether
        ## message("Argument doses is deprecated. Please use data instead.")
        data <- doses
    }
    if(!is.null(time.sim)){
        message("Argument time.sim is deprecated. Use TIME instead.")
        TIME <- time.sim
    }

    if("CMT"%in%colnames(data) && is.null(CMT)) {
        stop("`CMT` column is present in `data`. In this case, the `CMT` argument must be provided.")
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

    
    to.use <- setdiff(colnames(data),c("TIME",col.evid,"CMT","AMT","RATE","MDV","SS","II","ADDL","DV"))
    covs.data <- findCovs(data[,to.use,with=FALSE],by=col.id,as.fun="data.table")

    dt.obs <- NULL
### handle time
    if(!is.null(TIME)){
        if(!is.data.frame(TIME)){
            TIME <- data.table(TIME=TIME)
            ## dt.obs <- egdt(dt.obs,covs.data,quiet=TRUE)
        }

        if(!"TIME"%in%colnames(TIME)) stop("When TIME is a data.frame, it must contain a column called TIME.")
        TIME <- as.data.table(TIME)

        
        if(extras.are.covs){
            cols.by <- intersect(colnames(TIME),colnames(covs.data))

            if(length(cols.by) == 0){
                dt.obs <- egdt(TIME,covs.data,quiet=TRUE)
            } else {

                dt.obs <-
                    ## merge(TIME,covs.data,by=cols.by,all.x=TRUE,allow.cartesian = TRUE)
                    merge(covs.data,TIME,by=cols.by,allow.cartesian = TRUE)
                if(!nrow(dt.obs)) message("No samples added. Covariates were found in sample time specifications but no matches found in `data`. Notice that extra columns (covariates) in `TIME` and `TAPD` must be matched in `data` for respective time values to be added.")
            }

        } else {
##### Check that no 
            dt.obs <- egdt(TIME,covs.data[,setdiff(colnames(covs.data),colnames(TIME)),with=FALSE],quiet=TRUE)
        }
        
        

    }

#### handle TAPD - add to time
    if(!is.null(TAPD)){
        
        if(!is.data.frame(TAPD)){
            TAPD <- data.table(TAPD=TAPD)
        }

        if(!"TAPD"%in%colnames(TAPD)) stop("When TAPD is a data.frame, it must contain a column called TAPD.")
        TAPD <- as.data.table(TAPD)
        ## TODO - TAPD cannot be a covariate
        cols.by <- intersect(colnames(TAPD),colnames(covs.data))
        
        if(length(cols.by) == 0){
            dt.tapd <- egdt(TAPD,covs.data,quiet=TRUE)
            ##dt.tapd <- TAPD
        } else {
            dt.tapd <- merge(TAPD,covs.data,all.x=TRUE,allow.cartesian = TRUE)
        }
        
        if(is.null(args.NMexpandDoses)) args.NMexpandDoses <- list()
        args.NMexpandDoses$data <- data[get(col.evid)%in%c(1,4)]

        if(nrow(args.NMexpandDoses$data)==0){
            message("No doses in data. `TAPD` is ignored.")
            TAPD <- NULL
        }

    }

    if(!is.null(TAPD)){

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
        cols.by.all <- intersect(c(colnames(TIME),colnames(TAPD)),colnames(covs.data))
        
        setorderv(dt.obs.2,c(cols.by.all,col.time,col.evidorder))
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
       ,(col.evid):=..EVID][
       ,MDV:=1]

    if(!is.null(DV)){
        dt.obs[
           ,DV:=..DV][
           ,MDV:=0]
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

    setorderv(dat.sim,cols=c(col.id,"TIME",col.evid))

    as.fun(dat.sim)
}
