##' Simulate with parameter variability using the NONMEM NWPRI subroutine
##' 
##' @description Modify control stream for simulation with uncertainty
##'     using inverse-Wishart distribution for OMEGA and SIGMA
##'     parameters
##'
##' This function does not run any simulations. To simulate, using
##' this method, see `NMsim()`. See examples.
##'
##' 
##' @param file.sim The path to the control stream to be edited. This
##'     function overwrites the contents of the file pointed to by
##'     file.sim.
##' @param file.mod Path to the path to the original input control
##'     stream provided as `file.mod` to `NMsim()`.
##' @param data.sim Included for compatibility with `NMsim()`. Not
##'     used.
##' @param PLEV Used in \code{$PRIOR NWPRI PLEV=0.999}. This is a
##'     NONMEM argument to the NWPRI subroutine. When PLEV < 1, a
##'     value of THETA will actually be obtained using a truncated
##'     multivariate normal distribution, i.e. from an ellipsoidal
##'     region R1 over which only a fraction of mass of the normal
##'     occurs. This fraction is given by PLEV.
##' @param add.diag A umeric value to add to the diagonal of the
##'     covariance matrix. This can be used in case of negative
##'     eigenvaluen in variance-covariance matrix.
##' @param ... Additional arguments passed to `NMsim_default()`.
##' @details Simulate with parameter uncertainty. THETA parameters are
##'     sampled from a multivariate normal distribution while OMEGA
##'     and SIGMA are simulated from the inverse-Wishart
##'     distribution. Correlations of OMEGA and SIGMA parameters will
##'     only be applied within modeled "blocks".
##' @references
##'     \href{https://ascpt.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002\%2Fpsp4.12422&file=psp412422-sup-0001-Supinfo1.pdf}{inverse-Wishart
##'     degrees of freedom calculation for OMEGA and SIGMA: NONMEM
##'     tutorial part II, supplement 1, part C.}

##' @seealso NMsim_VarCov
##' @import NMdata
##' @import data.table
##' @return Path to simulation control stream
##' @author Brian Reilly, Philip Delff
##' @examples
##' \dontrun{
##' simres <- NMsim(file.path,method.sim=NMsim_WPRI,typical=TRUE,subproblems=500)
##' }
##' @export

NMsim_NWPRI <- function(file.sim,file.mod,data.sim,PLEV=0.999,add.diag,...){

    NMdata:::messageWrap("NMsim_NWPRI: Simulation with variability on OMEGA and SIGMA are only reliable starting from Nonmem 7.60. Prior to Nonmem 7.60, NMsim_NWPRI reliably samples THETAs only. To explicitly skip sampling OMEGAs, run NMsim with `typical=TRUE`",fun.msg=message)
    
    . <- NULL
    DF <- NULL
    DF2 <- NULL
    FIX <- NULL
    N <- NULL
    blocksize <- NULL
    est <- NULL
    i <- NULL
    imin <- NULL
    iblock <- NULL
    j <- NULL
    line <- NULL
    par.name <- NULL
    par.type <- NULL
    par.type.i <- NULL
    par.type.j <- NULL
    parameter <- NULL
    parameter.i <- NULL
    parameter.j <- NULL
    return.text <- NULL
    SAME <- NULL
    sameblock <- NULL
    Nsameblock <- NULL
    se <- NULL
    value <- NULL


### NMsim_default() is run because it inserts $SIMULATION instead of
### $ESTIMATION and a few other things that are always needed.
    files.needed.def <- NMsim_default(file.sim=file.sim,file.mod,data.sim,...)
    
    lines.sim <- readLines(file.sim,warn=FALSE)

    cov <- NMreadCov(fnExtension(file.mod,".cov"))    
    pars.ext <- NMreadExt(file.mod,return="pars",as.fun="data.table")[,value:=est]
    ## use inits to identify IOV OMEGA terms that share a single distribution via the SAME column and remove them.
    inits <- NMreadInits(file.mod, as.fun="data.table")
    
    inits = addSameBlocks(inits = inits)
    
    pars = merge.data.table( pars.ext, inits[,.(parameter,SAME, sameblock, Nsameblock)],by = cc(parameter), all.x = TRUE)[,par.type:=factor(par.type, levels = c("THETA", "OMEGA", "SIGMA"))][order(par.type,i,j)]
    #pars = pars.ext

    if(!"se"%in%colnames(pars)){
        stop("ext file does not contain standard errors. A succussfull COVARIANCE step is needed for NMSIM_NWPRI to run.")
    }
    

### Add degrees of freedom for inverse-wishart distribution for OMEGA/SIGMA
    # remove parameters coming from SAME distribution (SAME==1) as another parameter since they are only a single parameter which is captured by the parameter with SAME==0
    nwpri_df <- NWPRI_df(pars[SAME!=1])
    nwpri_df[,line := paste0("$", par.type,"PD ", DF2, " FIX")]
    
    ## derive the different sets of new lines needed
    ## $THETAP section
    thetas <- pars[par.type=="THETA"][order(i)]
    lines.thetap <- c("$THETAP", paste(thetas[,est], "FIX"))

    ## $THETAPV
    if(packageVersion("NMdata")>'0.1.8.3') {
        cov.l <- mat2dt(cov,as.fun="data.table",triangle = "lower")
    } else {
        cov.l <- mat2dt(cov,as.fun="data.table",triangle = "upper")
    }
    cov.l <- addParType(cov.l,suffix="i")
    cov.l <- addParType(cov.l,suffix="j")
    
    ## Identify fixed thetas and set their diagonal in the $THETAPV cov matrix to be 1.0 for compatibility with nm7.60
    cov.l = merge.data.table(x = cov.l, y = pars[par.type=="THETA",.(i, parameter.i=parameter,FIX)], by = c("i", "parameter.i"))
    cov.l[i==j&FIX==1, value := 1.0]    

    if(!missing(add.diag)&& !is.null(add.diag) && add.diag!=0){
        message("Adding to cov diagonal")        
        ## cov.dt <- mat2dt(cov,as.fun="data.table")
        ## cov.dt[i==j,value:=value+add.diag]
        ## cov <- dt2mat(cov.dt)
        cov.l[i==j,value:=value+add.diag]
    }
    
    lines.thetapv <-
        NMcreateMatLines(
            cov.l[par.type.i=="THETA"&par.type.j=="THETA", .(i, j, value, parameter.i, parameter.j, par.type.i,  par.name, par.type.j)]
          , type="THETAPV",as.one.block=TRUE,fix=TRUE)
    
    ## $OMEGAP
    ## note: NMcreateMatLines sets 0 FIXED sigmas/omegas to 1e-30 (if blocksize >1) to avoid non-semi-positive definite matrices error 
    ##    
    pars.random = pars[par.type %in% c("OMEGA","SIGMA")][
        # IF diagonal is fixed to zero, set to a nonzero value.
        , .(par.type,i,j,iblock,FIX,blocksize,SAME,sameblock,Nsameblock, value=ifelse(i==j&FIX==1&value==0,1.0,value))][
            # if SAME, FIX should be 0 because it needs to be left off of 
            #    OMEGAP BLOCK(1) SAME; i.e. can't have :"OMEGAP BLOCK(1) SAME FIX"
            , FIX := ifelse(SAME==1,0,FIX)][
                # if SAME, hack to add "BLOCK(1)" and "BLOCK(1) <value> SAME"
                !is.na(iblock)]
    # for SAME parameters, combine them into one line as "$OMEGAP BLOCK(1) SAME(NN)"
    # if there are 5 occasions then it would look like below:
    #    $OMEGAP BLOCK(1) 0.1 FIX
    #    $OMEGAP BLOCK(1) SAME(4)
    pars.random.same = copy(pars.random)[SAME==1][,head(.SD,n=1),by=sameblock][,value := paste0("BLOCK(1) SAME(",Nsameblock ,")")] 
    
    # for parameters that are the first occasion within a SAME distribution make sure they are written as "$OMEGAP BLOCK(1) <value> FIX"
    # for parameters that are not part of a SAME distribution they will be written as "$OMEGAP <value> FIX"
    # NOTE: the "$OMEGAP"  and "FIX" are added by NMcreateMatLines
    pars.random.notsame = copy(pars.random)[SAME==0][, value := ifelse(sameblock==0,value, paste0("BLOCK(1) ", value))]
    
    # Combine random effects after processing SAME/not SAME parameters
    pars.random = rbind(pars.random.same, pars.random.notsame)[order(par.type,i,j)]
    
    lines.omegap <- NMcreateMatLines(
        pars.random[par.type=="OMEGA"]
       ,type="OMEGAP",as.one.block = FALSE)
    
    ## $OMEGAPD
    # see nwpri_df() for calculations of degrees of freedom for inverse-wishart prior
    lines.omegapd = nwpri_df[par.type=="OMEGA",line]
    
    ## $SIGMAP
    lines.sigmap <- NMcreateMatLines(
        pars.random[par.type=="SIGMA"]
       ,type="SIGMAP")
    
    ## $SIGMAPD
    lines.sigmapd = nwpri_df[par.type=="SIGMA",line]
    
    ## $PRIOR
    lines.prior = sprintf("$PRIOR NWPRI PLEV=%f",PLEV)

    
    all.lines = c(lines.prior, lines.thetap, lines.thetapv, lines.omegap, lines.omegapd, lines.sigmap, lines.sigmapd)

    
    ## insert the lines into file.sim using NMdata::NMwriteSection().  
    ## lines.sim <- NMdata:::NMwriteSectionOne(lines=lines.sim, section="SIMULATION", location="before", newlines=all.lines, backup=FALSE, quiet=TRUE)
    
    lines.sim <- NMwriteSectionOne(lines=lines.sim, section="SIMULATION", location="before", newlines=all.lines, backup=FALSE, quiet=TRUE)

    
### add TRUE=PRIOR to $SIMULATION
    ## lines.sim <- NMdata:::NMwriteSectionOne(lines=lines.sim, section="SIMULATION", location="after", newlines="TRUE=PRIOR", backup=FALSE, quiet=TRUE)
    lines.sim <- NMwriteSectionOne(lines=lines.sim, section="SIMULATION", location="after", newlines="TRUE=PRIOR", backup=FALSE, quiet=TRUE)

### update $SIZES LTH and LVR to reflect the parameters in NWPRI (not resized automatically like other subroutines)
    ## add 10 to both numbers per Bob Bauer (doesn't hurt to have slightly more memory/size)
    ## LTH = number of thetas = $THETA + $THETAP + $OMEGAPD + $SIGMAPD
    ## LVR = number of diagonal omegas + sigmas = $OMEGA + $OMEGAP + $SIGMA + $SIGMAP + $THETAPV
    lth = 2*nrow(pars[par.type=="THETA"]) + nrow(nwpri_df) + 10 
    lvr = 2*nrow(pars[(par.type=="OMEGA"|par.type=="SIGMA")&i==j]) + nrow(pars[par.type=="THETA"]) + 10

    lines.sim = NMwriteSizes(file.mod=NULL, newfile=NULL,lines = lines.sim, LTH = lth, LVR = lvr)
    
### update the simulation control stream
    ## if(return.text){
    ##     return(lines.sim)
    ## }
    
    writeTextFile(lines=lines.sim,file=file.sim)
    
    
    return(file.sim)

}
