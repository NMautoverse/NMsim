## ----include = FALSE----------------------------------------------------------
##knitr::opts_chunk$set(dev = "cairo_pdf")
knitr::opts_chunk$set(
                      collapse = TRUE
                     ,comment = "#>"
                     ,fig.width=7
                     ,cache=FALSE
                  )

## this changes data.table syntax. I think we can do without.
## knitr::opts_chunk$set(tidy.opts=list(width.cutoff=60), tidy=TRUE)

## ----eval=FALSE---------------------------------------------------------------
#  NMdataConf(path.nonmem="/opt/NONMEM/nm75/run/nmfe")

## ----eval=FALSE---------------------------------------------------------------
#  NMdataConf(dir.psn="/opt/PSN")

