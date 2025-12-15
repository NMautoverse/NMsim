##' clean up temporary directories left by PSN and NMsim.
##'
##' @param dir The directory in which to look for contents to clean
##' @param methods The sources to delete temporary content from. This
##'     is a character vector, and the defailt is
##'     `c("nmsim","psn","psnfit","backup")`. Each of these correspond
##'     to a preconfigured pattern.
##' @param recursive Look recursively in folder? Notice, matches will
##'     be deleted recursively (they are often
##'     directories). `recursive` controls whether they are searched
##'     for recursively.
##' @param delete Delete the found matches? If not, the matches are
##'     just reported, but nothing deleted.
##' @return data.table with identified items for deletion
##' @import data.table
##' @import NMdata
##' @export


deleteTmpDirs <- function(dir,methods,recursive=FALSE,delete=TRUE){

    . <- NULL
    method <- NULL
    pattern <- NULL
    
    findTmpType <- function(pattern){
        
        dirsToDelete <- list.files(path=dir,pattern=pattern,full.names=TRUE,recursive=recursive,include.dirs=T)
        dirsToDelete
    }



    dt.methods <- data.table(method=c("nmsim",
                                      "psn",
                                      ## add modelfit_dir5 (also from PSN execute)
                                      "psnfit",
### add backup files like backup_003
                                      "backup"),
                             pattern=c(".*\\_dir[0-9]+$",
                                       "_*\\.dir[0-9]+$",
                                       ".*modelfit_dir\\d+",
                                       "backup_.+")
                             )
    if(missing(methods)||is.null(methods)) methods <- dt.methods[,method]
    ## if(missing(methods)) methods <- c("psn","nmsim")
    methods <- NMdata:::cleanSpaces(methods) 
    methods <- tolower(methods)

    
    dt.methods <- dt.methods[method%in%methods][
       ,row:=.I]

    dt.finds <- dt.methods[,.(
        find=findTmpType(pattern=pattern)
    )
   ,by=.(row,method,pattern)]

    if(delete){
        dt.finds[,unlink(find,recursive=TRUE)]
    }

    dt.sum.finds <- dt.finds[,.N,by=.(method,pattern)]
    
    dt.sum.finds
    
}
