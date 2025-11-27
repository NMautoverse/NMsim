##' Update file names in control stream to match model name
##' @param x a control stream, path or `NMctl` object.
##' @param section What section to update
##' @param model Model name
##' @param fnext The file name extension of the file name to be
##'     updated (e.g., one of "tab", "csv", "msf").
##' @param add.section.text Addditional text to insert right after
##'     $SECTION. It can be additional TABLE variables.
##' @param par.file The Nonmem parameter that specifies the file. In
##'     $TABLE, this is FILE. In $EST it's probably MSFO.
##' @param text.section This is used to overwrite the contents of the section. The section output file name will still handled/updated.
##' @param quiet Suppress messages? Default is `FALSE`.
##' @keywords internal

NMupdateFn <- function(x,section,model,fnext,add.section.text,par.file,text.section,quiet=FALSE){### Arguments to replace: FILE, .tab, text.table
    
    lines <- as.NMctl(x)
    
    if(missing(text.section)) text.section <- NULL
    if(missing(add.section.text)) add.section.text <- NULL
    run.sim <- fnExtension(basename(model),ext="")
    
    fn.tab.base <- paste0(par.file,"=",run.sim,fnext)
    ## lines.mod <- readLines(model)

    dollar.section <- toupper(section)
    dollar.section <- paste0("$",substr(dollar.section,1,3))    
    dollar.section.new <- dollar.section
    if(dollar.section.new=="EST") dollar.section.new <- "ESTIMATION"
    if(dollar.section.new=="SIM") dollar.section.new <- "SIMULATION"

    
    lines.section <- NMreadSection(lines=lines,section=section,as.one=FALSE,simplify=FALSE)
     if(is.null(lines.section)){
         if(!quiet){message("Section not found. Nothing done.")}
         return(lines)
     }

    if(is.null(text.section)){
       
        ## replace output table name
        if(length(lines.section)==0){
            stop(sprintf("No %s statements found in control stream.",section))
        } else if(length(lines.section)<2){
            ## notice, this must capture zero and 1.
            lines.section.new <- list(gsub(paste0(par.file," *= *[^ ]+"),replacement=fn.tab.base,lines.section[[1]]))
        } else {
            ## I don't remember the reason for the concern this may fail. It looks OK? I think it was supposed to be a check if text.section was a list, so the user is trying to create multiple tables. I don't know if that would work.
            ## message("Number of output tables is >1. Trying, but retrieving results may fail.")
            lines.section.new <- lapply(seq_along(lines.section),function(n){
                fn.tab <- fnAppend(fn.tab.base,n)
                gsub(paste0(par.file," *= *[^ ]+"),replacement=fn.tab,lines.section[[n]])
            })
        }
    } else {
        lines.section.new <- list(paste(dollar.section.new,text.section,fn.tab.base))
    }
    lines.section.new <- paste(unlist(lines.section.new),collapse="\n")
    if(!is.null(add.section.text)){
        lines.section.new <- gsub(paste0("\\",dollar.section,"[A-Z]*"),paste(dollar.section.new,add.section.text),lines.section.new,fixed=FALSE)
    }
    
    ## replace old section with the updated one
    NMdata:::NMwriteSectionOne(lines=lines,section=section,newlines=lines.section.new,quiet=TRUE)
    
}
