##' Internal method for handling modify argument to NMsim
##' @param modify A list
##' @param dt.models a data.table
##' @param list.ctl List of coontrol streams as lines
##' @return dt.models (data.table) or result list.ctl (list) depending
##'     on whether the `dt.models` or the `list.ctl` argument was
##'     provided.
##' @import data.table
##' @keywords internal



modifyModel <- function(modify,dt.models=NULL,list.ctl=NULL){

    if(!length(modify)) {
        if(!is.null(dt.models)) return(dt.models)
        return(list.ctl)
    }

    ##
    modifyModelOne <- function(modify,dt.models=dt.models,list.ctl=list.ctl){
        . <- NULL
        path.sim <- NULL
        ROWMODEL <- NULL
        
        ## grab name and other arguments for NMwriteSection. 
        if(is.list(modify[[1]])){
            args <- modify[[1]]
            args$section <- toupper(names(modify))
            args$quiet <- TRUE
            args$backup <- FALSE
            ## do not use list.sections
        } else {
            args <- list(quiet=TRUE,backup=FALSE,list.sections=modify)
        }
        if(!is.null(list.ctl)){
            result <- lapply(list.ctl,function(ctl){
                args.all= append(list(lines=ctl),args)
                do.call(NMdata:::NMwriteSectionOne,args.all)
            })
        }
        if(!is.null(dt.models)){
            dt.models[,{
                args.all= append(list(files=path.sim),args)
                do.call(NMwriteSection,args.all)
            },by=.(ROWMODEL)]
            result <- dt.models
        }
        result
    }

    for(Nmodif in 1:length(modify)){
        list.ctl <- modifyModelOne(modify[Nmodif],dt.models=dt.models,list.ctl=list.ctl)
    }
    
    list.ctl
}
