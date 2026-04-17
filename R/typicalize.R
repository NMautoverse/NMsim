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

  
  ######### SAME blocks must be properly handled by NMwriteInits()
  ## inits <- inits[SAME!=1]
  inits <- inits[sameblock==0]
  ## inits[par.type%in%section&SAME!=1,init:="0"]
  ## inits[par.type%in%section&SAME!=1,FIX:=1]
  

  if("blocksize"%in%colnames(inits)){
    inits[par.type%in%section&blocksize>1,init:=valc.0]
  }

  ######## What is the right way to handle OMEGAP, OMEGAPD, SIGMAP and SIGMAPD for typical? Could we simply drop them?

  names.sections.rm <- intersect(toupper(section),c("OMEGAP","OMEGAPD","SIGMAP","SIGMAPD"))
  if(length(names.sections.rm)){
    list.sections.rm <- lapply(names.sections.rm,function(x) "")
    names(list.sections.rm) <- names.sections.rm
    lines <- NMwriteSectionOne(lines=lines,list.sections = list.sections.rm, quiet=TRUE)

    inits <- inits[!par.type%in%names.sections.rm]
  }
  mod.new <- NMwriteInits(lines=lines,inits.tab=inits,update=FALSE)

  ## write to file if requested
  if(is.null(newfile)){
    return(mod.new)            
  }

  writeTextFile(lines=mod.new,file=newfile)

  return(file.sim)

}
