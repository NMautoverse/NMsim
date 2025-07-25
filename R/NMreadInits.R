#### This file is a copy from NMdata - except NMreadInits is made
#### internal. And replaced NMdataDecideOption with NMdata:::NMdataDecideOption. Same for cleanSpaces and getLines. Must be deleted when NMsim requires NMdata 0.1.9.

##' Calculate number of elements for matrix specification
##' 
##' calculate number of elements in the diagonal and lower triangle of
##' a squared matrix, based on the length of the diagonal.
##'
##' @param diagSize The length of the diagonal. Same as number of rows
##'     or columns.
##' 
##' @return An integer
##' @keywords internal
## triagSize(1:5)
triagSize <- function(diagSize){
    ((diagSize^2)-diagSize)/2+diagSize
}


##' Row numbers of elements in a triangular representation of a symmetric matrix
##' @keywords internal
## itriag(3,istart=2)

itriag <- function(blocksize,istart=1,diag="lower"){
    if(diag!="lower") stop("only diag=lower supported")
    rep(1:blocksize,times=1:blocksize)+istart-1
}

##' Column numbers of elements in a triangular representation of a symmetric matrix
##' @keywords internal
## jtriag(3,istart=2)
jtriag <- function(blocksize,istart=1,diag="lower"){
    if(diag!="lower") stop("only diag=lower supported")
    unlist(lapply(1:blocksize,function(j) 1:j)) + istart-1
}



##' @keywords internal
##' @import data.table
classify_matches <- function(matches,patterns) {
    results <- list()
    

    use.pattern <- function(name){
        if(!name %in% names(patterns)){
            stop(paste("pattern called", name,"not found"))
        }
        paste0("^",patterns[[name]],"$")
    }



    ##pattern.singlenum <- "-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?"
    pattern.singlenum <- "-?(\\d+\\.\\d+|\\d+\\.|\\.\\d+|\\d+)([eE][+-]?\\d+)?"
    for (match in matches) {
        ## if (grepl("^BLOCK\\(\\d+\\)$",match)) {
        if (grepl(use.pattern("block"),match)) {
            ## Extract the number from BLOCK(N)
            if(grepl("\\( *(\\d+) *\\)",match)){
                number <- regmatches(match, regexec("BLOCK\\s*\\( *(\\d+) *\\)",match))[[1]][2]
            } else {
                number <- "1"
            }
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "BLOCK",
                                           value.elem = number
                                       )))
        } else if (grepl(use.pattern("fix"),match)) {
            ## For FIX or FIXED, value is 1
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "FIX",
                                           value.elem = "1"
                                       )))
        } else if (grepl(use.pattern("ll.init.ul"),match)) {
            ## Split (ll,init,ul)
            ## nums <- as.numeric(str_match_all(match, "-?\\d+(\\.\\d+)?")[[1]][, 1])
            nums <- ## as.numeric(
                ## stri_match_all_regex(match, pattern.singlenum)[[1]][, 1]
                regmatches(match, gregexpr(pattern.singlenum,match,perl=TRUE))[[1]]
            ## )
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "lower",
                                           value.elem = nums[1]
                                       )))
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "init",
                                           value.elem = nums[2]
                                       )))
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "upper",
                                           value.elem = nums[3]
                                       )))
        } else if (grepl( use.pattern("ll.init"),match)) {
                                        # Split (ll,init)
            ## nums <- as.numeric(str_match_all(match, "-?\\d+(\\.\\d+)?")[[1]][, 1])
            nums <- ## as.numeric(
                ## stri_match_all_regex(match, pattern.singlenum)[[1]][, 1]
                regmatches(match, gregexpr(pattern.singlenum,match,perl=TRUE))[[1]]
            ## )
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "lower",
                                           value.elem = nums[1]
                                       )))
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "init",
                                           value.elem = nums[2]
                                       )))
        } else if (grepl( use.pattern("(init)"),match)) {
                                        # Extract init from (init)
            ## nums <- as.numeric(str_match(match, "-?\\d+(\\.\\d+)?")[1, 1])
            nums <- ## as.numeric(
                ## stri_match_all_regex(match, pattern.singlenum)[[1]][1, 1]
                regmatches(match, gregexpr(pattern.singlenum,match,perl=TRUE))[[1]]
            ## )
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "init",
                                           value.elem = nums
                                       )))
        } else if (grepl( use.pattern("init"),match,perl=TRUE)) {
                                        # Standalone init
            ## nums <- as.numeric(match)
            nums <- match
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "init",
                                           value.elem = nums
                                       )))
        } else if (grepl( use.pattern("same"),match)) {
                                        # SAME
            nums <- match
            results <- append(results, list(list(
                                           string.elem = match,
                                           type.elem = "init",
                                           value.elem = nums
                                       )))
        }
    }
    
    return(rbindlist(results))
}

##' Assign i and j indexes based on parameter section text
##' @param res elements as detected by `NMreadInits()`
##' @import data.table
##' @keywords internal

count_ij <- function(res){

    elem <- NULL
    inblock <- NULL
    blocksize <- NULL
    iblock <- NULL
    i <- NULL
    j <- NULL
    parnum <- NULL
    parblock <- NULL
    type.elem <- NULL
    
    parcount <- 1
    icount <- 1
    dt.ij <- NULL
    while (parcount<=max(res[,parnum])){
        
        this.bsize <- 1

        if(res[parnum==parcount,unique(inblock)==TRUE]){
            ## assign i and j to all
            this.parblock <- res[parnum==parcount,unique(parblock)]
            this.res <- res[ parblock==this.parblock  & type.elem%in%c("init","lower","upper")]
            this.bsize <- this.res[,unique(blocksize)]

            this.dt.ij <- data.table(parnum=parcount+seq(0,triagSize(this.bsize)-1),
                                     i=itriag(this.bsize,istart=icount),
                                     j=jtriag(this.bsize,istart=icount))
            
        } else {
            ## res[parnum==parcount,i:=parcount]
            ## res[parnum==parcount,j:=parcount]
            this.dt.ij <- data.table(parnum=parcount,i=icount,j=icount)
            ## parcount <- parcount+1
        }

        dt.ij <- rbind(dt.ij,this.dt.ij)
        icount <- icount + this.bsize
        parcount <- parcount+triagSize(this.bsize)
    }

    
    res <- mergeCheck(res,dt.ij,by="parnum",all.x=TRUE,quiet=TRUE)

    if(any(res[,inblock])){
        res[inblock==TRUE,iblock:=min(i,na.rm=TRUE),by=parblock]
    }
    if(any(!res[,inblock])){
        res[inblock==FALSE,iblock:=i]
    }
    
    res[,c("lastblockmax","inblock"):=NULL]
    res
}


##' Tabulate information from parameter sections in control streams
##' @param file Path to a control stream. See `lines` too.
##' @param lines A control stream as text lines. Use this or `file`.
##' @param section The section to read. Typically, "theta", "omega",
##'     or "sigma". Default is those three.
##' @param return By default (when \code{return="pars"}, a parameter
##'     table with initial values, FIX, lower and upper bounds etc. In
##'     most cases, that is what is needed to derive information about
##'     parameter definitions. If \code{return="all"}, two additional
##'     tables are returned which can be used if the aim is to modify
##'     and write the resulting parameters to a control stream.
##' @param as.fun See ?NMscanData
##' @return A `data.frame` with parameter values. If `return="all"`, a
##'     list of three tables.
##' @import data.table
##' @keywords internal
NMreadInits <- function(file,lines,section,return="pars",as.fun) {

    getLines <- NMdata:::getLines
    NMdataDecideOption <- NMdata:::NMdataDecideOption
    cleanSpaces <- NMdata:::cleanSpaces

    . <- NULL
    blocksize <- NULL
    does.count <- NULL
    elblock <- NULL
    elem <- NULL
    elemnum <- NULL
    inblock <- NULL
    j <- NULL
    lastblockmax <- NULL
    linenum <- NULL
    parnum <- NULL
    parblock <- NULL
    par.type <- NULL
    string <- NULL
    text <- NULL
    text.after <- NULL
    text.before <- NULL
    text.clean <- NULL
    type.elem <- NULL
    value.elem <- NULL
    
    if(missing(section)) section <- NULL
    if(is.null(section)) {
        section <- cc("theta","omega","sigma")
    }
    
    return <- match.arg(return,choices=c("pars","all"))

    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdataDecideOption("as.fun",as.fun)

    section <- sub("\\$","",section)
    section <- cleanSpaces(section)
    section <- toupper(section)
    
    ## if(length(section)>1) stop("Only one section can be handled at a time.")
    ## We want to keep everything, even empty lines so we can keep track of line numbers
    ## lines <- NMreadSection(lines=lines,section=section,keep.empty=TRUE,keep.comments=TRUE)
    ## if(length(lines)==0) return(NULL)

    
    if(missing(lines)) lines <- NULL
    if(missing(file)) file <- NULL
### this is assuming there is only one file, or that lines contains only one control stream.
    lines <- getLines(file=file,lines=lines)
    
    section <- unique(section)
    if(!all(section%in%c("THETA","OMEGA","SIGMA"))) stop("section cannot be other than THETA, OMEGA and SIGMA.")


#### these are the patterns used to identfy the different types of elements in parameter sections. passed to classify_matches.
    patterns <- 
        c("block"="BLOCK\\s*(?:\\s*\\(\\d+\\s*\\))?",  # BLOCK(N)
          ## "ll.init.ul"="\\(\\s*-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*,\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*,\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*\\)", # (ll,init,ul)
          "ll.init.ul"="\\( *(\\s*-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*)*,\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*,( *\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*)*\\)", # (ll,init,ul)
          "ll.init"="\\( *(\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*)*,\\s*-?-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*\\)", # (ll,init)
          "(init)"="\\(\\s*-?(?:\\d+(\\.\\d+)?|(?:\\d+)?\\.\\d+)([eE][+-]?\\d+)?\\s*\\)",  # (init)
          "init" = "(?<!\\d)-?(\\d+\\.\\d+|\\d+\\.|\\.\\d+|\\d+)([eE][+-]?\\d+)?(?!\\.)",
          "fix"="\\bFIX(ED)?\\b",  # FIX(ED)
          "same"="SAME"
          )

    
    dt.lines <- rbindlist(
        lapply(section,function(sec){
            dt.l <- data.table(text=NMreadSection(lines=lines,section=sec,keep.empty=TRUE,keep.comments=TRUE))
            if(nrow(dt.l)==0) return(NULL)
            dt.l[
               ,linenum:=.I][
               ,par.type:=sec]
            dt.l
        })
       ,fill=TRUE
    )
    
    
    pattern <- paste(patterns,collapse="|")

    ## Preprocess to remove comments (everything after ";")
    dt.lines[grepl(";", text),text.after:=sub("^[^;]*;","",text)]
    dt.lines[grepl(pattern,text,perl=TRUE),text.before:=sub(paste0("(.*?)(?:",pattern,").*"),"\\1",text,perl=TRUE)]
    ## dt.lines[is.na(text.before),text.before:=""]

    dt.lines[,text.clean:=gsub( " *;.*", "",text)]
    dt.lines[,text.clean:=cleanSpaces(text.clean)]
    ## If inside parentheses, move FIX(ED) to after parentheses
    dt.lines[,text.clean:=gsub(
                  pattern = "\\(\\s*(-?\\d+(\\.\\d+)?(?:[eE][+-]?\\d+)?)\\s+FIX(?:ED)?\\s*\\)",
                  ## Replace with "init FIX"
                  replacement = "\\1 FIX",
                  x=text.clean)]

    getMatches <- function(dt.lines){
        ## Function to classify matches and insert NA where applicable
        text.clean <- NULL
        matches <- regmatches(dt.lines[,text.clean],gregexpr(pattern,dt.lines[,text.clean],perl=TRUE))
        
        matches.list <- lapply(seq_along(matches),function(I){
            match <- matches[[I]]
            if(length(match)==0) return(NULL)
            data.table(linenum=I,string=match)
        })
        dt.match <- rbindlist(matches.list)

        ## elemnum counts the findings. It is an arbitrary counter because it groups (ll,init,ul) together but not FIX. It really can't be used for anything beyond this function so should not be exported.
        dt.match[,elemnum:=.I]
        dt.match
    }


    
    dt.matches <- dt.lines[,getMatches(.SD),by=.(par.type)]
    
    res <- dt.matches[,classify_matches(string,patterns),by=.(par.type,linenum,elemnum)]

    ## count parameter number - init,ll,ul,FIX will all be assigned to one parameter number
    res.list <- split(res,by="par.type")
    res.list <- lapply(res.list,function(res){
        res[,parnum:=NA_integer_]
        this.parnum <- 0
        prev.type <- "init"
        for(r in 1:nrow(res)){
            this.type <- res[r,type.elem]
            if( this.type == "BLOCK" ||
                (this.type == "lower" && prev.type!="BLOCK" ) ||
                (this.type == "init" && !prev.type %in% c("BLOCK","lower")) ){
                this.parnum <- this.parnum + 1
            }
            res[r,parnum:=this.parnum]
            if(this.type!="FIX") {
                ## if this type is FIX the type relevant for
                ## classification hasn't changed from block, lower,
                ## etc.
                prev.type <- this.type
            }
        }
        

        res[type.elem=="BLOCK",parblock:=as.integer(parnum)]
        res[type.elem=="BLOCK",blocksize:=as.integer(value.elem)]
        res[type.elem=="BLOCK",lastblockmax:=triagSize(blocksize)+parnum-1]
        res[,lastblockmax:=nafill(lastblockmax,type="locf")]


        res[,inblock:=FALSE]
        res[parnum<=lastblockmax,inblock:=TRUE]
        res[inblock==TRUE,blocksize:=nafill(blocksize,type="locf")]
        res[inblock==FALSE,blocksize:=1]
        res[inblock==TRUE,parblock:=nafill(parblock,type="locf")]

        res <- count_ij(res)
        res[,parblock:=NULL]
        ##res[,par.type:=section]
        res[par.type=="THETA",j:=NA]
        res
    })

    res <- rbindlist(res.list)
    res <- addParameter(res)
    
    pars <- initsToExt(res)
    if(return=="pars") return(as.fun(pars))
    
    setcolorder(dt.lines,cc(par.type,linenum,text,text.clean,text.before,text.after))
    
    list(pars=as.fun(pars),
         lines=as.fun(dt.lines),
         elements=as.fun(res)
         )

}

##' Convert inits elements to a parameter data.frame
##' @param elements The elements object produced by `NMreadInits()`.
##' @import data.table
##' @keywords internal
##' @noRd
initsToExt <- function(elements){

#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    . <- NULL
    blocksize <- NULL
    FIX <- NULL
    iblock <- NULL
    init <- NULL
    init.num <- NULL
    i <- NULL
    j <- NULL
    lower <- NULL
    upper <- NULL
    par.type <- NULL
    parameter <- NULL
    par.name <- NULL
    type.elem <- NULL
    
### Section end: Dummy variables, only not to get NOTE's in pacakge checks
    
    pars <- dcast(elements[type.elem%in%cc(init,lower,upper,FIX)],par.type+i+j+iblock+blocksize~type.elem,value.var="value.elem")

###  init=SAME may not work for blocksizes>1
    if("init"%in%colnames(pars)){
        
        suppressWarnings(pars[,init.num:=as.numeric(init)])
        pars[!is.na(init.num)|init=="SAME",init.num:=nafill(init.num,type="locf")]
        pars[,init:=init.num]
        pars[,init.num:=NULL]
    } else {
        ## not sure this will ever happen
        pars[,init:=NA_real_]
    }
    if(!"FIX"%in% colnames(pars)) pars[,FIX:=0L]
    pars[,FIX:=as.integer(FIX)]
    pars[is.na(FIX),FIX:=0L]

    if(!"lower"%in% colnames(pars)) pars[,lower:=NA_real_]
    
    if(!"upper"%in% colnames(pars)) pars[,upper:=NA_real_]
    
    pars[par.type=="THETA",parameter:=paste0(par.type,i)]
    pars[par.type%in%c("OMEGA","SIGMA"),parameter:=sprintf("%s(%d,%d)",par.type,i,j)]
    pars[,par.name:=parameter]
    pars[par.type=="THETA",par.name:=sprintf("%s(%d)",par.type,i)]



    pars <- pars[,.(par.type,parameter,par.name,i,j,iblock,blocksize,init,lower,upper,FIX)]
    pars <- pars[order(match(par.type,c("THETA","OMEGA","SIGMA")),i,j)]
    
    pars[]
}
