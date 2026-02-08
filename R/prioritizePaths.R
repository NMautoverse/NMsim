##' first path that works
##'
##' When using scripts on different systems, the Nonmem path may
##' change from run to run. With this function you can specify a few
##' paths, and it will return the one that works on the system in use.
##' 
##' @param paths vector of file paths. Typically to Nonmem
##'     executables.
##' @param must.work If TRUE, an error is thrown if no paths are
##'     valid.
##' @export
##' 
prioritizePaths <- function(paths,must.work=FALSE){
    paths <- paths[sapply(paths,file.exists)]
    if(!length(paths)){
        if(must.work){
            stop("No paths valid")
        } else {
            message("No paths valid")
            return(NULL)
        }
    }
    paths[1]
}
