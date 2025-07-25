##' Versatile text extractor from Nonmem (input or output) control streams
##'
##' If you want to extract input sections like $PROBLEM, $DATA etc,
##' see NMreadSection. This function is more general and can be used to
##' extract eg result sections.
##'
##' @param file A file path to read from. Normally a .mod or .lst. See
##'     lines and text as well.
##' @param lines Text lines to process. This is an alternative to
##'     using the file and text arguments.
##' @param text Use this argument if the text to process is one long
##'     character string, and indicate the line separator with the
##'     linesep argument. Use only one of file, lines, and text.
##' @param section The name of section to extract. Examples: "INPUT",
##'     "PK", "TABLE", etc. It can also be result sections like
##'     "MINIMIZATION".
##' @param char.section The section denoted as a string compatible
##'     with regular expressions. "$" (remember to escape properly)
##'     for sections in .mod files, "0" for results in .lst files.
##' @param char.end A regular expression to capture the end of the
##'     section. The default is to look for the next occurrence of
##'     char.section.
##' @param return If "text", plain text lines are returned. If "idx",
##'     matching line numbers are returned. "text" is default.
##' @param keep.name Keep the section name in output (say, "$PROBLEM")
##'     Default is TRUE. It can only be FALSE, if return="text".
##' @param keep.comments Default is to keep comments. If FALSE, the
##'     will be removed.
##' @param keep.empty Keep empty lines in output? Default is
##'     FALSE. Notice, comments are removed before empty lines are
##'     handled if `keep.comments=TRUE`.
##' @param as.one If multiple hits, concatenate into one. This will
##'     most often be relevant with name="TABLE". If FALSE, a list
##'     will be returned, each element representing a table. Default
##'     is TRUE. So if you want to process the tables separately, you
##'     probably want FALSE here.
##' @param simplify If asOne=FALSE, do you want the result to be
##'     simplified if only one table is found? Default is TRUE which
##'     is desirable for interactive analysis. For programming, you
##'     probably want FALSE.
##' @param clean.spaces If TRUE, leading and trailing are removed, and
##'     multiplied succeeding white spaces are reduced to single white
##'     spaces.
##' @param match.exactly Default is to search for exact matches of
##'     `section`. If FALSE, only the first three characters are
##'     matched. E.G., this allows "ESTIMATION" to match "ESTIMATION"
##'     or "EST".
##' @param type Either mod, res or NULL. mod is for information that
##'     is given in .mod (.lst file can be used but results section is
##'     disregarded). If NULL, NA or empty string, everything is
##'     considered.
##' @param linesep If using the text argument, use linesep to indicate
##'     how lines should be separated.
##' @param keepComments Deprecated. See keep.comments.
##' @param keepEmpty Deprecated. See keep.empty.
##' @param keepName Deprecated. See keep.name.
##' @param asOne Deprecated. See as.one.
##' @return character vector with extracted lines.
##' @details This function is planned to get a more general name and
##'     then be called by NMreadSection.
##' @family Nonmem
##' @examples
##' library(NMdata)
##' NMreadSection(system.file("examples/nonmem/xgxr001.lst", package = "NMdata"),section="DATA")
##' @keywords internal


NMextractText <- function(file, lines, text, section, char.section,
                          char.end=char.section, return="text",
                          keep.empty=FALSE,keep.name=TRUE, keep.comments=TRUE,as.one=TRUE,
                          clean.spaces=FALSE, simplify=TRUE,
                          match.exactly=TRUE,
                          type="mod", linesep="\n",
                          ## deprecated arguments
                          keepEmpty, keepName,
                          keepComments, asOne
                          ){

    cleanSpaces <- NMdata:::cleanSpaces
    getArgs <- NMdata:::getArgs
    getLines <- NMdata:::getLines
    deprecatedArg <- NMdata:::deprecatedArg

    nsection <- NULL
    idx <- NULL
    
#### Section start: Pre-process arguments ####

    ## args <- getArgs()
    args <- getArgs(sys.call(),parent.frame())
    
### deprecated since 2023-06-14: keepEmpty, keepName, keepComments, asOne, cleanSpaces
    keep.empty <- deprecatedArg("keepEmpty","keep.empty",args=args)
    keep.name <- deprecatedArg("keepName","keep.name",args=args)
    keep.comments <- deprecatedArg("keepComments","keep.comments",args=args)
    as.one <- deprecatedArg("asOne","as.one",args=args)
    ## clean.spaces <- deprecatedArg("cleanSpaces","clean.spaces",args=args)

    if(!return%in%c("idx","text")) stop("text must be one of text or idx.")

    if(!missing(text) && !is.null(text)){
        stop("text argument is deprecated. Use lines.")
    }

    lines <- getLines(file=file,lines=lines)
    
    ## if(sum(c(!missing(file)&&!is.null(file),
    ##          !missing(lines)&&!is.null(lines),
    ##          !missing(text)&&!is.null(text)
    ##          ))!=1) stop("Exactly one of file, lines, or text must be supplied")


    ## works with both .mod and .lst
    if(length(type)>1) stop("type must be a single-element character.")
    if(is.null(type)||is.na(type)||grepl("^ *$",type)){
        type <- "all"
    }
    if(type=="lst") type <- "res"

    
    if(!match.exactly && section!="."){
        section <- paste0(substring(section,1,min(nchar(section),3)),"[A-Z]*")
    }
    ## if(match.exactly && section!="."){
    ##     section <- paste0(section,"[^[A-Z]]*")
    ## }

    
### Section end: Pre-process arguments

    ## if(!missing(file)&&!is.null(file)) {
    ##     if(!file.exists(file)) stop("When using the file argument, file has to point to an existing file.")
    ##     lines <- readLines(file,warn=FALSE)
    ## }
    ## if(!missing(text)&&!is.null(text)) {
    ##     lines <- strsplit(text,split=linesep)[[1]]
    ## }
    

    ## This line can give problems because of possible special characters in company names or the registerred trademark character. We are not using it anyway.
    lines <- lines[!grepl("^ *License Registered to:",lines,useBytes=TRUE)]
    lines <- switch(type,
                    mod={
                        lines[1:(min(c(length(lines),grep("NM-TRAN MESSAGES|WARNINGS AND ERRORS \\(IF ANY\\) FOR PROBLEM",lines)-1)))]
                    },
                    res={
                        idx.res.start <- min(grep("NM-TRAN MESSAGES|WARNINGS AND ERRORS \\(IF ANY\\) FOR PROBLEM",lines))
                        if(length(idx.res.start)==0) stop("type=res, but there are no results in the file/text to be analyzed.")
                        lines[idx.res.start:length(lines)]
                    },
                    all={lines}
                    )

    ## Find all the lines that start with the $section
    ## idx.starts <- grep(paste0("^ *",char.section,section," *"),lines)
    if(match.exactly){
        idx.starts <- (1:length(lines))[grepl(paste0("^ *",char.section,section,"[^A-Z]*"),lines) &
                                        !grepl(paste0("^ *",char.section,section,"[A-Z]+"),lines) ]
    } else {
        idx.starts <- (1:length(lines))[grepl(paste0("^ *",char.section,section,"[^A-Z]*"),lines)]
    }
    idx.ends <- grep(paste0("^ *",char.end),lines)

    ## get the sections
    idx.sections <- lapply(idx.starts,function(idx.st){
        idx.dollars.after <- idx.ends[idx.ends>idx.st]
        if(length(idx.dollars.after)==0) {
            idx.end <- length(lines)
        } else {
            idx.end <- min(idx.dollars.after)-1
        }
        idx.section <- idx.st:idx.end
    })
    ## result <- idx.sections
    
    if(length(idx.sections)==0) return(NULL)
    
    secs.list <- lapply(1:length(idx.sections),
                        function(I){data.table(nsection=I,idx=idx.sections[[I]],text=lines[idx.sections[[I]]])
                        })
    dt.res <- rbindlist(secs.list)
    
    
    if(!keep.comments){
#### dont drop a line from idx if there is a comment in it
        ## result <- lapply(result,function(x)
        ##     x[!grepl(" *;.*$",lines[x])]
        ##     )
        lines <- sub(pattern=" *;.*$",replacement="",x=lines)
        dt.res[,text:=sub(pattern=" *;.*$",replacement="",x=text)]
    }

    if(!keep.empty){
        ## result <- lapply(result,function(x)
        ##     x[!grepl("^ *$",lines[x])]
        ##     )
        dt.res <- dt.res[!grepl("^ *$",text)]
    }

    
    ## if(return=="text"){
    ##     result <- lapply(result,function(x)lines[x])
    ## }
    
    if(!keep.name){
        if(!return=="text") {
            stop("keepName can only be FALSE if return=='text'")
        }

        ## result <- lapply(result, function(x)sub(paste0("^ *\\$",section,"[a-zA-Z]*"),"",x))
        ##  "[a-zA-Z]*" is needed for abbrev section names. Like for SIMULATION in case of SIM.
        dt.res[,text:=sub(paste0("^ *\\$",section),"",text)]
    }


    if(clean.spaces){
        if(!return=="text") {
            stop("clean.spaces can only be TRUE if return=='text'")
        }
        ## result <- lapply(result,cleanSpaces)
        
        dt.res[,text:=cleanSpaces(text)]
    }

    if(!keep.empty){
        dt.res <- dt.res[!grepl("^ *$",text)]
    }

    
    
    if(as.one) {
        ## result <- do.call(c,result)
        dt.res[,nsection:=1]
    }

    ## if(simplify && length(result)==1) result <- result[[1]]

    if(return=="idx") res.from.dt <- lapply(split(dt.res,by="nsection"),function(x)x[,idx])
    if(return=="text") res.from.dt <- lapply(split(dt.res,by="nsection"),function(x)x[,text])

    if(simplify && dt.res[,uniqueN(nsection)==1]) res.from.dt <- res.from.dt[[1]]
    

    ## return (result)
    return (res.from.dt)
    
}
