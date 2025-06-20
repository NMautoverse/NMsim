---
title: "Reuse simulated subjects"
author: 
  - name: "Philip Delff"
date: '`r format(Sys.Date(), "%B %d, %Y")` using NMsim `r packageVersion("NMsim")`'
toctitle: "Contents"
output:
    html_document:
      toc: true
      toc_depth: 4
      toc_float: true
      number_sections: false
      df_print: kable
      editor_options:
        chunk_output_type: inline
        code_folding: show
bibliography: [packages.bib]
pkgdown:
  as_is: true
---


```{r,include = FALSE }
library(tidyvpc)
library(NMdata)
library(fst)
##knitr::opts_chunk$set(dev = "cairo_pdf")
knitr::opts_chunk$set(
                      collapse = TRUE
                     ,comment = "#>"
                     ,fig.width=7
                     ,cache=FALSE
                  )

## NMdataConf(dir.psn="/opt/psn")

## this changes data.table syntax. I think we can do without.
## knitr::opts_chunk$set(tidy.opts=list(width.cutoff=60), tidy=TRUE)
run.simuls <- FALSE
```

One may prefer to reuse the same
  simulated subjects in multiple simulations for reproducibility and to have all difference
  between say simulation results of different regimens be driven by
  differences in the regimen, and not in the populations. This also
  ensures reproducibilty in case things like number of simulated
  regimens or samples change which can otherwise make the simulation
  engine pull different subjects from one simulation to another.

This vignette still has to be written. The key things to understand are

* `NMsim_known` simulates known subjects based on a phi file. A custom phi file can be supplied.

*  `simPopEtas()` simulates new phi files

So essentially, create a `phi` file with `simPopEtas()` and then use the `NMsim_known` method to use it in new simulations. The `ID`s in the simulation data set must match simulated `ID`s. See [NMsim-known.html](https://philipdelff.github.io/NMsim/articles/NMsim-known.html) for an introduction to the `NMsim_known` method.

We'll just use the simulation data set created in [`NMsim-DataCreate.html`](https://philipdelff.github.io/NMsim/articles/NMsim-DataCreate.html)
```{r}
dat.sim <- read_fst(file="simulate-results/dat_sim.fst")
```


And now we can use `NMsim_known()`.
