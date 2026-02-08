##' @keywords internal

NMsimDataPrepare <- function(data,auto.dv,order.columns){

    DATAROW <- NULL
    DV <- NULL
    MDV <- NULL
    
    if(is.null(data)) return(data)
    
    if(!is.null(data) && is.data.frame(data)) {
        ##data <- list(copy(data))
        data <- list(data)
        data <- lapply(data,as.data.table)

    }

    ## default
    col.row <- NA_character_


    ## data sets must not be empty
    if(any(sapply(data,function(x)x[,.N==0]))){
        stop("Empty data set provided. If `data` is a list of data sets, make sure all of them are non-empty.")
    }

    
    
    ## if the list contains data.tables, we don't want to edit the data directly (by ref)
    if(any(sapply(data,is.data.table))){
        data <- copy(data)
    }
    names.data <- names(data)
    if(is.null(names.data)) {
### only add data counter/name if more than one data set or name is provided.
        
        if(length(data)>1){
            names.data <- as.character(1:length(data))
        } else {
            names.data <- ""
        }
    } else if(""%in%names.data) {
        names.data <- gsub(" ","_",names.data)
        if(any(duplicated(names.data))) stop("If data is a list of data sets, the list elements must be uniquely named.")
        names.data[names.data==""] <- as.character(which(names.data==""))
    }
    dt.data <- data.table(data.name=names.data)[,DATAROW:=.I]


    if(auto.dv){
        
        data <- lapply(data,function(x){
            if("DV"%in%colnames(x)){
                x
            } else {
                x[,DV:=NA_real_]
                if(!"MDV"%in%colnames(x)){
                    x[,MDV:=1]
                }
                x
            }})
    }
    all.names <- unique(unlist(lapply(data,colnames)))
    col.row <- tmpcol(names=all.names,base="NMROW")
    ## data <- lapply(data,function(d)d[,(col.row):=(1:.N)/1000])
    data <- lapply(data,function(d)d[,(col.row):=(1:.N)])
    if(order.columns) data <- lapply(data,NMorderColumns,col.row=col.row)
     

    
    list(data=data,col.row=col.row,dt.data=dt.data)
}
