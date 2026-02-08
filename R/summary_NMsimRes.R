##' summary method for NMsim results (NMsimRes objects)
##' @param object An NMsimRes object (from NMsim).
##' @param ... Not used
##' @return A list with summary information on the NMsimRes object.
##' @export
summary.NMsimRes <- function(object,...){

#### Section start: Dummy variables, only not to get NOTE's in pacakge checks #### ####

    . <- NULL
    EVID <- NULL
    evid <- NULL
    grp0 <- NULL
    ID <- NULL
    model <- NULL
    model.sim <- NULL
    NMREP <- NULL
    RepID <- NULL

### Section end: Dummy variables, only not to get NOTE's in pacakge checks ####


    
    dots <- list(...)
    defaults <- list(
        evid=TRUE
    )
    ## prioritize dots
    dots <- modifyList(defaults,dots)
    
    if(!inherits(object,"NMsimRes")){
        stop("object is not an NMsimRes object.")
    }


    cl.obj <- class(object)
    cl.obj <- setdiff(cl.obj,"NMsimRes")
    if(length(cl.obj)>1) cl.obj <- setdiff(cl.obj,"data.frame")

    
    ## drop class without editing by ref
    res <- copy(object)
    unNMsimRes(res)
    ## the rest will be done on data.table
    if(!is.data.table(res)) res <- as.data.table(res)

    ## add NMREP,
    if("NMREP"%in%colnames(res)) res[,NMREP:=1]
    fun.print.NMREP <- function(SD){
        if("NMREP"%in%colnames(SD)) return(SD[,uniqueN(NMREP)])
        return(0)
    }


    res.main <- res[,.(class.obj=cl.obj,
                       N.rows=nrow(.SD),
                       N.cols=ncol(.SD),
                       "uniqueN(model)"=uniqueN(model),"uniqueN(model.sim)"=uniqueN(model.sim),"uniqueN(NMREP)"=fun.print.NMREP(.SD))] 

    
    ## IDs - number
    res.id.evid <- NULL 
    res.evid.miss <- NULL

    res.id <- res[,.(RepID=.N),by=ID][,.(N.ID=uniqueN(ID),median.Rep=median(RepID),min.Rep=min(RepID),max.Rep=max(RepID))]
    if( dots$evid && "EVID"%in%colnames(res)){
        res.id2 <- res[,.(RepID=.N),by=c("ID","EVID")]
        
        res.id.evid <- res.id2[
           ,.(N.ID=uniqueN(ID),median.Rep=round(median(RepID),1),min.Rep=min(RepID),max.Rep=max(RepID)),
            keyby=c("EVID")]

        res.id2[,evid:=reorder(paste0("EVID=",EVID),EVID)]
        id.nEVID <- dcast(res.id2,ID~evid,value.var="RepID",fill=0)
        id.nEVID.miss <- id.nEVID[rowSums(id.nEVID[,!"ID",with=FALSE]==0,na.rm=TRUE)>0]
        ##
        
        if(nrow(id.nEVID.miss)){
            
            cols.not.id <- setdiff(colnames(id.nEVID.miss),"ID")
            ## grp0 is the column number where zero is found. Just an internal ref. The rest of the columns are how many of the other event types they do have.
            id.nEVID.miss[,grp0:=apply(.SD==0,1,function(z)paste(which(as.logical(z))+1,  collapse="_")),.SDcols=cols.not.id  ]
            res.evid.miss <- id.nEVID.miss[,c(list("N IDs"=.N),lapply(.SD,function(x){
                fifelse(all(unique(x))==0,"0",sprintf("%-s - %s",min(x),max(x)))
            })),
            .SDcols=cols.not.id,
            by=grp0]
        }
    }

    

    res <- list(main=res.main,
                id=res.id,
                id.evid=res.id.evid,
                evid.miss=res.evid.miss)
    
    setattr(res,"class",c("summary_NMsimRes",class(res)))

    res

}


##' print method for NMsimRes summaries
##' @param x The summary object to be printed. See ?summary.NMsimRes
##' @param ... Arguments passed to other print methods.
##' @return NULL (invisibly)
##' @import data.table
##' @export
print.summary_NMsimRes <- function(x,...){

    . <- NULL
    median.Rep <- NULL
    min.Rep <- NULL
    max.Rep <- NULL
    sum.rep <- NULL
    N.ID <- NULL
    EVID <- NULL

    
    dots <- list(...)
    message(with(x$main,sprintf("NMsim results as %s (%d rows, %d columns)",class.obj,N.rows,N.cols)))
    ## message("Number of source models (file.mod), NMsim model runs, and subproblems")
    ## main.sub <- x$main[,!(c("class.obj","N.rows","N.cols"))]
    ## main.l <- melt(
    ##     main.sub,
    ##     measure.vars=colnames(main.sub),value.name="N")
    ## message_dt(main.l)
    message(sprintf("Number of source models (file.mod): %d", x$main$`uniqueN(model)`))
    message(sprintf("Number of NMsim model runs: %d", x$main$`uniqueN(model.sim)`))
    message(sprintf("Number of subproblems: %d", x$main$`uniqueN(NMREP)`))
    ## message("Number of distinct ID's, with median, min and max of rows with each ID.")
    message()

    if( !is.null(x$id )){
        message("Summary of number of ID's")
        x$id[,sum.rep:=sprintf("%d (%d; %d)",median.Rep,min.Rep,max.Rep)]
        NMdata:::message_dt(x$id[,.("No of ID's."=N.ID,"Rows per ID (min; max)"= sum.rep)])
    }

    if( !is.null(x$id.evid )){
        message("Number of ID's on each event type:")
        x$id.evid[,sum.rep:=sprintf("%d (%d; %d)",median.Rep,min.Rep,max.Rep)]
        NMdata:::message_dt(x$id.evid[,.(EVID,"No of ID's."=N.ID,"Rows per ID (min; max)"=sum.rep)])
    }


    if( !is.null(x$evid.miss )){
        message("Not all ID's have all event types.")
        message("Number of other events for those who do not:")
        ##x$evid.miss[,sum.rep:=sprintf("%d (%d; %d)",median.Rep,min.Rep,max.Rep)]
        NMdata:::message_dt(x$evid.miss[,setdiff(colnames(x$evid.miss),"grp0"),with=FALSE])
    }

    return(invisible(NULL))
}
