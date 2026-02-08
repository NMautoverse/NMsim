
##' @import data.table
##' @import NMdata
##' @keywords internal
### read using fread, then merge with input data. Assume NMREP exists.
## file.mod <- "~/tmp/sims/xgxr032_tabopts5/xgxr032_tabopts5.lst"
## NMreadTabFast(file.mod=file.mod)


NMreadTabFast <- function(file,file.mod,carry.out,col.row=NULL,...){
    
    .tmpcol <- NULL
    
    if(missing(file.mod)||is.null(file.mod)){
        file.mod <- file
    }
    if(missing(carry.out) || is.null(carry.out)){
        carry.out <- TRUE
    }

    ## if(packageVersion("NMdata")>="0.2.1"){
        meta.output <- NMscanTables(file=file,quiet=TRUE,as.fun="data.table",skip.absent=TRUE,
                                    modelname=file.mod,col.model="model",meta.only=TRUE)
    ## } else {
    ## meta.output <- NMscanTables(file=file,quiet=TRUE,as.fun="data.table",skip.absent=TRUE,
    ##                             meta.only=TRUE)
    ## }

    alltabs <- lapply(meta.output$file,fread,...)

    cbind.new <- function(x,y){
        cbind(x,y[,setdiff(colnames(y),colnames(x)),with=FALSE])
    }

    alltabs <- Reduce(cbind.new,alltabs)

    ## add input data
    if(!isFALSE(carry.out)){

        inp <- NMscanInput(file=file,file.mod=file.mod,apply.filters=FALSE,translate=TRUE,recover.cols=TRUE,as.fun="data.table")
        
        if(isTRUE(carry.out)) {
            carry.out <- setdiff(colnames(inp),colnames(alltabs))
        } else {
            miss.carry.out <- setdiff(carry.out,colnames(inp))
            if(length(miss.carry.out)) {
### NMsim() says this too. We don't want it repeated for all models.
                ## message("variables in `carry.out` not found in input data ignored:\n",paste(miss.carry.out,collapse=", "))
                carry.out <- setdiff(carry.out,miss.carry.out)
            }
        }
        if(is.null(col.row)){
            
            col.by <- NULL
            if("NMREP"%in%colnames(alltabs)) col.by <- "NMREP"

            alltabs <- alltabs[,cbind(inp[,carry.out,with=FALSE],.SD),keyby=col.by,
                               .SDcols=setdiff(colnames(alltabs),c(carry.out,col.by))]
            setkey(alltabs,NULL)
        } else {
            alltabs[,.tmpcol:=.I]
            alltabs <- merge(alltabs,inp[,unique(c(col.row,carry.out)),with=FALSE],by=col.row,all.x=TRUE)
            setorder(alltabs,.tmpcol)
            alltabs[,.tmpcol:=NULL]

        }
    }
    
    alltabs
}
