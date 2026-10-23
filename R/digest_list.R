##' Derive digests of argument values or their contents
##' 
##' Get digests of argument values. Optionally, functions can be run
##' on some arguments before calculating digests. An example would be
##' reading contents of a file where the file path is an argument.
##' 
##' @param list Named list of elements to digest
##' @param funs.unwrap Named list of functions to be applied to elements (matched on names) in `args`. Optional.
##' @return A data.table with columns 'name' and 'res' (digest values)
##' @importFrom digest digest
##' @importFrom tools md5sum
##' @import data.table
##' @keywords internal

### Copied from recycle. Don't edit, don't export.

digest_list <- function(list, args.unwrap = NULL, path.results) {
  
  # Process args.unwrap to convert "function" keyword and build unwrap functions
  # Also auto-detect function arguments and apply "function" unwrapping by default
  
  funs.unwrap <- process_args_unwrap(args.unwrap, list)
  
  # Apply unwrap functions if provided
  if (!is.null(funs.unwrap)) {
    nms.funs <- names(funs.unwrap)
    for (na in nms.funs) {
      if (na %in% names(list)) {
        if (is.null(list[[na]])) {
          list[[na]] <- NULL
        } else {
          list[[na]] <- funs.unwrap[[na]](list[[na]] )
        }
      }
    }
  }
  

  # Calculate digests for each argument
  result <- data.table(
    name = names(list),
    type="arg",
    res = vapply(list, digest, character(1))
  )
  
if(!missing(path.results) && !is.null(path.results)){
  result <- rbind(result,
                  data.table(name="results",type="results",
                             res=as.character(tools::md5sum(path.results))
                             ))
}


  return(result)
}
