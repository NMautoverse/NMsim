##' @author Sanaya Shroff, Philip Delff
##' @keywords internal 

samplePars_simpar <- function(file.mod,nsims,format="ext",seed.R,as.fun){

    . <- NULL
    model <- NULL
    parameter <- NULL
    FIX <- NULL
    blocksize <- NULL
    
    
    DF2 <- NULL 
    iblock  <- NULL
    par.type <- NULL
    value <- NULL

    
    loadres <- requireNamespace("simpar",quietly=TRUE)
    if(!loadres) {
        message("simpar not found. Please install from github or MPN or use alternative sampling methods.")
        return(NULL)        
    }

    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)
    
    if(!missing(seed.R) && !is.null(seed.R)) {
        set.seed(seed=seed.R)
    }

    
    ## read param distributions from ext file
    pars <- NMreadExt(file=file.mod,as.fun="data.table")

    ## calculate degrees of freedom
    omega.sigma.dfs <- NWPRI_df(pars)

    ## variance-covariance for THETAs
    covar <- NMreadCov(file=file.mod)
    theta.covar <- covar[grep("^THETA",rownames(covar))
                        ,grep("^THETA",colnames(covar))]

    ## variance-covariance for OMEGAs
    omegas <- pars[par.type=="OMEGA" & !is.na(iblock),]
    omegas.list <- split(omegas,by="iblock")
    omega.mat.list <- 
        lapply(omegas.list,
               NMdata::dt2mat)
    
    ## variance-covariance for SIGMAs
    sigmas <- pars[par.type=="SIGMA" & !is.na(iblock),]
    sigmas.list <- split(sigmas,by="iblock")
    sigma.mat.list <- 
        lapply(sigmas.list,
               NMdata::dt2mat)

    
    
    ## use simpar to sample params
    pars.sample <- simpar::simpar(
                               nsim = nsims,
                               theta = pars[par.type=="THETA",value],
                               covar = theta.covar,
                               omega = omega.mat.list,
                               odf = omega.sigma.dfs[par.type=="OMEGA",DF2],
                               sigma = sigma.mat.list,
                               sdf = omega.sigma.dfs[par.type=="SIGMA",DF2]
                           )
    
    pars.sample <- as.data.table(pars.sample)
    
    if(format=="ext"){
        ## read in parameters simulated with simpar
        pars.sample <- readParsWide(
            data=pars.sample,as.fun="data.table"
        )
        if("model"%in%colnames(pars.sample)){
            pars.sample[,model:=NULL]
        }
        
        pars.sample <- mergeCheck(
            pars.sample
           ,
            pars[,.(parameter,model,value.est=value,FIX,iblock,blocksize)]
           ,
            by="parameter",common.cols="drop.y",quiet=T,all.x=TRUE
        )
    }
    as.fun(pars.sample)
}
