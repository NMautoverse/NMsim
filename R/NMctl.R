
##' Read as class NMctl
##' @param x object to read.
##' @param ... Not used.
##' @return An object of class `NMctl`.
##' @export
readCtl <- function(x,...){
    UseMethod("readCtl",x)
}

##readCtl(x="run1.mod")

##' @import NMdata
##' @export
readCtl.character <- function(x,...){
    ## ctl <- NMreadSection(file=x)
    ctl <- readLines(x,warn=FALSE)
    ## ctl <- as.NMctl(ctl)
    class(ctl) <- "NMctl"
    ctl
}

##' @export
readCtl.NMctl <- function(x,...){
    x
}

##' @export
print.NMctl <- function(x,...) {
   
    if(!is.list(x)) x <- list(x)
    res <- lapply(x,function(x){
        x <- x[!grepl("^ *$",x)]
        paste0(paste(x,collapse="\n"),"\n\n")
    })
    cat(do.call(paste0,res))
}

##' Convert object to class NMctl
##' @param x object to convert
##' @param ... Not used
##' @return An object of class `NMctl`.
##' @export
as.NMctl <- function(x,...){
    UseMethod("as.NMctl",x)
}

##' @export
as.NMctl.character <- function(x,...){
    
    readCtl(x)
}

##' @export
as.NMctl.NMctl <- function(x,...){
    x
}
