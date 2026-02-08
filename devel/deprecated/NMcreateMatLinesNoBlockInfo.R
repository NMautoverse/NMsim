##' Create text lines for OMEGA and SIGMA Nonmem sections
##'
##' @param omegas A data.table with at least `i`, `j` and `value`
##'     columns. See `NMdata::NMreadExt` and the pars element returned
##'     by that function.
##' @param as.one.block If `TRUE`, all values are printed as one
##'     block. If `FALSE` (default), matrix will be separeted into
##'     blocks based on position non-zero off-diagonal
##'     values. Generally speaking, for `OMEGA` matrices (var-cov
##'     matrices for ETAs), this should be `FALSE`, and for
##'     variance-covariance matrices (like `THETAP`), this should be
##'     `TRUE`.
##' @param fix Include `FIX` for all lines? If not, none will be
##'     fixed. Currently, there is no support for keeping
##' @param type The matrix type. `OMEGA` or `SIGMA` - case
##'     in-sensitive. Will be used to print say `$OMEGA` in front of
##'     each line.
##' @return Character vector
##'
##' @keywords internal

NMcreateMatLinesNoBlockInfo <- function(omegas,as.one.block=FALSE,fix=TRUE,type){
    . <- NULL
    j <- NULL
    i <- NULL
    value <- NULL
    maxOff <- NULL
    hasOff <- NULL
    offNonZero <- NULL
    text <- NULL
    
    string.fix <- ifelse(fix,"FIX","")
    if(!missing(type)){
        string.type <- paste0("$",toupper(type))
    } else {
        string.type <- ""
    }

    
    

    ## the code was written in the oppositie direction, so switching i
    ## and j.
    omegas.long <- omegas[,.(i=j,j=i,value)]
    if(as.one.block){
        ## omegas.long[,hasOff:TRUE]
        omegas.long[,maxOff:=max(abs((1:max(j))-i)),by=i]
    } else {
        omegas.long[,maxOff:=0]
        omegas.long[,hasOff:=FALSE]
        omegas.long[,offNonZero:=abs(value)>1e-9&i!=j]

        if(any(omegas.long$offNonZero)){
            omegas.long[,hasOff:=any(offNonZero==TRUE),by=.(i)]
        }
        omegas.long[hasOff==TRUE,maxOff:=max(j[abs(value)>1e-9]-i),by=.(i)]
    }
    
    is <- unique(omegas.long$i)

    i.idx <- 1
    loopres <- c()
    ## Netas <- omegas[,max(i)]

    while(i.idx <= length(is)){
        i.this <- is[i.idx]
        nis.block <- omegas.long[i==i.this,unique(maxOff)]
        if(nis.block>0){
            ## values.this <- omegas.long[i>=i.this&i<=(i.this+nis.block)&j<=(i.this+nis.block),value]
            ## values.this[values.this==0] <- 1e-30
            ## res <- paste0("BLOCK(",nis.block+1,") ",string.fix," ",paste(values.this,collapse=" "))
            values.this <- omegas.long[i>=i.this&i<=(i.this+nis.block)&j<=(i.this+nis.block),.(j,value)]
            values.this[value==0,value:=1e-30]
            res <- pasteBegin(
                add=paste0("BLOCK(",nis.block+1,") ",string.fix)
               ,
                x=values.this[,.(text=paste(value,collapse=" ")),by=j][,text]
            )
            
            i.idx <- i.idx+nis.block+1
        } else {
            value.this <- omegas.long[i==i.this&j==i.this,value]
            if(string.fix==""){
                res <- value.this       
            } else {
                res <- paste(value.this, string.fix)
            }
            i.idx <- i.idx+1
        }
        res <- pasteBegin(add=string.type,x=res)
        loopres <- c(loopres,res)
    }
    
    ##lines.mat <- paste(paste0("$",toupper(type)),loopres)
    lines.mat <- loopres

    return(lines.mat)
}

