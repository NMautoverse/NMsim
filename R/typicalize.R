##' Set variability parameters to zero
##' @param file.mod path to control stream to edit
##' @param lines control stream as lines. Use either file.sim or
##'     lines.sim.
##' @param section The sections (parameter types) to edit. Default is
##'     `c("OMEGA", "OMEGAP", "OMEGAPD")`.
##' @param newfile path and filename to new run. If missing or NULL,
##'     output is returned as a character vector rather than written.
##' @import data.table
##' @import NMdata
##' @keywords internal

typicalize <- function(file.mod,lines,section,newfile){
    
    blocksize <- NULL
    file.sim <- NULL
    FIX <- NULL
    init <- NULL
    par.type <- NULL
    

    if(missing(file.mod)) file.mod <- NULL
    if(missing(lines)) lines <- NULL
    if(missing(section)) section <- NULL
    if(missing(newfile)) newfile <- NULL
    
    lines <- NMdata:::getLines(file=file.mod,lines=lines,simplify=TRUE)
    
    if(is.null(section)){
        section <- c("OMEGA","OMEGAP","OMEGAPD")
    }
    section <- NMdata:::cleanSpaces(section)
    section <- toupper(section)

    inits <- NMreadInits(lines=lines,as.fun="data.table",section=section)
    inits[,init:=as.character(init)]
    valc.0 <- "1E-30"

    inits[par.type%in%section,init:="0"]
    inits[par.type%in%section,FIX:=1]
    if("blocksize"%in%colnames(inits)){
        inits[par.type%in%section&blocksize>1,init:=valc.0]
    }

    mod.new <- NMwriteInits(lines=lines,inits.tab=inits,update=FALSE)

    ## write to file if requested
    if(is.null(newfile)){
        return(mod.new)            
    }

    writeTextFile(lines=mod.new,file=newfile)

    return(file.sim)    

}
