##' Execute Nonmem and archive input data with model files
##'
##' Execute Nonmem from within R - optionally but by default in
##' parallel. Archiving the input data ensures that postprocessing can
##' still be reproduced if the input data files should be updated.
##' 
##' @param files File paths to the models (control streams) to run
##'     nonmem on. See file.pattern too.
##' @param file.pattern Alternatively to files, you can supply a
##'     regular expression which will be passed to list.files as the
##'     pattern argument. If this is used, use dir argument as
##'     well. Also see data.file to only process models that use a
##'     specific data file.
##' @param dir If file.pattern is used, dir is the directory to search
##'     for control streams in.
##' @param path.nonmem The path to the nonmem executable. Only used if
##'     \code{method.execute="direct"} or
##'     \code{method.execute="nmsim"} (which is not default). If this
##'     argument is not supplied, NMexec will try to run nmfe75,
##'     i.e. this has to be available in the path of the underlying
##'     shell. The default value can be modified using
##'     \code{NMdata::NMdataConf}, like
##'     \code{NMdataConf(path.nonmem="/path/to/nonmem")}
##' @param sge Use the sge queing system. Default is TRUE. Disable for
##'     quick models not to wait for the queue to run the job.
##' @param nc Number of cores to use if sending to the cluster. This
##'     will only be used if \code{method.execute="psn"}, and
##'     \code{sge=TRUE}. Default is 64.
##' @param dir.data The directory in which the data file is
##'     stored. This is normally not needed as data will be found
##'     using the path in the control stream. This argument may be
##'     removed in the future since it should not be needed.
##' @param wait Wait for process to finish before making R console
##'     available again? This is useful if calling NMexec from a
##'     function that needs to wait for the output of the Nonmem run
##'     to be available for further processing.
##' @param input.archive A function of the model file path to generate
##'     the path in which to archive the input data as RDS. Set to
##'     FALSE not to archive the data.
##' @param nmfe.options additional options that will be passed to
##'     nmfe. It is only used when path.nonmem is available (directly
##'     or using `NMdataConf()`). Default is "-maxlim=2" For PSN, see
##'     `args.psn.execute`.
##' @param args.psn.execute A character string with arguments passed
##'     to execute. Default is
##'     "-model_dir_name -nm_output=coi,cor,cov,ext,phi,shk,xml".
##' @param update.only Only run model(s) if control stream or data
##'     updated since last run?
##' @param nmquiet Suppress terminal output from `Nonmem`. This is
##'     likely to only work on linux/unix systems.
##' @param method.execute How to run Nonmem. Must be one of 'psn',
##'     'nmsim', or 'direct'. 
##' \itemize{
##'
##' \item psn PSN's execute is used. This supports parallel Nonmem
##' runs. Use the \code{nc} argument to control how many cores to use
##' for each job. For estimation runs, this is most likely the better
##' choice, if you have PSN installed. See \code{dir.psn} argument
##' too.
##'
##' \item nmsim Creates a temporary directory and runs Nonmem
##' inside that directory before copying relevant results files back
##' to the folder where the input control stream was. If
##' \code{sge=TRUE}, the job will be submitted to a cluster, but
##' parallel execution of the job itself is not supported. See
##' \code{path.nonmem} argument too.
##' 
##' \item direct Nonmem is called directly on the control stream. This
##' is the simplest method and is the least convenient in most
##' cases. It does not offer parallel runs and leaves all the Nonmem
##' output files next to the control streams.
##' 
##'
##' }
##'
##' See `sge` as well.
##' 
##' @param clean The degree of cleaning (file removal) to do after
##'     Nonmem execution. If `method.execute=="psn"`, this is passed
##'     to PSN's `execute`. If `method.execute=="nmsim"` a similar
##'     behavior is applied, even though not as granular. NMsim's
##'     internal method only distinguishes between 0 (no cleaning),
##'     any integer 1-4 (default, quite a bit of cleaning) and 5
##'     (remove temporary dir completely).
##' @param fun.post A function of the path to the control stream
##'     (`file.mod`) that generates bash code to be evaluated once
##'     Nonmem is done. This can be used to automatically run a
##'     goodness-of-fit script or a simulation script after model
##'     estimation.
##' @param dir.psn The directory in which to find PSN
##'     executables. This is only needed if these are not searchable
##'     in the system path, or if the user should want to be explicit
##'     about where to find them (i.e. want to use a specific
##'     installed version of PSN).
##' @param files.needed In case method.execute="nmsim", this argument
##'     specifies files to be copied into the temporary directory
##'     before Nonmem is run. Input control stream and simulation
##'     input data does not need to be specified.
##' @param system.type A charachter string, either \"windows\" or
##'     \"linux\" - case insensitive. Windows is only experimentally
##'     supported. Default is to use \code{Sys.info()[["sysname"]]}.
##' @param backup Before running, should existing results files be
##'     backed up in a sub directory? If not, the files will be
##'     deleted before running.
##' @param quiet Suppress messages on what NMexec is doing? Default is
##'     FALSE.
##' @details Use this to read the archived input data when retrieving
##'     the nonmem results:
##'     \code{NMdataConf(file.data=inputArchiveDefault)}
##'
##' Since `NMexec` will typically not be used for simulations directly
##' (`NMsim` is the natural interface for that purpose), the default
##' method for `NMexec` is currently to use `method.execute="psn"`
##' which is at this point the only of the methods that allow for
##' multi-core execution of a single Nonmem job (NB:
##' `method.execute="NMsim"` can run multiple jobs in parallel which
##' is normally sufficient for simulations).
##' 
##' @return NULL (invisibly)
##' @import NMdata
##' @importFrom utils packageVersion
##' @importFrom R.utils getAbsolutePath
##' @examples
##' file.mod <- "run001.mod"
##' \dontrun{
##' ## run locally - not on cluster
##' NMexec(file.mod,sge=FALSE)
##' ## run on cluster with 16 cores. 64 cores is default
##' NMexec(file.mod,nc=16)
##' ## submit multiple models to cluster
##' multiple.models <- c("run001.mod","run002.mod")
##' NMexec(multiple.models,nc=16)
##' ## run all models called run001.mod - run099.mod if updated. 64 cores to each.
##' NMexec(file.pattern="run0..\\.mod",dir="models",nc=16,update.only=TRUE)
##' }
##' @export


NMexec <- function(files,file.pattern,dir,sge=TRUE,input.archive,
                   nc,dir.data=NULL,wait=FALSE, path.nonmem,
                   update.only=FALSE,
                   fun.post,
                   method.execute,
                   nmfe.options,
                   dir.psn,args.psn.execute,
                   files.needed,clean=1,backup=TRUE,quiet=FALSE
                  ,nmquiet=FALSE
                  ,system.type){
    
    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    dir.tmp <- NULL
    nid <- NULL
    input <- NULL
    result <- NULL
    string.cmd <- NULL
    name <- NULL
    
### Section end: Dummy variables, only not to get NOTE's in pacakge checks

    if(missing(dir.psn)) dir.psn <- NULL
    if(missing(path.nonmem)) path.nonmem <- NULL
    if(missing(method.execute)) method.execute <- NULL
    if(missing(system.type)) system.type <- NULL
    if(missing(files.needed)) files.needed <- NULL
    
    NMsimConf <- NMsimTestConf(path.nonmem=path.nonmem,method.execute=method.execute,system.type=system.type,must.work=TRUE)
    ## todo integrate in NMsimTestConf

    cmd.execute <- file.psn(NMsimConf$dir.psn,"execute")


    ## system.type <- getSystemType(system.type)


    if(missing(input.archive)||is.null(input.archive)){
        input.archive <- inputArchiveDefault
    }    
    if(isFALSE(input.archive)){
        input.archive <- function(file) FALSE
    }

    if(missing(nc)) nc <- NULL
    nc <- NMdata:::NMdataDecideOption("nc",nc,allow.unknown = TRUE)
    ## not needed with NMdata 0.1.6 or 0.1.7
    if(is.null(nc)) nc <- 64
    

    if(missing(fun.post)) fun.post <- NULL

    ## nmfe.options
    if(missing(nmfe.options)) nmfe.options <- NULL
    nmfe.options <- simpleCharArg("nmfe.options"
                                     ,nmfe.options
                                     ,default="-maxlim=2"
                                     ,accepted=NULL
                                     ,clean=FALSE
                                     ,lower=FALSE)
    
    ## args.psn.execute
    if(missing(args.psn.execute)) args.psn.execute <- NULL
    args.psn.execute <- simpleCharArg("args.psn.execute"
                                     ,args.psn.execute
                                     ,default=sprintf("-clean=%s -model_dir_name -nm_output=coi,cor,cov,ext,phi,shk,xml -nmfe_options=\"-maxlim=2\"",clean)
                                     ,accepted=NULL
                                     ,clean=FALSE
                                     ,lower=FALSE)
    if(!is.null(files.needed)){
        
        args.psn.execute  <- paste0(args.psn.execute," -extra_files=",paste(basename(files.needed),collapse=","))
    }

    if(missing(files)) files <- NULL
    if(missing(dir)) dir <- NULL
    dir <- simpleCharArg("dir"
                        ,dir
                        ,default=NULL
                        ,accepted=NULL
                        ,clean=FALSE
                        ,lower=FALSE)


    if(missing(file.pattern)) file.pattern <- NULL
    file.pattern <- simpleCharArg("file.pattern"
                                 ,file.pattern
                                 ,default=NULL
                                 ,accepted=NULL
                                 ,clean=FALSE
                                 ,lower=FALSE)


    if(is.null(files) && is.null(file.pattern)) file.pattern <- ".+\\.mod$"
    files.all <- NMdata:::getFilePaths(files=files,file.pattern=file.pattern,dir=dir,quiet=TRUE)
    
    files.exec <- files.all
    if(update.only){
        ## files.exec <- findUpdated(fnExtension(files.all,"lst"))
        files.exec <- findUpdated(files.all)
        if(length(files.exec)>0){
            message(length(files.exec)," model(s) to be executed:\n",paste(files.exec,collapse=",\n"),"\n")
        }
    }
    if(length(files.exec)<1){
        message("No models to run. Exiting.")
        return(invisible())
    }
    
    list.obj.exec <- 
        lapply(1:length(files.exec),function(I){
            file.mod <- NMdata:::filePathSimple(files.exec[I])
            if(!quiet) message(paste0("Executing ",file.mod))
            if(!file.exists(file.mod)){
                stop(paste("Could not find file:",file.mod))
            }

            
            ## replace extension of fn.input based on path.input - prefer rds
            rundir <- dirname(file.mod)

            exts <- c("\\.cov","\\.cor","\\.coi","\\.ext","\\.lst",".*msf","\\.msfi","\\.msfo","\\.phi","_input\\.rds","\\.res","\\.shk","\\.xml")
            exts.string <- paste0("(",paste(exts,collapse="|"),")")

### backup previous results if any:
            
            files.found <- c(
                list.files(rundir,pattern=sprintf("%s%s",fnExtension(basename(file.mod),""),exts.string)),
                list.files(rundir,pattern=paste0("^(",paste(
                                                          NMscanTables(file.mod,meta.only=TRUE,as.fun="data.table")[,name]
                                                         ,collapse="|"),")$"))
            )
            ## make sure files.found does not contain input control stream or input data
            if(length(files.found)){
                if(backup){
                    dir.backup <- file.path(rundir,paste0("backup_",fnExtension(basename(file.mod),"")))
                    if(dir.exists(dir.backup)){
                        unlink(dir.backup,recursive=TRUE)
                    }
                    dir.create(dir.backup)
                    lapply(c(files.found),function(f) file.rename(
                                                          from=file.path(rundir,f),
                                                          to=file.path(dir.backup,f)
                                                      ))
                    file.copy(file.mod,dir.backup)
                } else {
                    lapply(file.path(rundir,files.found),unlink)
                }
            }
            
            if(!isFALSE(input.archive(file.mod))){
                fn.input <- input.archive(file.mod)

                ## copy input data
                dat.inp <- NMscanInput(file=file.mod,file.mod=file.mod,translate=FALSE,apply.filters = FALSE,file.data="extract",quiet=TRUE)
                saveRDS(dat.inp,file=file.path(rundir,basename(fn.input)))
            }


            ##if((sge && nc > 1)||(sge && NMsimConf$method.execute=="psn")){
            if( sge ){
                if(nc>1){
                    file.pnm <- file.path(rundir,fnExtension(basename(file.mod),"pnm"))
                    pnm <- NMgenPNM(nc=nc,file=file.pnm)
                    files.needed <- unique(c(files.needed,pnm) )
                } else {
                    ## for nc=1, the pnm file setup does not seem to work.
                    ## if(!quiet) message("sge is disabled because nc=1")
                    ## sge <- FALSE
                    pnm <- NULL
                }
            }
            
            if(NMsimConf$method.execute=="psn"){
                obj.exec <- list()
                obj.exec$dir.exec <- "(PSN)"
                obj.exec$mod.exec <- "(PSN)"
                obj.exec$path.script <- "(PSN)"
                obj.exec$cmd <- sprintf('cd "%s"; "%s" %s',rundir,cmd.execute ,args.psn.execute)
                ##}
                ## if(system.type=="windows"){
                ##     pas
                ## }
                if(sge){
                    obj.exec$cmd <- paste0(obj.exec$cmd," -run_on_sge")
                    if(nc>1){
                        obj.exec$cmd <- paste0(obj.exec$cmd," -sge_prepend_flags=\"-pe orte ",nc," -V\" -parafile=",basename(pnm)," -nodes=",nc)
                    }
                }
                obj.exec$cmd <- paste(obj.exec$cmd,basename(file.mod))
            }

            
            if(NMsimConf$method.execute=="nmsim"){
                
                obj.exec <- NMexecDirectory(file.mod,NMsimConf$path.nonmem,files.needed=files.needed,system.type=NMsimConf$system.type,dir.data=dir.data,clean=clean,sge,nc,pnm=pnm,fun.post=fun.post,nmfe.options=nmfe.options)
                ##obj.exec$dir <- dirname(obj.exec$cmd)

                if(NMsimConf$system.type=="linux"){
                    ## a patch. ~ does not get expanded by system(). But maybe this should be handled earlier, not sure.
                    obj.exec$dir.exec <- gsub("~", path.expand("~"), obj.exec$dir.exec, fixed = TRUE)
                    obj.exec$cmd <- sprintf("cd \"%s\"; \"./%s\"",obj.exec$dir.exec,basename(obj.exec$path.script))
                }
                if(NMsimConf$system.type=="windows"){
                    obj.exec$cmd <- sprintf("@echo off;@CD \"%s\" >nul;cmd /c \"%s\"",obj.exec$dir.exec,basename(obj.exec$path.script))
                }
            }
            
            if(NMsimConf$system.type=="windows"){
                
                ## contents.bat <- gsub(";","\n",string.cmd)
                ## cat(contents.bat,file=path.script)
                path.script <- file.path(dirname(file.mod),"NMsim_exec.bat")

                contents.bat <-
                    strsplit(obj.exec$cmd,split=";")[[1]]
                writeTextFile(contents.bat,file=path.script)

                ## Maybe better to use system(,ignore.stdout=TRUE)
                ## shell(shQuote(paste("call", path.script),type="cmd"),invisible=TRUE )
                
                path.script.win <- normalizePath(path.script, winslash = "\\", mustWork = TRUE)
                sysres <- system(paste("cmd /c", shQuote(path.script.win)),ignore.stdout=FALSE,intern=FALSE)
                ## sysres <- system2(paste("cmd /c", shQuote(path.script.win)))## ,ignore.stdout=FALSE,intern=FALSE)
                shell("echo. > CON",invisible=TRUE)
            }
            if(NMsimConf$system.type=="linux"){
                
                if(nmquiet) obj.exec$cmd <- paste(obj.exec$cmd, ">/dev/null 2>&1")
                if(!wait) obj.exec$cmd <- paste(obj.exec$cmd,"&")
                ## if(exists("dir.tmp") && !is.null(dir.tmp)) {          
                ##     writeTextFile(string.cmd,file.path(dir.tmp,"NMexec_command.txt"))
                ## }
                
                procres <- system(obj.exec$cmd,ignore.stdout=nmquiet)
                if(procres!=0) {##stop("Nonmem failed. Exiting.")
                    ##message("Nonmem failed. Exiting.")
                    if(sge){
                        reportFailedRun(file.path(dir.tmp,basename(fnExtension(file.mod,"lst"))))
                    }
                    stop("Nonmem failed. Exiting.")
                }
            }
            
            as.data.table(obj.exec)
        })
    
    dt.obj.exec <- rbindlist(list.obj.exec)

    return(invisible(dt.obj.exec))

}
