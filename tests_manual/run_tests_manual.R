library(testthat)
library(NMsim)

## library(devtools)
## test_dir("testthat/")
##
load_all("~/wdirs/NMsim",export_all = FALSE)
test_file("testthat/test_NMsim.R")
