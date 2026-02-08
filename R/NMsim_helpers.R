##' @keywords internal
##' 
adjust.method.update.inits <- function(method.update.inits,system.type,dir.psn,cmd.update.inits,file.ext,inits){

    psn <- NULL
    nmsim <- NULL
    none <- NULL
    ## method.update.inits
    if(missing(inits)) inits <- NULL
    if(missing(method.update.inits)) method.update.inits <- NULL

    if(is.null(method.update.inits)){
### if nothing is provided, we use nmsim.deprec in order to support NMdata<0.1.9
        if(length(inits)==0) {
            ## inits$method <- "nmsim.deprec"
            inits$method <- "nmsim"
        } else {
            ## inits is provided, but no method included.
            if(!"method" %in% names(inits)) inits$method <- "nmsim"
        }
    } else {
        if(!is.null(inits)){
            if(!is.null(inits$method)) stop("method.update.inits is deprecated. Use i.e. `inits=list(method='nmsim'` instead. You supplied both which is not allowed.")
        }
        message("method.update.inits is deprecated. Use i.e. `inits=list(method='nmsim'` instead.")
        if(tolower(method.update.inits)=="nmsim") {
            ## this is the old interface. That gives the old method.
            method.update.inits <- "nmsim.deprec"
        }
        inits$method <- method.update.inits
    }

    if(inits$method!="none" && is.null(inits$update)) inits$update <- TRUE
    
    
    if(missing(file.ext)) file.ext <- NULL
    if(!is.null(file.ext)){
        inits$file.ext <- file.ext
    } 
    
    ## if method.execute is psn, default is psn. If not, it is NMsim.
    if(is.null(inits$method)) {
        inits$method <- "nmsim"
    }


    inits$method <- simpleCharArg("inits$method",inits$method,"nmsim",c("psn","nmsim","nmsim.deprec","simple","none"))
    if(inits$method=="simple") inits$method <- "nmsim.deprec"
    ## if update.inits with psn, it needs to be available
    if(inits$method=="psn"){
        
        cmd.update.inits <- file.psn(dir.psn,"update_inits")
        if(system.type=="linux" && suppressWarnings(system(paste(cmd.update.inits,"-h"),ignore.stdout = TRUE)!=0)){
            stop('Attempting to use PSN\'s update_inits but it was not found. Look at the dir.psn argument or use the default `inits=list(method="nmsim")`')
        }
    }

    if(!is.null(inits$file.ext) && inits$method=="psn"){
        stop("argument `file.ext` is not allowed when `inits=list(method='psn')`")
    }


    inits
}


##' Drop spaces and odd characters. Use to ensure generated file names
##' are usable.
##' @param x a string to clean
##' @return A character vector
##' @keywords internal
##' @examples
##' NMsim:::cleanStrings("e w% # ff!l3:t,3?.csv")
##' NMsim:::cleanStrings("3!?:#;<>=, {}|=g+&-
##' .csv")

cleanStrings <- function(x){
    ## x <- gsub(" ","",as.character(x))
    ## x <- gsub("[[:punct:]]", "", x)
    ##  *^$@~% []
    ## x <- gsub("[ !?#:;<>/,[]\\{\\}\\|-=+&]", "", x)


    x <- gsub("[ +!?#:;<>&/,\\{\\}\\|=\\(\\)]", "",x) 
    x <- gsub(pattern="-",replacement="",x=x,perl=TRUE) 
    x <- gsub(pattern="\n",replacement="",x=x)
    
    x
}

file.psn <- function(dir.psn,file.psn){
    if(dir.psn=="none") stop("PSN not found")
    if(dir.psn=="") return(file.psn)
    file.path(dir.psn,file.psn)
}

##' Simplify file paths by dropping .. and //
##' @param path single or multiple file or dir paths as strings.
##' @examples
##' \dontrun{
##' path <- c("ds/asf.t","gege/../jjj.r")
##' NMsim:::simplePath(path)
##' }
##' @return Simplified paths as strings
##' @keywords internal
simplePath <- function(path){
    
    path <- NMdata:::cleanSpaces(path,double=FALSE)
    parts.list <- strsplit(path,"/")

    newpath <- sapply(parts.list,function(parts){
        
        simple <- character(0)
        is.abs <- parts[1]==""
        for(p in parts){
            
            if(p==""||p==".") next
            if(p==".." && length(simple)){
                simple <- head(simple,-1)
            } else {
                simple <- c(simple,p)
            }
        }
        res <- paste(simple,collapse="/")
        if(is.abs) res <- paste0("/",res)
        res
    })
    
    return(newpath)
}
