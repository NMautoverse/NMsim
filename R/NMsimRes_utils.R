##' Remove NMsimRes class and discard NMsimRes meta data
##' @param x An 'NMsimRes' object.
##' @return x stripped from the 'NMsimRes' class
##' @export
##' @rdname NMsimResOperations
unNMsimRes <- function(x){
  if(!is.null(x)){
    ## setattr(x,"NMsimRes",NULL)
    setattr(x,"NMsimModTab",NULL)
    setattr(x,"meta",NULL)
    setattr(x,"class",setdiff(class(x),"NMsimRes"))
  }
}


##' Check if an object is 'NMsimRes'
##' @param x Any object
##' @return logical if x is an 'NMsimRes' object
##' @export
##' @rdname NMsimResOperations
is.NMsimRes <- function(x){
  inherits(x,"NMsimRes")
}


##' Basic arithmetic on NMsimRes objects
##'
##' @param x an NMsimRes object
##' @param ... arguments passed to other methods.
##' @details When 'dimnames', 'merge', 'cbind', 'rbind', or 't' is
##'     called on an 'NMsimRes' object, the 'NMsimRes' class is dropped,
##'     and then the operation is performed. So if and 'NMsimRes' object
##'     inherits from 'data.frame' and no other classes (which is
##'     default), these operations will be performed using the
##'     'data.frame' methods. But for example, if you use 'as.fun' to
##'     get a 'data.table' or 'tbl', their respective methods are used
##'     instead.
##' @return An object that is not of class 'NMsimRes'.
##' @name NMsimResOperations
NULL

##' @rdname NMsimResOperations
##' @export
merge.NMsimRes <- function(x,...){
  unNMsimRes(x)
  merge(x,...)
}

##' @rdname NMsimResOperations
##' @export
t.NMsimRes <- function(x,...){
  unNMsimRes(x)
  t(x,...)
}

##' @rdname NMsimResOperations
##' @export
dimnames.NMsimRes <- function(x,...){
  unNMsimRes(x)
  dimnames(x,...)
}

##' @rdname NMsimResOperations
##' @export
rbind.NMsimRes <- function(x,...){

  use.meta <- FALSE
  metas <- try(lapply(c(list(x),list(...)),function(y)attributes(y)$meta),silent=TRUE)
  if(!inherits(metas,"try-error")) {
    meta <- NULL
    
    if(any(!sapply(metas,is.null))){
      ## meta <- lapply(metas,rbindlist,fill=TRUE)
      meta <- do.call(rbind,metas)
    }
    if(!inherits(meta,"try-error") && !is.null(meta) ) {
      use.meta <- TRUE
    }
  }

  if(!use.meta){
    
    list.ModTab <- lapply(c(list(x),list(...)),modTab)
    ## list.ModTab <- list.ModTab[!sapply(list.ModTab,is.null)]
    ## ModTab <- rbindlist(list.ModTab,fill=TRUE)
    ModTab <- do.call(rbind, c(list.ModTab))
  }



  ### solution 1
  ## unNMsimRes(x)
  x <- as.data.table(x)
  ## lapply(c(x,list(...)),unNMsimRes)
  res <- rbind(x,...)
  
  ## args.res.list <- c(x,list(...))
  ## args.res.list <- args.res.list[!sapply(args.res.list,is.null)]
  ## res <- do.call(rbind,args.res.list)
  ### solution 2
  ## res <- data.table:::rbind.data.table(x,...)
  addClass(res,"NMsimRes")

  
  if(use.meta){
    setattr(res,"meta",meta)
  } else {
    setattr(res,"NMsimModTab",ModTab)
  }

  res
}

##' @rdname NMsimResOperations
##' @export
cbind.NMsimRes <- function(x,...){
  unNMsimRes(x)
  cbind(x,...)
}

##' @keywords internal
setNMsimRes <- function(res,models,digests){
  ## meta <- list(models=models,digests=digests)
  addClass(models,"NMsimModTab")
  meta <- as.NMsimResMeta(models=models,digests=digests)
  addClass(res,"NMsimRes")
  setattr(res,"meta",meta)
  invisible(res)
}


is.NMsimResMeta <- function(meta){
  inherits(meta,"NMsimResMeta")
}

##' @keywords internal
as.NMsimResMeta <- function(meta,models,digests){
  
  if(xor(missing(models),missing(digests))) {stop("use either meta of both of models and digests.")}

  if(!missing(meta)){
    if(!is.list(meta)&&!is.NMsimResMeta(meta)){
      stop("meta must be a NMsimResMeta object or at list a compatible list.")
    }
    if(!is.NMsimResMeta(meta)){
      if(!"models"%in%names(meta)){
        stop("meta must contain an element called models") 
      }
      addClass(meta,"NMsimResMeta")
      return(meta)
    }
  }

  if(missing(models)) stop("meta or models must be provided")
  if(missing(digests)) digests <- NULL

  addClass(models,"NMsimModTab")
  meta <- list(models=models,digests=digests)
  
  addClass(meta,"NMsimResMeta")
  meta
}


##' @rdname NMsimResOperations
##' @export
rbind.NMsimResMeta <- function(x,...){
  list.all <- c(list(x),list(...))

  list.all <- list.all[!sapply(list.all,is.null)]

  if(length(list.all)==1){
    res <- list.all[[1]]
    addClass(res,"NMsimResMeta")
    return(res)
  }
  
  allnames <- unique(unlist(lapply(list.all, names)))

  res <- setNames(
    lapply(allnames, function(nm) {
      ## rbindlist(lapply(list.all, `[[`, nm), use.names = TRUE, fill = TRUE)
      do.call(rbind, lapply(list.all, `[[`, nm))
      ## do.call(rbind, c(lapply(list.all, `[[`, nm),list(fill=TRUE)))
    }),
    allnames
  )
  addClass(res,"NMsimResMeta")

  res
}

saveNMsimMeta <- function(simres,file){
  if(!is.NMsimRes(simres)) stop("simres is not a NMsimRes object. Can't save metadata")
  meta <- attributes(simres)$meta
  saveRDS(meta,file)
}


