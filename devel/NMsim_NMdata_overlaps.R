library(data.table)
library(NMdata)
library(diffr)
## library(waldo)

## firefox from snap can't read /tmp
diffr_newdir <- function(file1, file2, parent_dir = tempdir(),
                         open = TRUE, clean = FALSE, ...) {
  ## 1. Ensure parent dir exists
  if (!dir.exists(parent_dir)) {
    stop("Parent directory does not exist: ", parent_dir)
  }
  
  ## 2. Create a guaranteed fresh subdirectory
  tmpdir <- file.path(parent_dir, paste0("diffr_", format(Sys.time(), "%Y%m%d_%H%M%S_"),sprintf("%04d",sample(1:1e4-1,size=1))))
  dir.create(tmpdir, recursive = TRUE)
  
  ## 3. Run diffr and save output
  diff_widget <- diffr::diffr(file1, file2, ...)
  out_file <- file.path(tmpdir, "index.html")
  htmlwidgets::saveWidget(diff_widget, out_file, selfcontained = TRUE)
  
  ## 4. Optionally open in browser
  if (open) {
      utils::browseURL(out_file)
  }
  
  ## 5. Optionally clean up afterwards
  if (clean) {
    unlink(tmpdir, recursive = TRUE, force = TRUE)
  }
  
  invisible(out_file)
}


dir.NMsim <- "~/wdirs/NMsim/R"
dir.NMData <- "~/wdirs/NMsim/R"

dt.pkgs <- data.table(pkg=cc(NMsim,NMdata))[
   ,dir:=sprintf("~/wdirs/%s/R",pkg)][]

dt.files <- dt.pkgs[,.(file=list.files(dir)),by=pkg]
dt.files <- dt.files[file!="zzz.R"]
dt.files[,N:=.N,by=.(file)]

dt.files <- mergeCheck(dt.files,dt.pkgs,by="pkg")
dt.files[,fpath:=file.path(dir,file)]

dtf.w <- dt.files[N>1] |>
    dcast(file~pkg,value.var="fpath")

dtf.w

path.expand("~/tmp")

res.list <- lapply(1:nrow(dtf.w),function(row){
    ## diffr(dtf.w[row,NMsim],dtf.w[row,NMdata])
    diffr_newdir(dtf.w[row,NMsim],dtf.w[row,NMdata],parent_dir=path.expand("~/tmp"),
                 open=FALSE)

    ## waldo::compare(readLines(dtf.w[row,NMsim]),
    ##                readLines(dtf.w[row,NMdata]),
    ##                x_arg=paste(dtf.w[row,file],"NMsim"),
    ##                y_arg=paste(dtf.w[row,file],"NMdata")
    ##                )
    
})


## Maybe NMwriteSection belongs better in NMsim?
## NMctl. Belongs in NMdata. NMdata 0.2.2 required.
## NMextractText. Belongs in NMdata. NMdata 0.2.2 required.
## NMreadFilters. Belongs in NMdata. NMdata 0.2.2 required.
## NMreadInits. Belongs in NMdata. NMdata 0.2.2 required.
## addParType+addParameter. Belongs in NMdata (internal). Requires NMdata 0.2.2.
## fnAppend. Belongs in NMdata (internal). Requires NMdata 0.2.2. (collapse arg)
## NMreadSection. Belongs in NMdata. NMdata 0.2.2 required.
## NMwriteSectionOne. Belongs in NMdata. NMdata 0.2.2 required. 

## NMwriteFilters. Belongs in NMsim (internal). Dropped in NMdata 0.2.1.
## NMwriteInits. Belongs in NMsim (internal). Dropped in NMdata 0.2.1.
## NMwriteInitsOne. Belongs in NMsim (internal). Dropped in NMdata 0.2.1.

## addBlocks. Belongs in NMdata (internal). Requires NMdata 0.2.1. Dropped in NMsim 0.2.6

## dtapply and lapplydt belong in NMdata

length(res.list)
utils::browseURL(res.list[[1]],browser="firefox")
utils::browseURL(res.list[[2]],browser="firefox")
res.list[[2]]
res.list[[3]]
res.list[[4]]
res.list[[5]]
res.list[[6]]
res.list[[7]]
lapply(res.list,utils::browseURL,browser="firefox")


## for(I
##     res <- dtf.w[,list(diffr(NMdata,NMsim)),by="file"]



##     dt.overlap <- dt.files[,.N,by=.(file)][N>1]

##     library(tools)
##     dt.overlap[,md5sum()]



##     |>
##     dcast(V1~pkg)

##     dir=
##         list.
## )
