##' Create text lines for OMEGA and SIGMA Nonmem sections
##'
##' @param omegas A data.table with at least `i`, `j` and `value`
##'     columns. See `NMdata::NMreadExt` and the pars element returned
##'     by that function. Must at least have columns `i`, `j`,
##'     `value`, `iblock`, `blocksize`, `FIX`.
##' @param as.one.block If `TRUE`, all values are printed as one
##'     block. If `FALSE` (default), matrix will be separeted into
##'     blocks based on position non-zero off-diagonal
##'     values. Generally speaking, for `OMEGA` matrices (var-cov
##'     matrices for ETAs), this should be `FALSE`, and for
##'     variance-covariance matrices (like `THETAP`), this should be
##'     `TRUE`.
##' @param fix Include `FIX` for all lines? If `FALSE`, fixing will
##'     not be modified. Notice, `fix=TRUE` will fix everything -
##'     individual parameters cannot be controlled. For finer control
##'     and way more features, see `NMdata::NMwriteInits()`.
##' @param type The matrix type. `OMEGA` or `SIGMA` - case
##'     in-sensitive. Will be used to print say `$OMEGA` in front of
##'     each line.
##' @return Character vector
##'
##' @keywords internal

NMcreateMatLines <- function(omegas,as.one.block=FALSE,fix=FALSE,type){

    . <- NULL
    blocksize <- NULL
    FIX <- NULL
    i <- NULL
    iblock <- NULL
    j <- NULL
    hasOff <- NULL    
    maxOff <- NULL
    offNonZero <- NULL
    text <- NULL
    value <- NULL
    value.c <- NULL

    
    
    if(fix){
        fun.string.fix <- function(FIX) " FIX"
    } else {
        fun.string.fix <- function(FIX) ifelse(FIX," FIX","")
    }
    
    if(!missing(type)){
        string.type <- paste0("$",toupper(type))
    } else {
        string.type <- ""
    }

    
    if(as.one.block){
        omegas[,blocksize:=max(i)-min(i)+1]
        omegas[,iblock:=1]
        omegas[,FIX:=as.integer(fix)]
    }

    setorder(omegas,i,j)
    
    
    ## is <- unique(omegas$i)
    loopres <- c()
    iblocks <- unique(omegas$iblock)
    iblocks <- iblocks[!is.na(iblocks)]

    

    for(i.this in iblocks){
        
        values.this <- omegas[iblock==i.this]
        this.blocksize <- values.this[,unique(blocksize)]
        
        if(this.blocksize>1){
            ## derive fix
            values.this[,value.c := as.character(value)]
            values.this[value==0,value.c := "1E-30"]
            ##values.this[value==0,value:=1e-30]
            res <- pasteBegin(
                add=paste0("BLOCK(",this.blocksize,")",fun.string.fix(values.this[i==i.this&j==i.this,FIX]))
               ,
                x=values.this[,.(text=paste(value.c,collapse=" ")),keyby=.(i)]$text
            )
            
        } else {
            res <- values.this[,value]
            ## if(values.this[,FIX])  res <- paste(res, fun.string.fix(1))
            res <- paste0(res, fun.string.fix(values.this[,FIX]))
        }
        res <- pasteBegin(add=string.type,x=res)
        loopres <- c(loopres,res)
    }
    
    lines.mat <- loopres

    return(lines.mat)

}
