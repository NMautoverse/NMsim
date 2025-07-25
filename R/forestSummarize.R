##' Summarize simulated exposures relative to reference subject
##' @param data Simulated data to process. This data.frame must
##'     contain must contain multiple columns, as defined by
##'     `NMsim::forestDefineCovs()`.
##' @param funs.exposure A named list of functions to apply for
##'     derivation of exposure metrics.
##' @param cover.ci The coverage of the confidence intervals. Default
##'     is 0.95.
##' @param by a character vector of column names to perform all
##'     calculations by. This could be sampling subsets or analyte.
##' @param as.fun The default is to return data as a
##'     `data.frame`. Pass a function (say `tibble::as_tibble`) in
##'     as.fun to convert to something else. If data.tables are
##'     wanted, use `as.fun="data.table"`. The default can be
##'     configured using `NMdataConf()`.
##' @details This function is part of the workflow provided by NMsim
##'     to generate forest plots - a graphical representation of the
##'     estimated covariate effects and the uncertainty of those
##'     effect estimates. `forestDefineCovs()` helps construct a set of
##'     simulations to perform, simulation methods like `NMsim_VarCov`
##'     and `NMsim_NWPRI` can perform siulations with parameter
##'     uncertainty, and `forestSummarize()` can then summarize those
##'     simulation results into the numbers to plot in a forest
##'     plot. See the NMsim vignette on forest plot generation
##'     available on the NMsim website for a step-by-step
##'     demonstration.
##'
##' The following columns
##'     are generated by `forestDefineCovs()` and are expected to be
##'     present. Differences within any of them will lead to separate
##'     summarizing (say for as covariate value to be plotted):
##' 
##' \itemize{
##' \item `model`: A model identifier - generated by `NMsim()`.
##' \item `type`: The simulation type. "ref" for reference subject, "value" for any other. This is generated by `forestDefineCovs()`.
##' \item `covvar`: The covariate (of interest) that is different from the reference value in the specific simulation. Example: "WT"
##' \item `covlabel`: Label of the covariate of interest. Example: "Bodyweight (kg)"
##' \item `covref`: Reference value of the covariate of interest. Example: 80
##' \item `covval`: Value of the covariate of interest (not reference). Example 110.
##'}
##' @importFrom stats median reorder setNames
##' @return A data.frame
##' @export

    
forestSummarize <- function(data,funs.exposure,cover.ci=0.95,by,as.fun){
    . <- NULL
    EVID <- NULL
    covlabel <- NULL
    covref <- NULL
    covval <- NULL
    covvalc <- NULL
    covvalf <- NULL
    covvar <- NULL
    median <- NULL
    metric.val <- NULL
    model <- NULL
    ## pred.type <- NULL
    predm <- NULL
    reorder <- NULL
    run.sim <- NULL
    setNames  <- NULL
    type <- NULL
    val.exp.ref <- NULL
    

    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)

    ##if(missing(cols.value)) cols.value <- NULL
    
    ## A standard evaluation interface to data.table::dcast
    dcastSe <- function(data,l,r,...){
        lhs <- paste(l,collapse="+")
        formula.char <- paste(lhs,r,sep="~")
        dcast(data,formula=as.formula(formula.char),...)
    }
    
### this is using model and model.sim as introduced in NMsim 0.1.4
    ## will not work with earlier versions!
    
    ## predefined data columns to calculate by
    databy <- cc(model,type##,pred.type
                ,covvar,covlabel,covref,covval,covvalc)


    
### modelby are NMsim model columns that will be used if found
    ## model.sim should always be present starting from NMsim 0.1.4. NMREP
    ## is in case a method using SUBPROBLEMS is used - like NWPRI.
    modelby <- intersect(c("model.sim","NMREP"),colnames(data))

    
    simres <- as.data.table(data)[EVID==2]

    ## if(is.null(cols.value)){
    ##     databy <- setdiff(databy,"pred.type")
    ## } else {
### The var.conc argument applied
    ## long format so calculations can be done by "prediction type".
    ## simres <- melt(simres,
    ##                measure.vars=cols.value,
    ##                variable.name="pred.type",
    ##                value.name="value")
    ## }

    
    ## allby expands "by" to contain data columns that calculations
    ## will always be done by.
    allby <- c(databy,by)

    
    
    cols.miss <- setdiff(c(allby,"ID"),colnames(simres))
    if(length(cols.miss)){
        stop(paste("The following columns are missing in data. `forestSummarize` is intended to summarize results of simulations defined using `forestDefineCovs()`. Please consult `?forestDefineCovs`. Missing:\n",paste(cols.miss,collapse=",\n")))
    }

    
### summarizing exposure metrics for each subject in each model,
### each combination of covariates
    resp.model <- simres[,lapply(funs.exposure,function(f)f(.SD)),
                         by=c(allby,modelby,"ID")]
    
    
### the exposure metrics in long format.
    mvars <- names(funs.exposure)
    resp.model.l <- melt(resp.model,measure.vars=mvars,variable.name="metric.var",value.name="metric.val")

    
    ## deriving median by model and time to have a single value per model
    ## and time point. This is only needed in case multiple subjects are
    ## simulated by each model.
    sum.res.model <- resp.model.l[
       ,.(predm=median(metric.val))
       ,by=c(modelby,allby,"metric.var")
    ]

    
### making reference value a column rather than rows. 
    ## column with refrence exposure value is called val.exp.ref
    dt.ref <- setnames(
        sum.res.model[type=="ref",c(modelby,"metric.var",setdiff(allby,c("covval","covvalc","type")),"predm"),with=FALSE]
       ,"predm","val.exp.ref")
    ## these columns are not necessarily in refr columns. If not, drop them before merge.
    dt.miss <- dt.ref[,lapply(.SD,function(x)all(is.na(x))),.SDcols=c("covvar","covlabel","covref")]
    cols.miss <- colnames(dt.miss[,as.logical(colSums(dt.miss)),with=FALSE])
    if(length(cols.miss)){
        dt.ref <- dt.ref[,!(cols.miss),with=FALSE]
    }
    
    sum.res.model <- mergeCheck(sum.res.model[type=="value"],
                                dt.ref
                               ,
                                by=c(modelby,"metric.var",setdiff(allby,c("covval","covvalc","type",cols.miss))),
                                fun.na.by=NULL,
                                quiet=TRUE
                                )

    
### summarize distribution of ratio to ref across parameter samples/models
    sum.uncertain <- sum.res.model[
       ,setNames(as.list(quantile(predm/val.exp.ref,probs=c((1-cover.ci)/2,.5,1-(1-cover.ci)/2),na.rm=TRUE)),
                 c("predml","predmm","predmu"))
       ,by=c(allby,"metric.var")]
### check whether NA's were produced by quantile
    
    if(any(unlist(
        sum.uncertain[,lapply(.SD,function(x)any(is.na(x))),.SDcols=c("predml","predmm","predmu")]
    ))){
        if(sum.res.model[,any(val.exp.ref==0)]){
            warning("NA's produced. There are 0's in the reference exposures which may be the reason.")
        } else {
            warning("NA's produced. 0's not found in the reference exposures.")
        }
    }

    

### Section end: Summarize exposure metrics vs covariates
    ## A factor representation of covariate values - only based on the remainding values - not reference
    
    cnames <- copy(colnames(sum.uncertain))
    
    cname.cvc <- which(cnames=="covvalc")
    nnames <- length(cnames)
    sum.uncertain[,covvalf:=reorder(covvalc,covval)]
    neworder <- c(cnames[1:cname.cvc],"covvalf",cnames[(cname.cvc+1):nnames])
    setcolorder(sum.uncertain,neworder)

    as.fun(sum.uncertain)
}
