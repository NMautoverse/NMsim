
## res1 <- NCAsim(file.mod="/data/prod_vx993_phase1_analysis/trunk/analysis/popPK_prelim/VX993_003/models/run230.mod",covs=list(FED=0),cmt.dos=1,cmt.obs=2)

dt.cmt <- data.table(
    compound=cl("VX-548","M6-548"),
    ## comp=c("CP","CM"),
        PARENT=c(1,0),
    ## METAB=c(0,1),
        CMT=c(2,4)
    )
res1 <- NCAsim(file.mod="/data/prod_vx548_phase3_analysis/trunk/analysis/NDA/models/PK/2822/2822.mod",covs=list(TAB=1,ABD=0,AGE=50,BMIBLI=30,WTBLI=80,MALE=0),cmt.dos=1,cmt.obs=dt.cmt,by=cc("compound"))

NCAsim <- function(file.mod,amt=50e3,by=NULL,covs,cmt.dos=1,cmt.obs=2){

    
    file.lst <- fnExtension(file.mod,"lst")
    ## automated
    ## file.mod <- fnExtension(file.lst,"mod")
    run.model <- basename(file.mod) |> fnExtension("")
    label.mod  <- file.path(dir.main,file.mod) |> sub(pattern="^ */data/",replacement="")


    dt.covs <- do.call(data.table,covs)
    allby <- c(by,colnames(dt.covs))

    dt.dos <- NMcreateDoses(TIME=0,AMT=amt,RATE=-2,CMT=cmt.dos)
    ## dt.dos[,DOSESSN:=AMT/1000]

    dt.dos <- egdt(dt.dos,dt.covs,quiet=TRUE)
    dt.dos[,ID:=.I]

    time.sim <- unique(c(seq(0,5,.005),seq(0,24*8)))
    dt.sim <- addEVID2(dt.dos,time.sim=time.sim,CMT=cmt.obs)
    ## this is because many models need PDOSAMT
    dt.sim <- addTAPD(dt.sim)


    ### we need two approaches. one that identifies number of
    ### compartments and adds one. One that converts an ADVAN4 to an
    ### ADVAN13.
    simres.sd <- NMsim(file.mod=file.mod,
                       data=dt.sim,
                       method.sim=NMsim_typical,
                       list.sections=list(MODEL=function(x)c(x,"COMP=ABSD")
                                         ,DES=function(x)c(x,"DADT(7)=-DADT(1)")
                                         ,ERROR=function(x)c(x,"ABSD=A(7)")
                                          )
                      ,table.vars="PRED IPRED ABSD"
                       )

### will also need MAD

### need IV for MRT?


#### simulation-based derivation
    ## Need a plot of what was simulated so we can check that the full
    ## profile is captured for MRT and absorption densely sampled.


    ## MAT. This only makes sense for parent
    sres2 <- simres.sd[EVID==2,.(TIME,ABSDnorm=ABSD/max(ABSD))
                      ,by=allby]
    
    dt.mat <- sres2[,.(MAT=trapez(TIME,(1-ABSDnorm))),by=allby]

    ## MRT
    dt.mrt <- simres.sd[EVID==2,.(
                                     AUC=trapez(TIME,PRED)
                                    ,AUMC=trapez(TIME,PRED*TIME)
                                 ),by=allby][,MRT:=AUMC/AUC]

    dt.mrt


    ## terminal half life. Plot only after MRT
    if(F){
        ggplot(simres.sd[TIME>1],aes(TIME,PRED,colour=factor(TAB)))+
            geom_line() +
            scale_y_log10()+
            facet_wrap(~compound)
    }

    thalf.obs <- function(t,y){
        k <- log(max(y)/min(y))/(max(t)-min(t))
        thalf <- log(2)/k
        thalf
    }
    tab.thalf <- simres.sd[EVID==2&TIME>130&TIME<180,.(Thalf=thalf.obs(TIME,PRED)),by=allby]

    data.table:::rbind.data.table(dt.mat,dt.mrt,tab.thalf,fill=T)

}
