cleaningPatterns <- function(clean){
    if(! clean %in% 1:4){
        stop ("only clean values 1, 2, 3, and 4 are supported")
    }
    c("FSUBS*","FCON","INTER",
"LINKC.LNK",
"LINK.LNK",
"PRSIZES.f90"
,"gfortran.txt","nonmem","worker*","FDATA*","fort.*","WK_*","temp_dir","thetair.f90","nmprd4p.mod")




}
