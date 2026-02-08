
##sprintf("call %s %s %s",path.nonmem,fn.mod,fnExtension(fn.mod,".lst"))
NMrunWin <- function(fn.mod,dir.mod.abs,exts.cp,meta.tables,path.nonmem,clean,nmfe.options,fun.post=NULL){

#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    ##     path.nonmem <- FALSE
    name <- FALSE

### Section end: Dummy variables, only not to get NOTE's in pacakge checks

    cp.if.pres <- function(fn,dest){
        ##print(sprintf("IF EXIST \"%s\" COPY /Y \"%s\" \"%s\" ",fn,fn,dest))
        sprintf("IF EXIST \"%s\" COPY /Y \"%s\" \"%s\" >NUL",fn,fn,normalizePath(dest, winslash = "\\", mustWork = TRUE))
    }
    rm.if.pres <- function(fn){
        sprintf("IF EXIST \"%s\" DEL /s /q \"%s\" >nul",fn,fn)
    }

    lines.bat <- c("@echo off",
                   sprintf("call %s %s %s %s",
                           path.nonmem,fn.mod,fnExtension(fn.mod,".lst"),nmfe.options)
                  ,
                   paste(unlist(lapply(fnExtension(fn.mod,exts.cp),cp.if.pres,dest=dir.mod.abs)),collapse="\n")
                  ,
                   paste(unlist(lapply(meta.tables[,name],cp.if.pres,dest=dir.mod.abs)),collapse="\n")
                   )

### Cleaning
    if(clean>0 && clean<5){
        lines.bat <- c(lines.bat,
                       paste(unlist(lapply(cleaningPatterns(clean),
                                           rm.if.pres)),collapse="\n")
                       )
    }

    lines.bat <- c(lines.bat
                  ,"set \"oldwd=%cd%\""
                  ,"CD .. >nul")
    
    if(clean==5){

        lines.bat <- c(lines.bat
                       ##sprintf("CD .. & rd /s /q \"%s\"",dir.tmp)
                      ,"rd /s /q \"%oldwd%\" >nul"
                       )
    }

    if(!is.null(fun.post)){
        lines.bat <- c(lines.bat,
                       fun.post(file.path(dir.mod.abs,basename(fn.mod)))
                       )
    }
    ## restore redirection 
    lines.bat <- c(lines.bat,"echo. > CON")
    lines.bat
}

