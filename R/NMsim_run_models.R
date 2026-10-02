##' Internal function to execute data frame with model specifications
##'
##' @param dt.models 
##' @return list with simulation results and updated dt.models
##' @author Philip Delff
##' @keywords internal

NMsim_run_models <- function(env){
  


  ## dir.sim.sub && sim.dir.from.scratch
  ##quiet
  ## method.update.inits
  ## inits
  ## data

  if(!nrow(dt.models)) return(list(simres=NULL,dt.models=NULL))
    
    ############### This should be internalized in NMexec     
    ### clear simulation directories so user does not end up with old results
    if(dir.sim.sub && sim.dir.from.scratch){
      dt.models[,if(dir.exists(dir.sim)) unlink(dir.sim,recursive=TRUE),by=.(ROWMODEL)]
    }
    dt.models[,if(file.exists(path.sim)) unlink(path.sim),by=.(ROWMODEL)]
    
    dt.models[,{if(!dir.exists(dir.sim)){
      dir.create(dir.sim)
    }
      if(!dir.exists(dir.data.sim)){
        dir.create(dir.data.sim)
      }   
    },by=.(ROWMODEL)
    ]

    ###### Messaging to user
    if(!quiet) {
      message(sprintf("Location(s) of intermediate files and Nonmem execution:\n%s",
                      dt.models[,paste(paste0("  ",simplePath(unique(dir.sim))),collapse="\n")]))
      message(sprintf("Location of final result files:\n%s\n",
                      dt.models[,paste(paste0("  ",simplePath(unique(dirname(path.rds)))),collapse="\n")]))
      ## It would be nice to say how many. But we dont know until after NMsim_method()
      ## message(sprintf("* Writing %d simulation control stream(s) and simulation data set(s)",dt.models[,.N]))
      message(sprintf("* Writing simulation control stream(s) and simulation data set(s)"))
    }
    
    ## It would not need to, but beware PSN's update_inits needs to
    ## create a new file - don't try to overwrite an existing one.
    if(method.update.inits=="none"){
      dt.models[,file.copy(file.mod,path.sim),by=ROWMODEL]
    }

    ##### todo all file.xyz arguments must be NULL or of equal length. And this should be done per model
    
    if(method.update.inits=="nmsim.deprec" && any(dt.models[,!file.exists(file.ext)])){
      stop(paste("ext file(s) not found. Did you forget to copy it? Normally, NMsim needs that file to find estimated parameter values. If you do not have an ext file and you are running a simulation that does not need it, please use `inits=list(method=\"none\")`. Was expecting to find ",paste(dt.models[!file.exists(file.ext),file.ext],collapse="\n"),sep=""))
    }

    if(method.update.inits=="nmsim" && inits$update && any(dt.models[,!file.exists(file.ext)])){
      stop(paste("ext file(s) not found. Did you forget to copy it? Normally, NMsim needs that file to find estimated parameter values. If you do not have an ext file and you are running a simulation that does not need it, please use `inits=list(method=\"none\")`. Was expecting to find ",paste(dt.models[!file.exists(file.ext),file.ext],collapse="\n"),sep=""))
    }
    
    if(method.update.inits=="psn"){
      ### this next line is done already. I think it should be removed but testing needed.
      cmd.update.inits <- file.psn(NMsimConf$dir.psn,"update_inits")

      dt.models[,
      {
        if(!file.exists(fnExtension(file.mod,"lst"))){
          
          stop("When using `inits=list(method=\"psn\")`, an output control stream with file name extensions .lst must be located next to the input control stream. Consider also the default `inits=list(method=\"nmsim\")`.")
        }
        cmd.update <- sprintf("%s --output_model=\"%s\" \"%s\"",normalizePath(cmd.update.inits,mustWork=FALSE),fn.sim.tmp,normalizePath(file.mod))
        ### would be better to write to another location than next to estimation model
        ## cmd.update <- sprintf("%s --output_model=%s %s",cmd.update.inits,file.path(".",fn.sim.tmp),file.mod)
        if(NMsimConf$system.type=="linux"){
          ## print(paste(cmd.update,"2>/dev/null"))
          
          sys.res <- system(paste(cmd.update,"2>/dev/null"),wait=TRUE)
          
          if(sys.res!=0){
            stop("update_inits failed. Please look into this. Is the output control stream available? Is it in a directory where you have write-access?")
          }
        }
        if(NMsimConf$system.type=="windows"){
          cmd.update <- sprintf("\"%s\" --output_model=\"%s\" \"%s\"",normalizePath(cmd.update.inits),fn.sim.tmp,normalizePath(file.mod))
          script.update.inits <- file.path(dirname(file.mod),"script_update_inits.bat")
          writeTextFile(cmd.update,script.update.inits)
          sys.res <- shell(shQuote("tmp.bat",type="cmd") )
        }
        
        file.rename(file.path(dirname(file.mod),fn.sim.tmp),path.sim)
      },by=ROWMODEL]
    }
    
    if(method.update.inits=="nmsim.deprec"){
      ## edits the simulation control stream in the
      ## background. dt.models not affected.
      ### because we use newfile, this will be printed to newfile. If not, it would just return a list of control stream lines.
      dt.models[,NMupdateInits(file.mod=file.mod,newfile=path.sim,file.ext=file.ext),by=.(ROWMODEL)]
    }

    if(method.update.inits=="nmsim"){
      ## edits the simulation control stream in the
      ## background. dt.models not affected.
      ### because we use newfile, this will be printed to newfile. If not, it would just return a list of control stream lines.

      ## dt.models[,NMwriteInits(file.mod=file.mod,newfile=path.sim,file.ext=file.ext,),by=.(ROWMODEL)]
      dt.models[,{
        
        args.inits <- append(
          list(file.mod=file.mod,newfile=path.sim,file.ext=file.ext)
         ,
          inits[setdiff(names(inits),"method")]
        )
        do.call(NMwriteInits,args.inits)
      },by=.(ROWMODEL)]
    }

    if(is.null(data)){
      ##add.var.table <- col.row
      args.NMscanData.default$merge.by.row <- TRUE
      ##args.NMscanData.default$col.row <- col.row
      rewrite.data.section <- FALSE
      order.columns <- FALSE
    }

    ###### write unique data sets
    if(!is.null(data)){

      if(is.character(carry.out)){
        
        not.found <- lapply(data$data,function(dat)carry.out[!carry.out%in% colnames(dat)]) 
        not.found <- unlist(not.found)
        not.found <- unique(not.found)
        if(length(not.found)){
          warning(paste0("Not all variables in `carry.out` found in (all) data set(s):\n",paste(not.found,collapse=" ")))
        }
      }
      
      dt.data.tmp <- unique(dt.models[,.(DATAROW,path.data)])
      dt.data.tmp[,tmprow:=.I]
      
      ### TODO set $SIZES PD if with>something

      ## NMwriteData is run in lapply because genText=T may return
      ## incompatible objects - do not run as dt[,NMwriteData(),by]
      null <- lapply(split(dt.data.tmp,by="tmprow"),function(datrow){
        with(datrow,NMwriteData(data$data[[DATAROW]]
                               ,file=path.data
                               ,genText=T
                               ,formats.write=c("csv",format.data.complete)
                                ## if NMsim is not controlling $DATA, we don't know what can be dropped.
                                
                               ,csv.trunc.as.nm=TRUE
                               ,script=script
                               ,quiet=TRUE)
             )})
      

    }
    


    if(is.null(data)){
      ###### VPC mode
      
      dt.models.split <- split(dt.models,by="file.mod")
      dt.split.res <- lapply(dt.models.split,function(dt){
        file.mod <- unique(dt$file.mod)
        
        ## reading with recover.cols. This does not affect what
        ## will be written to the $INPUT section which is still
        ## copied from the control stream, then edited to include
        ## the row identifier.
        data.this <- NMscanInput(file.mod,recover.cols=TRUE,translate=FALSE,apply.filters=FALSE,col.id=NULL,as.fun="data.table")
        col.row.this <- tmpcol(data.this,base="NMROW")

        dt[,col.row:=col.row.this]
        
        data.this[,(col.row.this):=(1:.N)]
        setcolorder(data.this,c(colnames(data.this)[1],col.row.this))
        
        section.input <- NMreadSection(file.mod,section="input",keep.name=FALSE)
        ## remove comments, so list can collapse the rows to one long row
        section.input <- sub(";.*","",section.input)
        ## collapse lines to one line
        section.input <- paste(section.input,collapse=" ")
        section.input <- gsub(","," ",section.input)
        ##section.input <- gsub("[ \\s]+"," ",section.input)
        section.input <- gsub("[[:space:]]+"," ",section.input)
        section.input <- NMdata:::cleanSpaces(section.input)
        section.input <- gsub(" *= *","=",section.input)
        ## Inject row counter in second position
        elems.input <- strsplit(section.input,split=" ")[[1]]
        elems.input <- c(elems.input[1],col.row.this,elems.input[-1])
        section.input <- paste("$INPUT",paste(elems.input,collapse=" "))
        
        
        ## save data and replace $input and $data
        
        nmtext <- NMwriteData(data.this,file=unique(dt$path.data),
                              args.NMgenText=list(dir.data=".",col.flagn=col.flagn)
                             ,formats.write=c("csv",format.data.complete)
                              ## if NMsim is not controlling $DATA, we don't know what can be dropped.
                             ,csv.trunc.as.nm=rewrite.data.section
                             ,script=script
                             ,quiet=TRUE)


        dt[,NMdata:::NMwriteSectionOne(file0=path.sim,list.sections = list(input=section.input),backup=FALSE,quiet=TRUE)]
        
        ## replace data file only
        dt[,NMreplaceDataFile(files=path.sim,path.data=basename(path.data),quiet=TRUE)]
        
        dt
      })
      dt.models <- rbindlist(dt.split.res)
      
    } else {
      dt.models[,col.row:=data$col.row]
      
      dt.models[,{
        data.this <- data$data[[DATAROW]]
        rewrite.data.section <- TRUE
        nmtext <- NMgenText(data.this,file=relative_path(path.data,dirname(path.sim)),
                            col.flagn=col.flagn,
                            quiet=TRUE)
        
        ## NMdata:::NMwriteSectionOne(file0=path.sim,list.sections = nmtext["INPUT"],
        ##                            backup=FALSE,quiet=TRUE)
        ## NMdata:::NMwriteSectionOne(file0=path.sim,list.sections = nmtext["DATA"],
        ##                            backup=FALSE,quiet=TRUE)    

        NMdata:::NMwriteSectionOne(file0=path.sim,list.sections = nmtext[c("INPUT","DATA")],
                                   backup=FALSE,quiet=TRUE)
        
        
      },by=.(ROWMODEL)]
    }    


    
    dt.models[,{### update .msf
      newlines <- NMupdateFn(x=path.sim,
                             section="EST",
                             model=basename(fn.sim),
                             fnext=".msf",
                             add.section.text=NULL,
                             par.file="MSFO",
                             text.section=NULL,
                             quiet=TRUE)
      writeTextFile(newlines,file=path.sim)
    },by=.(ROWMODEL)
    ]

    #### Section start: Output tables ####
    
    dt.models[,{
      
      fn.tab.base <- paste0("FILE=",model.sim,".tab")
      lines.sim <- readLines(path.sim,warn=FALSE)
      
      lines.tables <- NMreadSection(lines=lines.sim,section="TABLE",as.one=FALSE,simplify=FALSE)
      
      if(is.null(text.table)){
        ## replace output table name
        if(length(lines.tables)==0){
          stop("No TABLE statements found in control stream.")
        } else if(length(lines.tables)<2){
          ## notice, this must capture zero and 1.
          lines.tables.new <- list(gsub(paste0("FILE *= *[^ ]+"),replacement=fn.tab.base,lines.tables[[1]]))
        } else {
          ## I don't remember the reason for the concern this may fail. It looks OK? I think it was supposed to be a check if text.table was a list, so the user is trying to create multiple tables. I don't know if that would work.
          ## message("Number of output tables is >1. Trying, but retrieving results may fail.")
          lines.tables.new <- lapply(seq_along(lines.tables),function(n){
            fn.tab <- fnAppend(fn.tab.base,n)
            gsub(paste0("FILE *= *[^ ]+"),replacement=fn.tab,lines.tables[[n]])
          })
        }
      } else {
        lines.tables.new <- list(paste("$TABLE",text.table,fn.tab.base))
      }
      lines.tables.new <- paste(unlist(lines.tables.new),collapse="\n")
      ## if(exists("add.var.table")){
      ##     lines.tables.new <- gsub("\\$TABLE",paste("$TABLE",add.var.table),lines.tables.new)
      ## }
      lines.tables.new <- gsub("\\$TABLE",
                               sub(" +$","",paste("$TABLE",col.row,cols.table.add)),
                               lines.tables.new)
      ## if no $TABLE found already, just put it last
      if(length(lines.tables)){
        location <- "replace"
      } else {
        location <- "last"
      }
      
      lines.sim <- NMdata:::NMwriteSectionOne(lines=lines.sim,newlines=lines.tables.new,section="TABLE",backup=FALSE,location=location,quiet=TRUE)
      
      ### save file.sim
      writeTextFile(lines=lines.sim,file=path.sim)
    },by=.(ROWMODEL)]
    
    
    ###  Section end: Output tables
    #### DEBUG Does the sim control stream have TABLES at this point?    
    

    ## fun simulation method
    dt.models.gen <- dt.models[,
                               method.sim(file.sim=path.sim,file.mod=file.mod,data.sim=data$data[[DATAROW]],...)
                              ,by=.(ROWMODEL)]
    
    
    ## when methods return just a vector of path.sim, we need to reorganize
    if(ncol(dt.models.gen)==2 && all(colnames(dt.models.gen)%in%c("ROWMODEL","V1"))){
      setnames(dt.models.gen,"V1","path.sim")
    }

    all.files <- melt(dt.models.gen,id.vars="ROWMODEL")
    all.files[,f.exists:=file.exists(value),by=.(ROWMODEL)]
    if(any(!all.files$f.exists)){
      stop(paste("Not all required files exist. The following are missing:",paste(all.files[f.exists==FALSE,value],collapse=", ")))
    }

    ## we need the new path.sim and files.needed
    cnames.gen <- colnames(dt.models.gen)
    if(!"path.sim"%in%cnames.gen) stop("path.sim must be in returned data.table")


    ##### Moved to after reuse.results - before NMexec()
    ## if multiple models have been spawned, and files.needed has been generated, the only allowed method.execute is "nmsim"
    if(nrow(dt.models.gen)>1 && "files.needed"%in%colnames(dt.models.gen)){
      if(execute && NMsimConf$method.execute!="nmsim"){
        stop("Multiple simulation runs spawned, and they need additional files than the simulation input control streams. The only way this is supported is using method.execute=\"nmsim\".")
      }
    }

    if(sge && nc>1 && "files.needed"%in%colnames(dt.models.gen)){
      warning("This simulation uses auxiliary input data. This has been seen to create issues in combination with multi-core execution. If this fails, try using
`nc=1`.")
    }

    ## if multiple models spawned, direct is not allowed
    if(nrow(dt.models.gen)>1){
      if(execute && NMsimConf$method.execute=="direct"){
        stop("method.execute=\"direct\" cannot be used with simulation methods that spawn multiple simulation runs. Try method.execute=\"nmsim\" or method.execute=\"psn\".")
      }
    }
    

    ## if files.needed, psn execute cannot be used.
    if("files.needed"%in%colnames(dt.models.gen)){
      if(execute && NMsimConf$method.execute=="psn"){
        warning("method.execute=\"psn\" currently has issues with simulation methods that need additional files to run - and this one does. Try method.execute=\"nmsim\" which is default when `path.nonmem` is provided.")
      }
    }
    

    
    
    setnames(dt.models,"path.sim","path.sim.main")
    cols.fneed <- cnames.gen[grepl("^files.needed",cnames.gen)]
    
    ## check that all path.sim and files.needed have been generated
    dt.files <- melt(dt.models.gen,measure.vars=c("path.sim",cols.fneed),value.name="file")
    dt.files[,missing:=!file.exists(file)]
    if(dt.files[,sum(missing)]){
      message(dt.files[,.("No. of files missing"=sum(missing)),by=.(column=variable)])
      stop("All needed files must be available after running simulation method.")
    }
    
    if(length(cols.fneed)){
      dt.models.gen[,ROW:=.I]
      ## by ROW, paste contents of columns named as described in cols.fneed
      ## dt.models.gen[,files.needed:=do.call(paste,as.list(c(get(cols.fneed),sep=":"))),by=.(ROW)]
      pastetmp <- function(...)paste(...,sep=":")
      dt.models.gen[,files.needed:=do.call(pastetmp,.SD),by=.(ROW),.SDcols=cols.fneed]
      
    }
    dt.models <- mergeCheck(
      dt.models.gen[,intersect(c("ROWMODEL","path.sim","files.needed"),cnames.gen),with=FALSE],
      dt.models,
      by="ROWMODEL"
     ,quiet=TRUE)


    
    ## path.sim.lst is full path to final output control stream to be
    ## read by NMscanData. This must be derived after method.sim may
    ## have spawned more runs.
    dt.models[,path.sim.lst:=fnExtension(path.sim,".lst")]
    #### model.sim has been defined already. I don't understand why it's redefined here.
    dt.models[,model.sim:=modelname(path.sim)]
    
    ## dt.models[,ROWMODEL2:=.I]
    dt.models[,ROWMODEL:=.I]
    ## dt.models[,seed:={if(is.function(seed))  seed() else seed},by=.(ROWMODEL2)]
    ## if(is.numeric(dt.models[,seed])) dt.model[,seed:=sprintf("(%s)",seed)]

    
    ### if typical
    if(is.character(typical)||typical){
      typical.use <- typical
      if(!is.character(typical)) typical.use <- NULL
      #### old typicalize version
      ## dt.mods.sim <- dt.models[,.(mod=typicalize(file.sim=path.sim,file.mod=file.mod,return.text=TRUE,file.ext=file.ext)),by=.(ROWMODEL,path.sim)]
      dt.mods.sim <- dt.models[,.(mod=typicalize(file.mod=path.sim,section=typical.use)),by=.(ROWMODEL,path.sim)]
      ## write results
      
      ## dt.models[,writeTextFile(dt.mods.sim[ROWMODEL2==ROWMODEL,mod],file=path.sim),by=ROWMODEL2]
      dt.mods.sim[,writeTextFile(lines=mod,file=unique(path.sim)),by=ROWMODEL]
    }

    
    if(do.seed){
      dt.models <- do.call(NMseed,c(list(models=dt.models),seed.nm))
    }
    
    
    ### seed and subproblems
    
    if(do.seed || subproblems>0){
      dt.models[,{
        
        lines.sim <- readLines(path.sim,warn=FALSE)
        all.sections.sim <- NMreadSection(lines=lines.sim)
        names.sections <- names(all.sections.sim)
        n.sim.sections <- sum(grepl("^(SIM|SIMULATION)$",names.sections))
        if(n.sim.sections == 0 && (!is.null(arg.seed.nm) || subproblems>1) ){
          warning("No simulation section found. Subproblems and seed will not be applied.")
        }
        if(n.sim.sections > 1 ){
          warning("More than one simulation section found. Subproblems and seed will not be applied.")
        }
        if(n.sim.sections == 1 ){
          
          name.simsec <- names.sections[grepl("^(SIM|SIMULATION)$",names.sections)]
          section.sim <- all.sections.sim[[name.simsec]]
          
          section.sim <- gsub("\\([0-9]+\\)","",section.sim)
          
          ### pasting the seed after SIM(ULATION) and after ONLYSIM(ULATION) if the latter exists. seed refers to dt.models[,seed], not the argument called seed
          section.sim <- sub("(SIM(ULATION)*( +ONLYSIM(ULATION)*)*) *",paste("\\1",seed),section.sim)

          if(subproblems>0){
            section.sim <- gsub("SUBPROBLEMS *= *[0-9]*"," ",section.sim)
            section.sim <- pasteEnd(section.sim,sprintf("SUBPROBLEMS=%s",subproblems))
          }
          ## section.sim <- paste(section.sim,text.sim)
          section.sim <- pasteEnd(section.sim,text.sim)
          lines.sim <- NMdata:::NMwriteSectionOne(lines=lines.sim,section="simulation",newlines=section.sim,quiet=TRUE,backup=FALSE)
          writeTextFile(lines.sim,path.sim)
        }
      },by=.(ROWMODEL)]
    }
    
    
    
    #### Section start: Additional control stream modifications specified by user - modify ####

    if(!is.null(sizes)){
      dt.models[,{
        args.sizes <- append(list(file.mod=path.sim,newfile=path.sim,write=TRUE),sizes)
        do.call(NMwriteSizes,args.sizes)
      },by=.(ROWMODEL)]
    }

    
    if(!is.null(filters)){
      dt.models[,{
        args.filters <- list(file=path.sim,filters=filters,write=TRUE)
        do.call(NMwriteFilters,args.filters)
      },by=.(ROWMODEL)]
    }


    if( !is.null(modify) ){
      modifyModel(modify,dt.models)
    }
    
    ### Section end: Additional control stream modifications specified by user - modify


    

    ######  store NMscanData arguments
    args.NMscanData.list <- c(args.NMscanData,args.NMscanData.default)
    args.NMscanData.list <- args.NMscanData.list[unique(names(args.NMscanData.list))]
    ## if(!is.null(args.NMscanData.list)){
    if(nrow(dt.models)==1){
      dt.models[,args.NMscanData:=list()]
    } else {
      dt.models[,args.NMscanData:=vector("list", .N)]
    }
    dt.models[,args.NMscanData:=list(list(args.NMscanData.list))]


    ###### store transform
    
    if(nrow(dt.models)==1){
      dt.models[,funs.transform:=list()]
    } else {
      dt.models[,funs.transform:=vector("list", .N)]
    }
    dt.models[,funs.transform:=list(list(transform))]

    
    
    
    #### Section start: Execute ####

    
    ### files needed can vary, so NMexec must be run for one model at a time
    simres <- NULL

    if(execute){
      ##### Messaging user
      if(!quiet) {
        if(wait.exec){
          message(paste("* Executing Nonmem job(s)",ifelse(NMsimConf$method.execute=="psn","(using PSN)","")))
        } else {
          message(paste0("* Starting Nonmem job(s)",ifelse(NMsimConf$method.execute=="psn"," (using PSN)","")," in background"))
        }
      }

      dt.models[,unlink(path.rds)]
      ## file.res.data <- fnAppend(fnExtension(dt.models[,path.rds],"fst"),"res")
      if(any(file.exists(dt.models[,path.results]))){
        unlink(dt.models[file.exists(path.results),unlink(path.results)])
      }

      ## run sim
      
      if(is.null(progress)) {
        do.pb <- !quiet && dt.models[,.N]>1
      } else {
        do.pb <- progress
      }

      if(is.null(nmquiet)){
        ## easier to do ! (talk)
        nmquiet <- ! (wait && dt.models[,.N]==1 && !do.pb && !quiet && subproblems<=1 )
      }
      
      if(do.pb){
        ## set up progress bar
        pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                             max = dt.models[,.N], # Maximum value of the progress bar
                             style = 3,    # Progress bar style (also available style = 1 and style = 2)
                             ## width = 50,   # Progress bar width. Defaults to getOption("width")
                             char = "=")
      }

      ###### execute jobs using NMexec
      dt.models[,path.mod.exec:={
        simres.n <- NULL
        files.needed.n <- try(strsplit(files.needed,":")[[1]],silent=TRUE)
        if(inherits(files.needed.n,"try-error")) files.needed.n <- NULL
        
        ### this is an important assumption. Removing everyting in format
        ### run.extension. run_input.extension kept.
        ## files.unwanted <- list.files(
        if(file.exists(path.sim.lst)){
          ## message("Existing output control stream found. Removing.")
          dt.outtabs <- try(NMscanTables(path.sim.lst,meta.only=TRUE,as.fun="data.table",quiet=TRUE),silent=TRUE)
          if(!inherits(dt.outtabs,"try-error") && is.data.table(dt.outtabs) && nrow(dt.outtabs)>0){
            file.remove(
              dt.outtabs[file.exists(file),file]
            )
          }
          unlink(path.sim.lst)

        }
        
        
        obj.exec <- NMexec(files=path.sim,sge=sge,nc=nc,wait=wait.exec,
                           args.psn.execute=args.psn.execute,nmquiet=nmquiet,quiet=TRUE,
                           method.execute=NMsimConf$method.execute,
                           path.nonmem=NMsimConf$path.nonmem,
                           dir.psn=NMsimConf$dir.psn,
                           system.type=NMsimConf$system.type,
                           files.needed=files.needed.n,
                           input.archive=input.archive,
                           dir.data="..",
                           clean=clean,
                           nmfe.options=nmfe.options,
                           backup=FALSE)
        
        ## simres.n <- list(lst=path.sim.lst)
        ## simres.n
        if(do.pb){
          setTxtProgressBar(pb, .I)
          
        }
        
        obj.exec$mod.exec
      },by=.(ROWMODEL)]
      if(do.pb){
        close(pb)
      }
    }
    
    ###  Section end: Execute
    
    dt.models.save <- split(dt.models,by="path.rds")
    addClass(dt.models,"NMsimModTab")
    files.rds <- lapply(1:length(dt.models.save),function(I){

      ####### notify user where to find rds files
      fn.this.rds <- unique(dt.models.save[[I]][,path.rds])
      addClass(dt.models.save[[I]],"NMsimModTab")
      saveRDS(dt.models.save[[I]],file=fn.this.rds)
      fn.this.rds
    })

    #### Section start: Read results if requested ####
    
    if(execute && (wait.exec||wait)){
      ##### Messaging user
      ### we are controlling this messaging better from NMreadSim()
      ## if(!quiet) message("* Collecting Nonmem results")
      simres <- NMreadSim(unlist(files.rds),wait=wait,progress=progress,quiet=quiet,as.fun=as.fun)
    }
    ### Section end: Read results if requested
return(list(dt.models=dt.models,simres=simres))
  }

  
