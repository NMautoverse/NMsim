
##' @export

rbind.recycle_digests <- function(x,...){
  
  list.all <- c(list(x),list(...))

  if(length(list.all)==1){
    res <- list.all[[1]]
    addClass(res,"recycle_digests")
    return(res)
  }

  allnames <- unique(unlist(lapply(list.all, names)))

  res <- setNames(
    lapply(allnames, function(nm) {
      ## rbindlist(lapply(list.all, `[[`, nm), use.names = TRUE, fill = TRUE)
      do.call(rbind, c(lapply(list.all, `[[`, nm),list(fill=TRUE)))
    }),
    allnames
  )
  addClass(res,"recycle_digests")

  res
  
}
