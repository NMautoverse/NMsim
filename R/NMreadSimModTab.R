##' Read simulation results from rds objects and/or NMsimModTab objects
##' @inheritParams NMreadSim
##' @param progress Track progress? Default is `TRUE` if `quiet` is
##'     FALSE and more than one model is being simulated. The progress
##'     tracking is based on the number of models completed, not the
##'     status of the individual models.
##' @import data.table
##' @importFrom xfun relative_path
##' @keywords internal

NMreadSimModTab <- function(x,check.time=FALSE,dir.sims,wait=FALSE,skip.missing=FALSE,quiet=FALSE,progress,read.fst=NULL,fast.tables=NULL,carry.out=NULL,as.fun){
    
    
    ROWTMP <- NULL
    path.lst.read <- NULL
    path.rds.read <- NULL
    pathSimsFromRes <- NULL
    path.sim.lst <- NULL
    . <- NULL

    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)
    if(missing(progress)) progress <- NULL
    

    ## read all rds files to get everything into just one table.
    unwrapRDS <- function(x){
        path.rds.read <- NULL
        file.res.data <- NULL
        path.results.read <- NULL
        path.results <- NULL

        if(is.character(x)) {
            ##  an rds, read it, make sure its NMSimModels, check for fst,  and proceed with NMSimModels
            
            tab.paths.list <- lapply(x,function(file){
                tab.paths <- readRDS(file)
                if(!inherits(tab.paths,"NMsimModTab")) {
                    if(!is.data.frame(tab.paths)){
                        stop("The provided rds file does not contain a NMsimModTab object")
                    }
                    message("x is not a NMsimModTab object. This can be OK if it was generated using earlier versions of NMsim. However, you may need to provide `dir.sims` for this to work.")
                }
                
                tab.paths[,path.rds.read:=file]
#### path.results does not exist for all old versions. Move to ..One and make dependent on version?
                ## tab.paths[,path.results.read:=file.path(dirname(file),basename(path.results))]
            })

            tab.paths <- rbindlist(tab.paths.list,fill=TRUE)
            ## tab.paths[,file.res.data:=fnAppend(fnExtension(x,"fst"),"res")]

            
        } else if(is.NMsimModTab(x)){
            ## a NMSimModels already, go to procecssing that
            tab.paths <- x
        } else {
            stop("x is not recognized as an NMsimModTab object")
        }
        tab.paths
    }

    res.list <- lapply(x,unwrapRDS)
    modtab <- rbindlist(res.list,fill=TRUE)
    
    ## add in usable path to sim results. This has to be dir.sims followed by the path to the resulting lst, relative to dir.sims. dir.sims is an argument to this function.
    modtab[,ROWTMP:=.I]
    modtab[,path.lst.read:={
        
        if(is.null(dir.sims)){
            dirSims <- file.path(dirname(path.rds.read),pathSimsFromRes)
        } else {
            dirSims <- dir.sims           
        }
        
        
        simplePath(
            file.path(dirSims,
#### issue: path.sim.lst contains the simtmp dir name first. dirSims also ends in that name. This fix goes one level up between the two, but this may fail if file.path(dirSims,"..") does not exist.

###this does not work when dirSims is not a direct subfolder to getwd()
                      ## relative_path(path.sim.lst,dirSims)
                      
                      relative_path(path.sim.lst,dirSims)

                      ## relative_path(
                      ##     simplePath(file.path(dirSims,"..",path.sim.lst))
                      ##    ,
                      ##     dir=simplePath(dirSims)
                      ## )
                      )
        )
    },
    ## by=.(ROWMODEL2)
    by=.(ROWTMP)
    ]
    
    
    modtab[,ROWTMP:=NULL]
    
### rather than reading one rds at a time, we should read all the
### rds's, stack them, and then read the object as
### one. NMreadSimModTabOne checks that there is only one rds but I'm
### sure that requirement is needed anymore. Could try to combine
### these and run at once. Would require more testing.
    
    res.list <- lapply(split(modtab,by="path.rds.read"),NMreadSimModTabOne,check.time=check.time,dir.sims=dir.sims,wait=wait,skip.missing=skip.missing,quiet=quiet,fast.tables=fast.tables,read.fst=read.fst,carry.out=carry.out,as.fun=as.fun,progress=progress)
    
    
    res <- rbindlist(res.list,fill=TRUE)

    list.ModTab <- lapply(res.list,function(y)attributes(y)$NMsimModTab)
    ModTab <- rbindlist(list.ModTab,fill=TRUE)

    addClass(res,"NMsimRes")
    setattr(res,"NMsimModTab",ModTab)

    res

}

##' Read simulation results from an rds or a NMsimModTab object
##' @inheritParams NMreadSim
##' @keywords internal
##' @import utils
NMreadSimModTabOne <- function(modtab,check.time=FALSE,dir.sims,wait=FALSE,quiet=FALSE,skip.missing=FALSE,progress,read.fst=NULL,fast.tables=NULL,carry.out=NULL,as.fun){
    
    . <- NULL
    args.NMscanData <- NULL
    col.row <- NULL
    file.res.data <- NULL
    funs.transform <- NULL
    NMsimVersion <- NULL
    path.rds.read <- NULL
    path.sim <- NULL
    path.results <- NULL
    path.results.read <- NULL
    path.lst.read <- NULL
    IPRED <- NULL
    PRED <- NULL
    ROWMODEL <- NULL
    ROWMODEL2 <- NULL
    ROWTMP <- NULL
    simres <- NULL
    variable <- NULL
    
    if(missing(progress)) progress <- NULL
    if(is.null(progress)) progress <- TRUE
    ## Previous versions did not save path.results, so 

    arg.fast.tables <- fast.tables
    arg.carry.out <- carry.out
    

    
    if(!"path.results"%in%colnames(modtab)){
        if(! "NMsimVersion"%in%colnames(modtab) || !"file.res.data" %in% colnames(modtab)){
            modtab[,path.results:=fnExtension(fnAppend(path.rds.read,"res"),"fst")]
        } else {
            modtab[NMsimVersion<="0.1.0.941",path.results:=file.res.data]
        }
    }
    
### Assuming that rds and fst are next to each other
    modtab[,path.results.read:=file.path(dirname(path.rds.read),basename(path.results))]
    
    rdstab <- unique(modtab[,.(path.results.read
                              ,path.rds.read)])
    if(nrow(rdstab)>1) stop("modtab must be related to only one rds file.")
    
####### Now we have a NMSimModels object to process.
    
### will need a function to apply transformations if applicable
    wrap.trans <- function(dt,...){
        
        funs <- list(...)
        for(name.fun in names(funs)){
            dt[,(name.fun):=funs[[name.fun]](get(name.fun))]
        }
        dt
    }

### read all sim results

####  must read each model into list elements. Then rbind(fill=T)
### this is to make sure results from different models with
### incompatible columns can be combined.
    
    
    
### if we have an fst, read it and return results
    if(is.null(read.fst)){
        if(check.time){
            read.fst <- rdstab[,!is.null(path.results.read) &&
                                file.exists(path.results.read) &&
                                file.mtime(path.results.read)>file.mtime(path.rds.read)
                               ]
        } else {
            read.fst <- rdstab[,!is.null(path.results.read) &&
                                file.exists(path.results.read)]
        }
    }

    
    ## fsts
    if(read.fst){
### reads unique fsts
        res.list <- lapply(modtab[,unique(path.results.read)],read_fst,as.data.table=TRUE)
        res <- rbindlist(res.list,fill=TRUE)

        setattr(res,"NMsimModTab",modtab)
        addClass(res,"NMsimRes")
        return(res)
        
    }
    
    lsts.found <- modtab[,file.exists(path.lst.read)]
    done <- all(lsts.found)

    if(!done){
        if(wait){
            turns <- 0
            if(!done) message("* Waiting for Nonmem to finish")
            
            ## progress tracker
            n.lsts <- modtab[,.N]
            do.pb <- !quiet && progress && n.lsts>1
            if(do.pb){
                ## set up progress bar
                n.done <- sum(file.exists(modtab[,path.lst.read]))
                pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                                     max = n.lsts, # Maximum value of the progress bar
                                     initial = n.done,
                                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                                     ## width = 50,   # Progress bar width. Defaults to getOption("width")
                                     char = "=")
            }

            
            while(!done){
                Sys.sleep(5)
                n.done <- sum(file.exists(modtab[,path.lst.read]))
                done <- n.done==n.lsts
                turns <- turns+1

                if(do.pb){
                    setTxtProgressBar(pb, n.done)
                }
                
            }
            ## if(turns>0) message("Nonmem finished.")
            if(do.pb){
                close(pb)
                ## message("")
            }
            lsts.found <- modtab[,file.exists(path.lst.read)]
            done <- all(lsts.found)            
        } else {
            if(skip.missing){
                message(sprintf("%d/%d model runs found",sum(lsts.found),length(lsts.found)))
            } else {
                lapply(modtab[!file.exists(path.lst.read),path.lst.read],function(x) message(sprintf("Not found: %s",x)))
                stop("Not all model runs completed. Look in messages for which ones. If you want to go ahead and read the ones that are found, use skip.missing=`TRUE`.")
            }
        }
    }
    
    if(sum(lsts.found)==0) {
        message("No results found")
        return(NULL)
    }
    if(skip.missing){
        modtab <- modtab[file.exists(path.lst.read)]
    }
    ## if(!quiet) message("Reading Nonmem results")
    
    if("ROWMODEL2" %in%colnames(modtab)) modtab[,ROWMODEL:=.GRP,by=.(ROWMODEL,ROWMODEL2)]
    tab.split <- split(modtab,by="ROWMODEL")
    nsplits <- length(tab.split)

    if(!quiet) message("* Collecting Nonmem results")
    do.pb <- do.pb <- !quiet && progress && nsplits>1
    if(do.pb){
        ## progress tracker
        pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                             max = nsplits, # Maximum value of the progress bar
                             ##initial = n.done,
                             style = 3,    # Progress bar style (also available style = 1 and style = 2)
                             ## width = 50,   # Progress bar width. Defaults to getOption("width")
                             char = "=")
    }

    
### this is needed for nc>1
    ## Sys.sleep(5)

    
    if(is.null(arg.fast.tables)) arg.fast.tables <- FALSE
    res.list <- lapply(1:nsplits,function(count){
        
        dat <- tab.split[[count]]
        bycols <- intersect(c("ROWMODEL","name.sim","model","model.sim"),colnames(dat))
        res <- dat[,{
            
            ## the rds table must keep NMscanData arguments
            args.NM <- args.NMscanData[[1]]
            if( "file.mod" %in% names(args.NM)){
                
                stop("Do not use file.mod in args.NMscanData. NMsim created the simulation control streams so as a user you do not need to help NMsim find them.")
            }
            ## 
            ## args.NM$file.mod <- function(file) fnExtension(file,".mod")
            args.NM$file.mod <- .SD$path.sim
            args.NM$as.fun <- "data.table"
            ## args.NM$file.mod <- fnExtension(path.lst.read,".mod")
            
            if(! "quiet" %in% names(args.NM)){
                args.NM$quiet <- TRUE
            }
            if( !is.null(.SD$col.row)){
                args.NM$col.row <- .SD$col.row
            }
            use.carry.out <- .SD$carry.out
            if(!is.null(arg.carry.out)) use.carry.out <- arg.carry.out
            use.carry.out <- unlist(use.carry.out)
            
            if(arg.fast.tables || .SD$fast.tables){

####### TODO: NMreadTabFast must optionally take file and file.mod. We need to not be affected by NMdataConf()$file.mod
                
                this.res <- try(NMreadTabFast(path.lst.read,file.mod=path.sim,carry.out=use.carry.out,col.row=col.row))

            } else {
                ## put this in try and report better info if broken
                this.res <- try(
                    do.call(NMscanData,
                            c(list(file=path.lst.read),args.NM)
                            )
                   ,silent=TRUE)
            }
            if(inherits(this.res,"try-error")){
                if(!quiet) {
                    message()
                    message(sprintf("Results could not be read from %s\nPasting the bottom of output control stream.",path.lst.read))
                    reportFailedRun(lst=path.lst.read)
                }
                this.res <- NULL

            } else {

                if(!is.null(.SD$funs.transform)){
                    this.funs <- .SD[1,funs.transform][[1]]
                    if(!is.null(this.funs)){
                        
                        this.res <- do.call(wrap.trans,c(list(dt=this.res),this.funs))
                    }
                }
                
                ## we are not keeping col.row. Just used it to make sure to combine right.
                
                if(col.row%in%colnames(this.res)) this.res[,(col.row):=NULL]

            }
            
            this.res
        },by=bycols]

        if(do.pb){
            setTxtProgressBar(pb, count)
        }

        
        res
        
    })

    if(do.pb){
        close(pb)
    }
    
    res <- rbindlist(res.list,fill=TRUE)
    if("ROWMODEL"%in%colnames(res)){
        res[,ROWMODEL:=NULL]
    }
    if("ROWMODEL2"%in%colnames(res)){
        res[,ROWMODEL2:=NULL]
    }
    
    res <- NMorderColumns(res,first=cc(PRED,IPRED),as.fun="data.table",col.id="ID",col.time="TIME")
    setcolorder(res,c(setdiff(colnames(res),intersect(colnames(res),c("model.sim","model","name.sim"))),c("name.sim","model","model.sim")
                      ))

    res <- as.fun(res)
    setattr(res,"NMsimModTab",modtab)
    addClass(res,"NMsimRes")

### if no models ran successfully, res will be a zero-row data table. Should that be saved?
    if(!is.null(rdstab$path.results.read) ){
        if(nrow(res)>0){
            NMwriteData(res,
                        file=rdstab$path.results.read,
                        formats.write="fst",
                        genText=F,
                        quiet=TRUE)
            ## this message may confuse because the user may think this has not happened if they don't see the message. And the message will only appear the first time data is being read.
            ## message("Results have been efficiently stored in results folder.")
        } else {
            message("Results empty.")
        }
    }
    res


}
