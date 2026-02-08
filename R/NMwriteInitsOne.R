##' @keywords internal

NMwriteInitsOne <- function(lines,inits.w,inits.orig,pars.l){
    . <- NULL
    elems.found <- NULL
    elemnum <- NULL
    elemnum_BLOCK <- NULL
    elemnum_init <- NULL
    elemnum_lower <- NULL
    elemnum_upper <- NULL
    iblock <- NULL
    linenum <- NULL
    linenum.unique <- NULL
    nchars.active <- NULL
    newtext <- NULL
    par.type <- NULL
    string.elem <- NULL
    text <- NULL
    text.after <- NULL
    text.before <- NULL
    type.elem <- NULL
    V1 <- NULL
    value.elem_BLOCK <- NULL
    value.elem_FIX <- NULL
    value.elem_init <- NULL
    value.elem_lower <- NULL
    value.elem_upper <- NULL

    

    ## need to write line by line. All elements in a line written one at a time
    paste.ll.init.ul <- function(lower,init,upper,FIX,BLOCK){
### some code in paste.ll.init.ul suggests that more than one row is
### handled at a time (like row:=.I). But it is never used that way,
### and I don't think it would be easy to make it work with that. Also
### I don't see why it should.
        res <- NULL
        
        ## if(any(is.na(init))) stop("An initial value must be provided")
        if(!is.na(lower) && is.na(init)) stop("When lower, or upper is provided, an initial value must be provided too")
        if(any(!is.na(upper)&is.na(lower))) stop("if upper limit is provided, lower limit must also be provided.")
        dt <- data.table(lower=lower,init=init,upper=upper)[,row:=.I]
        dt[,res:=""]
        
        if(!is.na(init)){
            dt[init=="SAME",res:=init]
            dt[init!="SAME",res:=paste0("(",paste(setdiff(c(lower,init,upper),NA),collapse=","),")",FIX),by=row]
            dt[init!="SAME"&is.na(lower)&is.na(upper),res:=paste0(init,FIX),by=row]
        } else if (!is.na(FIX)) {
            dt[,res:=FIX,by=row]
        }
        ##if(!is.na(BLOCK)) dt[,res:=sprintf("BLOCK(%s) %s",BLOCK,res)]
        dt$res
    }
    
######### format paramters for ctl
    inits.w[,type.elem:="ll.init.ul"]
    inits.w[,row:=1:.N]
    
    if(!"value.elem_BLOCK"%in%colnames(inits.w)){
        inits.w[,value.elem_BLOCK:=NA_character_]
    }
    if(!"elemnum_BLOCK"%in%colnames(inits.w)){
        inits.w[,elemnum_BLOCK:=NA]
    }
    
### The way paste.ll.unit.ul works, it pastes FIX after all fixed
### parameters. But BLOCKs should only be fixed once. Dropping FIX
### from non-first elements in blocks.
########## I think the best would be to summarize FIX in the BLOCK element. Then have paste.ll..... add FIX right after BLOCK() like BLOCK(2) FIX 0 0 0     
    ## inits.w[,iblock.unique:=.GRP,by=.(par.type,iblock)]
    ## !is.na(value.elem_init) is because we don't count BLOCK elements here
    ##inits.w[!is.na(value.elem_init)&duplicated(iblock.unique),value.elem_FIX:=""]
    ## inits.w[blocksize>1&elemn]
    ## inits.w[,value.elem_FIX:=ifelse(any(grepl("FIX",value.elem_FIX))," FIX",""),by=iblock.unique]
    inits.w[,string.elem:=paste.ll.init.ul(lower=value.elem_lower,
                                           init=value.elem_init,
                                           upper=value.elem_upper,
                                           FIX=value.elem_FIX,
                                           BLOCK=value.elem_BLOCK),by=row]
    inits.w[,elemnum:=min(elemnum_lower,elemnum_init,elemnum_upper,elemnum_BLOCK,na.rm=TRUE),by=row]
    ## the elemnum may become character if some are missing. That will
    ## lead to wrong ordering as 11 is sorted before 8.
    inits.w[,elemnum:=as.numeric(elemnum)]

    cnames.common <- intersect(colnames(pars.l),colnames(inits.w))
    elems.all <- rbind(
        pars.l[!type.elem%in%c("lower","init","upper","FIX")][,cnames.common,with=FALSE]
       ,
        inits.w[,cnames.common,with=FALSE]
    )
    
    elems.all <- elems.all[order(par.type,linenum,elemnum)]
    elems.all[,row:=.I]
    ## idx.update <- elems.all[par.type%in%c("OMEGA","SIGMA"), row[1], by = .(par.type,iblock)][,V1]
    idx.update <- elems.all[, row[1], by = .(par.type,iblock)][,V1]
    ## putting $SECTION in front of every new line
    elems.all[,linenum.unique:=.GRP,by=.(par.type,linenum)]
    ## elems.all[idx.update, string.elem := paste(paste0("$",par.type),string.elem)]
    elems.all[!duplicated(linenum.unique)&row%in%idx.update, string.elem := paste(paste0("$",par.type),string.elem)]

    ## lines.all should also include empty lines and before and after text
    setorder(elems.all,par.type,linenum,elemnum)
    lines.all <- elems.all[,.(text=paste(string.elem,collapse=" ")),keyby=.(par.type,linenum)]

    mod.lines <- inits.orig$lines
    
    
    lines.all.2 <- elems.all[,.(newtext=paste(string.elem,collapse=" ")),keyby=.(par.type,linenum)]
    lines.all.2[,elems.found:=TRUE]
##### this is the new total lines obj
    lines.all.3 <- mergeCheck(mod.lines,lines.all.2,by=c("par.type","linenum"),all.x=TRUE,quiet=TRUE)
##### correct elems.found=NA to FALSE
    lines.all.3[is.na(elems.found),elems.found:=FALSE]
#### update newtext for lines without elements. This will only work if text was read with keep.name=FALSE
    lines.all.3[elems.found==FALSE,newtext:=sub(pattern=paste0("^ *\\$ *",par.type),replacement="",x=text,ignore.case=TRUE),by=.(par.type,linenum)]

    

    lines.all.3[elems.found==TRUE&!is.na(text.before),newtext:=paste(
                                                          sub(pattern=paste0("\\$ *",par.type),"",text.before,ignore.case=TRUE)
                                                         ,newtext
                                                      ),by=.(par.type,linenum)]

    
    ## number of characters to reserve for before+newtext
    lines.all.3[elems.found==TRUE,nchars.active:=max(nchar(newtext))+1,by="par.type"]
    lines.all.3[,row:=.I]
    
    lines.all.3[elems.found==TRUE,newtext:=paste0(newtext,paste(rep(" ",nchars.active-nchar(newtext)),collapse="")),by=row]
    
    lines.all.3[elems.found==TRUE&!is.na(text.after),newtext:=paste(
                                                         newtext,
                                                         paste0(";",text.after)
                                                     ),by=.(par.type,linenum)]
    lines.all.3[,text:=newtext]
    

    fun.update.ctl <- function(lines.old,section,dt.lines){
        par.type <- NULL
        text <- NULL
        
        newsection <- dt.lines[par.type==section,text]
        if(length(newsection)==0) return(lines.old)
        
        NMwriteSectionOne(lines=lines.old,
                          section=section,
                          newlines=newsection,
                          location="replace",
                          quiet=TRUE,
                          backup=FALSE)
    }

    
    
    lines <- fun.update.ctl(lines,section="THETA",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="OMEGA",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="SIGMA",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="THETAP",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="THETAPV",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="OMEGAP",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="OMEGAPD",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="SIGMAP",dt.lines=lines.all.3)
    lines <- fun.update.ctl(lines,section="SIGMAPD",dt.lines=lines.all.3)
    

    lines
}
