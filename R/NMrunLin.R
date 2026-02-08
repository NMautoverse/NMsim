##' Internal function to run Nonmem on linux
##' @param fn.mod Just the file name, not including path
##' @keywords internal
NMrunLin <- function(fn.mod,dir.mod.abs,exts.cp,meta.tables,path.nonmem,clean,sge,nc,pnm,nmfe.options,fun.post=NULL){

    ## nmfe.options
    if(missing(nmfe.options)) nmfe.options <- NULL

    
    rm.if.pres <- function(regex){
        sprintf("find . -type f -name \"%s\" -exec rm {} \\;",regex)     
    }


    name <- NULL
    fn.lst <- fnExtension( fn.mod,".lst")
    line.run <- sprintf("%s %s %s %s",path.nonmem,fn.mod,fn.lst,nmfe.options)

    if(sge){
        ## executing from model execution dir.
        jobname <- 
            sub(pattern="^ *",replacement="", x=basename(fn.mod) )
        ## qsub does not allow a jobname to start in a numeric
        if(grepl("^[0-9]",jobname)) {
            jobname <- paste0("NM",jobname)
        }
        line.run <- sprintf('qsub -terse %s -V -e \"%s\" -o \"%s\" -N \"%s\" -j y -cwd -b y \"%s\" -background'
                           ,ifelse(nc>1,paste("-pe orte",nc),"")
                           ,"NMexec.err"
                           ,"NMexec.out"
                           ,jobname
                           ,line.run
                            )

        if(nc>1){
            line.run <- sprintf('%s -parafile=\"%s\" [nodes]=%s',line.run,getAbsolutePath(pnm),nc)
        }
        ##line.run <- paste(line.run,"| read jobid_qsub")
        line.run <- paste0("jobid_qsub=$(",line.run,"  2>&1)")
    }


    lines.wait <- c()
    if(sge) {
        path.wait.qsub <- system.file("bash/wait_qsub.sh",package="NMsim")
        #### would be better to copy wait_qsub.sh. But where should it be copied to?
## file.copy(path.wait.qsub)
        lines.wait <- paste(path.wait.qsub, "\"$jobid_qsub\"")
    }
    
    lines.bash <- c(
        "#!/bin/bash"
       ,""
       ,line.run
        ##,"echo \"job submitted\" > "        
       ,lines.wait
### copy output tables back
### this would be simpler. Needs testing.
        ## ,sprintf("find . -type f -name \'%s\' -exec cp {} \'%s\' \\;",meta.tables[,name],dir.mod.abs)
       ,paste0("find . -type f -name ",paste0("\'",meta.tables[,name],"\'")," -exec cp {} \'",dir.mod.abs,"\' \\;")

### copy wanted files back to orig location of fn.mod 
       ,paste0("find . -type f -name ",paste0("\'*.",exts.cp,"\'")," -exec cp {} \'",dir.mod.abs,"\' \\;")
       ,""
    )

    if(clean>0 && clean<5){

        patterns.clean <- cleaningPatterns(clean)
        lines.bash <- c(lines.bash
                       ,paste(unlist(lapply(patterns.clean,
                                            rm.if.pres)),collapse="\n")
                        )
        
    }
    lines.bash <- c(lines.bash
                   ,"oldwd=$PWD"
                   ,"cd .."
                    )
    if(clean==5){
        lines.bash <- c(lines.bash
                       ,"rm -r \"$oldwd\""
                       ,""
                        )
    }

    if(!is.null(fun.post)){
        lines.bash <- c(lines.bash,
                        fun.post(file.path(dir.mod.abs,basename(fn.mod)))
                        )
    }
    
    lines.bash
}
