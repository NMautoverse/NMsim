##' Simulate from a Nonmem model
##'
##' Supply a data set and an estimation input control stream, and
##' NMsim can create neccesary files (control stream, data files), run
##' the simulation and read the results. It has additional methods for
##' other simulation types available, can do multiple simulations at
##' once and more. Please see vignettes for an introduction to how to
##' get the most out of this.
##'
##' @param file.mod Path(s) to the input control stream(s) to run the simulation
##'   on. The output control stream is for now assumed to be stored next to the
##'   input control stream and ending in .lst instead of .mod. The .ext file
##'   must also be present. If simulating known subjects, the .phi is necessary
##'   too.
##' @param data The simulation data as a \code{data.frame} or a list of
##'   \code{data.frame}s. If a list, the model(s) will be run on each of the
##'   data sets in the list.
##' @param dir.sims The directory in which NMsim will store all generated files.
##'   Default is to create a folder called `NMsim` next to `file.mod`.
##' @param dir.res Provide a path to a directory in which to save rds files with
##'   paths to results. Default is to use dir.sims. After running `NMreadSim()`
##'   on these files, the original simulation files can be deleted. Hence,
##'   providing both `dir.sims` and `dir.res` provides a structure that is
##'   simple to clean. `dir.sims` can be purged when `NMreadSim` has been run
##'   and only small `rds` and `fst` files will be kept in `dir.res`. Notice, in
##'   case multiple models are simulated, multiple `rds` (to be read with
##'   `NMreadSim()`) files will be created by default. In cases where multiple
##'   models are simulated, see `file.res` to get just one file refering to all
##'   simulation results.
##' @param name.sim Give all filenames related to the simulation a suffix. A
##'   short string describing the sim is recommended like "ph3_regimens".
##' @param subproblems Number of subproblems to use as \code{SUBPROBLEMS} in
##'   \code{$SIMULATION} block in Nonmem. The default is subproblem=0 which
##'   means not to use \code{SUBPROBLEMS}.
##' @param table.vars Variables to be printed in output table as a character
##'   vector or a space-separated string of variable names. The default is to
##'   export the same tables as listed in the input control stream. If
##'   \code{table.vars} is provided, all output tables in estimation control
##'   streams are dropped and replaced by a new one with just the provided
##'   variables. If many variables are exported, and much fewer are used, it can
##'   speed up NMsim significantly to only export what is needed (sometimes this
##'   is as little as "PRED IPRED"). Nonmem writes data slowly so reducing
##'   output data can make a very big difference in execution time. See
##'   \code{table.options} too.
##' @param table.options A character vector or a string of space-separated
##'   options. Only used if \code{table.vars} is provided. If constructing a new
##'   output table with \code{table.vars} the default is to add two options,
##'   \code{NOAPPEND} and \code{NOPRINT}. You can modify that with
##'   \code{table.options}. Do not try to modify output filename - \code{NMsim}
##'   takes care of that. See `table.format` too.
##' @param table.format A format for `$TABLE`. Only used if `table.vars` is
##'   provided. Default is "s1PE16.9". NMsim needs a high-resolution format. The
##'   Nonmem default "s1PE11.4" is insufficient for simulation data sets of 1e5
##'   rows or more.
##' @param carry.out Variables from input data that should be included in
##'   results. Default is to include everything. If working with large data
##'   sets, it may be wanted to provide a subset of the columns here. If doing
##'   very large simulations, this may also be a way to save memory. Notice,
##'   `table.vars` must be provided to use carry.out.
##' @param reuse.results If simulation results found on file, should they be
##'   used? If TRUE and reading the results fail, the simulations will still be
##'   rerun.
##' @param transform A list defining transformations to be applied after the
##'   Nonmem simulations and before plotting. For each list element, its name
##'   refers to the name of the column to transform, the contents must be the
##'   function to apply.
##' @param seed.R A value passed to \code{set.seed()}. It is recommended to use
##'   \code{seed.R} rather than calling \code{set.seed()} manually because the
##'   seed can then be captured and stored by \code{NMsim()} for
##'   reproducibility. See \code{seed.nm} for finer control of the seeds that
##'   are used in the Nonmem control streams.
##' @param seed.nm Control Nonmem seeds. If a numeric, a vector or a
##'   `data.frame`, these are used as the the seed values (a single value or
##'   vector will be recycled so make sure the dimesnsions are right, the number
##'   of columns in a \code{data.frame} will dictate the number of seeds in each
##'   Nonmem control stream. Use a list with elements `values`, and `dist` and
##'   others for detailed control of the random sources. See \code{?NMseed} for
##'   details on what arguments can be passed this way.
##'
##' Default is to draw seeds betwen
##'     0 and 2147483647 (the values supported by Nonmem) for each
##'     simulation. You can pass a function that will be evaluated
##'     (say to choose a different pool of seeds to draw from).
##'
##' To avoid changing an exisiting seed in a control stream, use
##' \code{seed.nm="asis"} or \code{seed.nm="FALSE"}.
##'
##' In case \code{method.sim=NMsim_EBE}, seeds are not used.
##'
##' @param script The path to the script where this is run. For
##'     stamping of dataset so results can be traced back to code.
##' @param text.sim A character string to be pasted into
##'     $SIMULATION. This must not contain seed or SUBPROBLEM which is
##'     handled separately. Default is to include "ONLYSIM". You
##'     cannot avoid that using `text.sim`. If needed, you can use
##'     `onlysim=FALSE` which will be passed to `NMsim_default()`.
##' @param method.sim A function (not quoted) that creates the
##'     simulation control stream and other necessary files for a
##'     simulation based on the estimation control stream, the data,
##'     etc. The default is called \code{NMsim_default} which will
##'     replace any estimation and covariance step by a simulation
##'     step. See details section on oter methods, and see examples
##'     and especially vignettes on how to use the different provided
##'     methods.
##' @param typical Run with all ETAs fixed to zero? Technically all
##'     ETAs=0 is obtained by replacing \code{$OMEGA} by a zero
##'     matrix. Default is `FALSE`. Instead of a logical `TRUE/FALSE`,
##'     a character vector can be used to specify what parameter types
##'     to set to zero and fix. Examples:
##'     `typical=c("OMEGA","SIGMA")`,
##'     `typical=c("THETAPV","OMEGA","OMEGAP","OMEGAPD")`. In fact, if
##'     `typical=TRUE`, both `$OMEGA` itself and - if found - their
##'     priors will be fixed at zero.
##' @param inits Control the parameter values. `inits` is a list and
##'     contains (any of) the `method` used to edit the parameters,
##'     and what modifications to do.
##'
##' Using the defaul `method`, all other list elements are passed as
##' arguments to `NMwriteInits()`. Please see `?NMwriteInits` and the
##' examples on the NMsim website for how to edit the parameter
##' values:
##' \url{https://nmautoverse.github.io/NMsim/articles/NMsim-modify-model.html}
##'
##' The `method` element controls which method is used to do this, and
##'     this corresponds to the old `method.update.inits`
##'     argument. Normally, the user should not need to deal with this
##'     as the default `nmsim` method is very flexible and
##'     powerful. If using the new `method=nmsim` you can specify
##'     parameter values, fix/unfix them, and edit lower and upper
##'     limits for estimation.  \itemize{
##'
##' \item{`method="nmsim"`} (default) A highly flexible internal
##'      method, allows for modification of the parameter values. All
##'      other elements in `inits` are passed to
##'      `NMwriteInits()`. Example where `THETA(2)` is customized:
##'      `inits=list("THETA(2)"=list(init=1.3))`. See `?NMwriteInits`
##'      too.
##' 
##' \item{`method="psn"`}
##'     Uses PSN's "update_inits". Requires a functioning PSN
##'     installation and possibly that \code{dir.psn} is correctly
##'     set. The advantages of this method are that it keeps comments
##'     in the control stream and that it is a method known to many.
##'
##' \item{`method="simple"`} Uses a simple internal method to
##'  update the parameter values based on the ext file.  The
##'  advantages are it does not require PSN, and that it does not rely
##'  on code-interpretation for generation of simulation control
##'  streams. "simple" fixes the whole OMEGA and SIGMA matrices
##'  as single blocks which is robust because it avoids any
##'  interpretation of BLOCK structure or other code in the control
##'  streams. The downside is it strips all comments, and generally
##'  makes the $OMEGA and $SIGMA sections of the simulation control
##'  streams less easy to read. "simple" can be used as a
##'  fallback in case of any issues with `method="nmsim"`.
##'
##' \item{`method="none"`} Do nothing. This is useful if the model to simulate
##' has not been estimated but parameter values have been manually put
##' into the respective sections in the control stream.
##' }
##' 
##' See also `file.ext` which can now be handled by `inits` too. This
##' change collects the update of the "initial" parameter values into
##' one interface rather than multiple arguments.
##' @param modify Named list of additional control stream section
##'     edits. Note, these can be functions that define how to edit
##'     sections. This is an advanced feature which is not needed to
##'     run most simulations. It is however powerful for some types of
##'     analyses, like modifying parameter values. See vignettes for
##'     further information.
##' @param filters Edit data filters (`IGNORE`/`ACCEPT` statements)
##'     before running model. This should normally only be used if no
##'     data set is provided. It can be useful if simulating for a VPC
##'     but a different subset of data needs to be simulated than the
##'     one used for estimation. A common example on this is inclusion
##'     of BLQ's in the VPC even if they were excluded in the
##'     estimation. See `?NMreadFilters` which returns a table you can
##'     edit and pass to `filters`. You can also just pass a string
##'     representing the full set of filters to be used. If you pass a
##'     string, consider including "IGN=@" to avoid character rows,
##'     like the column headers.
##' @param sizes If needed, adjust the `$SIZES` section by providing a
##'     list of arguments to `NMupdateSizes()`. Example:
##'     `sizes=list(PD=80)`. See `?NMupdateSizes` for details. Don't
##'     use arguments like `file.mod` and `newfile` which are handled
##'     internally.
##' @param execute Execute the simulation or only prepare it?
##'     `execute=FALSE` can be useful if you want to do additional
##'     tweaks or simulate using other parameter estimates.
##' @param sge Submit to cluster? Default is not to, but this is very
##'     useful if creating a large number of simulations,
##'     e.g. simulate with all parameter estimates from a bootstrap
##'     result.
##' @param nc Number of cores used in parallelization. Only used if
##'     `sge=TRUE`.
##' @param wait Wait for simulations to finish? Default is to do so if
##'     simulations are run locally but not to if they are sent to the
##'     cluster. Waiting for them means that the results will be read
##'     when simulations are done. If not waiting, path(s) to `rds`
##'     files to read will be returned. Pass them through
##'     `NMreadSim()`. Conveniently, NMreadSim() also takes the `wait`
##'     argument too, allowing flexibility to run Nonmem in the
##'     background, and then read the results, still waiting for
##'     Nonmem to finish.
##' @param order.columns reorder columns by calling
##'     \code{NMdata::NMorderColumns} before saving dataset and
##'     running simulations? Default is TRUE.
##' @param method.execute Specify how to call Nonmem. Options are
##'     "psn" (PSN's execute), "nmsim" (an internal method similar to
##'     PSN's execute), and "direct" (just run Nonmem directly and
##'     dump all the temporary files). "nmsim" has advantages over
##'     "psn" that makes it the only supported method when
##'     type.sim="NMsim_EBE". "psn" has the simple advantage that the
##'     path to nonmem does not have to be specified if "execute" is
##'     in the system search path. So as long as you know where your
##'     Nonmem executable is, "nmsim" is recommended. The default is
##'     "nmsim" if path.nonmem is specified, and "psn" if not.
##' @param nmfe.options additional options that will be passed to
##'     nmfe. It is only used when path.nonmem is available (directly
##'     or using `NMdataConf()`). Default is "-maxlim=2" For PSN, see
##'     `args.psn.execute`.
##' @param args.psn.execute A charachter string that will be passed as
##'     arguments PSN's `execute`. The default is
##'     "-model_dir_name -nm_output=coi,cor,cov,ext,phi,shk,xml -nmfe_options=\"-maxlim=2\""
##'     in addition to the "-clean" based on the `clean`
##'     argument. Notice, if `path.nonmem` is provided, the default is
##'     not to use PSN.
##' @param path.nonmem The path to the Nonmem executable to use. The
##'     could be something like "/usr/local/NONMEM/run/nmfe75" (which
##'     is a made up example). No default is available. You should be
##'     able to figure this out through how you normally execute
##'     Nonmem, or ask a colleague.
##' @param dir.psn The directory in which to find PSN's executables
##'     ('execute' and 'update_inits'). The default is to rely on the
##'     system's search path. So if you can run 'execute' and
##'     'update_inits' by just typing that in a terminal, you don't
##'     need to specify this unless you want to explicitly use a
##'     specific installation of PSN on your system.
##' @param nmrep Include `NMREP` as counter of subproblems? The
##'     default is to do so if `subproblems>0`. This will insert a
##'     counter called `NMREP` in the `$ERROR` section and include
##'     that in the output table(s). At this point, nothing is done to
##'     avoid overwriting existing variables.
##' @param col.flagn Only used if `data` is provided. Use this if you
##'     are including an exclusion flag column in data. However, what
##'     NMsim will then do is to require that column to equal `0`
##'     (zero) for the rows to be simulated. It is often better to
##'     subset the data before simulation. See `filters` too.
##' @param create.dirs If the directories specified in dir.sims and
##'     dir.res do not exists, should it be created? Default is TRUE.
##' @param sim.dir.from.scratch If TRUE (default) this will wipe the
##'     simulation directory before running new simulations. The
##'     directory that will be emptied is _not_ dir.sims where you may
##'     keep many or all your simulations. It is the subdirectory
##'     named based on the run name and \code{name.sim}. The reason it
##'     is advised to wipe this directory is that if you in a previous
##'     simulation created simulation runs that are now obsolete, you
##'     could end up reading those too when collecting the
##'     results. NMsim will delete previously generated simulation
##'     control streams with the same name, but this option goes
##'     further. An example where it is important is if you first ran
##'     1000 replications, fixed something and now rand 500. If you
##'     choose FALSE here, you can end up with the results of 500 new
##'     and 500 old simulations.
##' @param auto.dv Add a column called `DV` to input data sets if a
##'     column of that name is not found? Nonmem is generally
##'     dependent on a `DV` column in input data but this is typically
##'     uninformative in simulation data sets and hence easily
##'     forgotten when generating simulation data sets. If
##'     \code{auto.dv=TRUE} and no `DV` column is found, `DV=NA` will
##'     be added. In this case (`auto.dv=TRUE` and no `DV` column
##'     found) a `MDV=1` column will also be added if none found.
##' @param file.res Path to an rds file that will contain a table of
##'     the simulated models and other metadata. This is needed for
##'     subsequently retrieving all the results using
##'     `NMreadSim()`. The default is to create a file called
##'     `NMsim_..._MetaData.rds` under the \code{dir.res} directory
##'     where ... is based on the model name. However, if multiple
##'     models (\code{file.mod}) are simulated, this will result in
##'     multiple rds files. Specifying a path ensures that one rds
##'     file containing information about all simulated models will be
##'     created. Notice if \code{file.res} is supplied, \code{dir.res}
##'     is not used.
##' @param dir.sim.sub If `TRUE` (default) a dedicated subdirectory
##'     will be created for eac model run. This is normally the
##'     cleanest way to run simulations. However, when `NMsim()` is
##'     used for estimation, it may be better to provide model results
##'     in the same folder as the input control stream (like PSN would
##'     do). Use `dir.sim.sub=FALSE` to get this behavior.
##' @param clean The degree of cleaning (file removal) to do after
##'     Nonmem execution. If `method.execute=="psn"`, this is passed
##'     to PSN's `execute`. If `method.execute=="nmsim"` a similar
##'     behavior is applied, even though not as granular. NMsim's
##'     internal method only distinguishes between 0 (no cleaning),
##'     any integer 1-4 (default, quite a bit of cleaning) and 5
##'     (remove temporary dir completely).
##' @param quiet If TRUE, messages from what is going on will be
##'     suppressed.
##' @param nmquiet Silent console messages from Nonmem? The default
##'     behaviour depends. It is FALSE if there is only one model to
##'     execute and `progress=FALSE`.
##' @param progress Track progress? Default is `TRUE` if `quiet` is
##'     FALSE and more than one model is being simulated. The progress
##'     tracking is based on the number of models completed, not the
##'     status of the individual models.
##' @param check.mod Check the provided control streams for contents
##'     that may cause issues for simulation. Default is `TRUE`, and
##'     it is only recommended to disable this if you are fully aware
##'     of such a feature of your control stream, you know how it
##'     impacts simulation, and you want to get rid of warnings.
##' @param as.fun The default is to return data as a data.frame. Pass
##'     a function (say `tibble::as_tibble`) in as.fun to convert to
##'     something else. If data.tables are wanted, use
##'     as.fun="data.table". The default can be configured using
##'     NMdataConf.
##' @param args.NMscanData If \code{execute=TRUE&sge=FALSE}, NMsim
##'     will normally read the results using \code{NMreadSim}. Use
##'     this argument to pass additional arguments (in a list) to that
##'     function if you want the results to be read in a specific
##'     way. This can be if the model for some reason drops rows, and
##'     you need to merge by a row identifier. You would do
##'     `args.NMscanData=list(col.row="ROW")` to merge by a column
##'     called `ROW`. This is only used in rare cases.
##' @param system.type A charachter string, either "windows" or
##'     "linux" - case insensitive. Windows is only experimentally
##'     supported. Default is to use \code{Sys.info()[["sysname"]]}.
##' @param format.data.complete For development purposes - users do
##'     not need this argument. Controls what format the complete
##'     input data set is saved in.  Possible values are `rds`
##'     (default), `fst` (experimental) and `csv`. `fst` may be faster
##'     and use less disk space but factor levels may be lost from
##'     input data to output data. `csv` will also lead to loss of
##'     additional information such as factor levels.
##' @param ... Additional arguments passed to \code{method.sim}.
##' @param modify.model Deprecated. Use modify instead.
##' @param list.sections Deprecated. Use modify instead.
##' @param method.update.inits Deprecated, please migrate to `inits`
##'     instead. The initial values of all parameters are by updated
##'     from the estimated model before running the simulation. NMsim
##'     can do this with a native function or use PSN to do it - or
##'     the step can be skipped to not update the values.
##' @param file.ext Deprecated. Use
##'     `inits=list(file.ext="path/to/file.ext")` instead. Optionally
##'     provide a parameter estimate file from Nonmem. This is
##'     normally not needed since `NMsim` will by default use the ext
##'     file stored next to the input control stream (replacing the
##'     file name extension with `.ext`). If using
##'     method.update.inits="psn", this argument cannot be used.
##' @param suffix.sim Deprecated. Use name.sim instead.
##' @param text.table Deprecated. Use `table.vars` and `table.options`
##'     instead.
##' @param seed Deprecated. See \code{seed.R} and \code{seed.nm}.
##' @return A data.frame with simulation results (same number of rows
##'     as input data). If `sge=TRUE` a character vector with paths to
##'     simulation control streams.
##' @details Loosely speaking, the argument \code{method.sim} defines
##'     _what_ NMsim will do, \code{method.execute} define _how_ it
##'     does it. \code{method.sim} takes a function that converts an
##'     estimation control stream into whatever should be
##'     run. Features like replacing `$INPUT`, `$DATA`, `$TABLE`, and
##'     handling seeds are NMsim features that are done in addition to
##'     the \code{method.sim}. Also the \code{modeify.model} argument
##'     is handled in addition to the \code{method.sim}. The
##'     \code{subproblems} and \code{seed.nm} arguments are available
##'     to all methods creating a \code{$SIMULATION} section.
##'
##' Notice, the following functions are internally available to
##' `NMsim` so you can run them by say \code{method.sim=NMsim_EBE}
##' without quotes. To see the code of that method, type
##' \code{NMsim_EBE}.
##' 
##' \itemize{
##' 
##' \item \code{NMsim_default} The default behaviour. Replaces any
##' $ESTIMATION and $COVARIANCE sections by a $SIMULATION section.
##'
##' \item \code{NMsim_asis} The simplest of all method. It does nothing (but
##' again, \code{NMsim} handles `$INPUT`, `$DATA`, `$TABLE` and
##' more. Use this for instance if you already created a simulation
##' (or estimation actually) control stream and want NMsim to run it
##' on different data sets.
##'
##' 
##' \item \code{NMsim_EBE} Simulates _known_ ETAs. By default, the ETA
##' values are automatically taken from the estimation run. This is
##' what is refered to as emperical Bayes estimates, hence the name of
##' the method "NMsim_EBE". However, the user can also provide a
##' different `.phi` file which may contain simulated ETA values (see
##' the `file.phi` argument). ID values in the simulation data set
##' must match ID values in the phi file for this step to work. If
##' refering to estimated subjects, the .phi file from the estimation
##' run must be found next to the .lst file from the estimation with
##' the same file name stem (say `run1.lst` and `run1.phi`). Again, ID
##' values in the (simulation) input data must be ID values that were
##' used in the estimation too. The method Runs an \code{$ESTIMATION
##' MAXEVAL=0} but pulls in ETAs for the ID's found in data. No
##' \code{$SIMULATION} step is run which unfortunately means no
##' residual error will be simulated.
##'
##' \item \code{NMsim_VarCov} Like \code{NMsim_default} but `$THETA`,
##' `$OMEGA`, and `SIGMA` are drawn from distribution estimated in
##' covariance step. This means that a successful covariance step must
##' be available from the estimation. NB. A multivariate normal
##' distribution is used for all parameters, including `$OMEGA` and
##' `$SIGMA` which is not the correct way to do this. In case the
##' simulation leads to negative diagonal elements in $OMEGA and
##' $SIGMA, those values are truncated at zero. This method is only
##' valid for simulation of `$THETA` variability. The method accepts a
##' table of parameter values that can be produced with other tools
##' than `NMsim`. For simulation with parameter variability based on
##' bootstrap results, use \code{NMsim_default}.
##'
##' }
##' @import NMdata
##' @import data.table
##' @import utils 
##' @importFrom xfun relative_path
##' @export


NMsim <- function(file.mod,data,
                  subproblems=NULL,
                  seed.R,
                  seed.nm,
                  name.sim,
                  table.vars,
                  table.options,
                  table.format="s1PE16.9",
                  carry.out=TRUE,
                  method.sim=NMsim_default,
                  typical=FALSE,
                  inits,
                  modify,
                  filters,
                  sizes,
                  path.nonmem=NULL,
                  sge=FALSE,
                  nc=1,
                  reuse.results=FALSE,
                  recycle=FALSE,
                  execute=TRUE,
                  script=NULL,
                  transform=NULL,
                  order.columns=TRUE,
                  method.execute,
                  nmfe.options,
                  nmrep,
                  col.flagn=FALSE,
                  dir.psn,
                  args.psn.execute,
                  args.NMscanData,
                  as.fun,
                  system.type=NULL,
                  dir.sims,
                  dir.res,
                  file.res,
                  dir.sim.sub=TRUE,
                  wait,
                  text.sim="",
                  auto.dv=TRUE,
                  clean,
                  sim.dir.from.scratch=TRUE,
                  create.dirs=TRUE,
                  quiet=FALSE,
                  nmquiet,
                  progress,
                  check.mod = TRUE,
                  format.data.complete="rds",
                  ### deprecated
                  text.table,
                  suffix.sim,
                  seed,
                  file.ext=NULL,
                  method.update.inits,
                  modify.model,
                  list.sections,
                  ...
                  ){

  ## recycle
  ## Capture all arguments except recycle-specific ones
  
  all.args.call <- as.list(environment())
  all.args.call <- c(all.args.call,list(...))
  
  ## all.args.call <- all.args.call[!sapply(all.args.call,is.name)]
  all.args.call[sapply(all.args.call,is.name)] <- NULL
  ## names(all.args.call)
  ## library(recycle)

  if(F){
    ## this can be done by check_need_run() later
    library(devtools)
    load_all("~/wdirs/recycle")
    digests.args.call <- digest_elements(all.args.call,
                                         funs.unwrap=list(file.mod=function(x)readLines(x,warn=FALSE)
                                                          )
                                         )
  }

  #### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####
  
  . <- NULL
  ..carry.out <- NULL
  ..dir.res <- NULL
  ..name.sim <- NULL
  col.row <- NULL
  DATAROW <- NULL
  data.name <- NULL
  default <- NULL
  direct <- NULL
  directory <- NULL
  dir.data.sim <- NULL
  dir.sim <- NULL
  DV <- NULL
  est <- NULL
  fast.tables <- NULL
  fn.data <- NULL
  f.exists <- NULL
  fn.sim.predata <- NULL
  files.needed <- NULL
  files.res <- NULL
  fn.sim.tmp <- NULL
  fn <- NULL
  fn.mod <- NULL
  fn.sim <- NULL
  funs.transform <- NULL
  i <- NULL
  ID <- NULL
  is.data <- NULL
  known <- NULL
  lst <- NULL
  MDV <- NULL
  model <- NULL
  model.sim <- NULL
  mod <- NULL
  n <- NULL
  ## name.mod <- NULL
  NEWMODEL <- NULL
  nmsim <- NULL
  NMsimTime <- NULL
  NMsimVersion <- NULL
  n.fn.sim <- NULL
  none <- NULL
  psn <- NULL
  par.type <- NULL
  path.mod.exec <- NULL
  path.rds <- NULL
  path.results <- NULL
  pathResFromists <- NULL
  pathResFromSims <- NULL
  pathSimsFromRes <- NULL
  path.sim <- NULL
  path.digests <- NULL
  path.sim.lst <- NULL
  path.data <- NULL
  path.rds.exists <- NULL
  ROW <- NULL
  ROWMODEL <- NULL
  ## ROWMODEL2 <- NULL
  ## rowtmp <- NULL
  ##    run.mod <- NULL
  ## run.sim <- NULL
  sim <- NULL
  tab.ext <- NULL
  tmprow <- NULL
  text <- NULL
  textmod <- NULL
  value <- NULL
  variable <- NULL
  
  
  ## Section end: Dummy variables, only not to get NOTE's in pacakge checks

  

  ## as.fun
  if(missing(as.fun)) as.fun <- NULL
  as.fun <- NMdata:::NMdataDecideOption("as.fun",as.fun)
  returnSimres <- function(simres){
    simres <- as.fun(simres)
    addClass(simres,"NMsimRes")
    return(simres)
  }
  
  #### Section start: Checking aguments ####
  
  if(missing(file.mod)) stop("file.mod must be supplied. It must be one or more paths to existing control streams.")
  if(any(!file.exists(file.mod))) stop("All elements in file.mod must be paths to existing input control streams.")
  ## Check control streams for potential problems
  
  if(check.mod){
    lapply(file.mod,NMsimCheckMod)
  }
  if(missing(data)) data <- NULL


  if(missing(args.NMscanData)) args.NMscanData <- NULL
  if(!is.null(args.NMscanData)){
    if(!is.list(args.NMscanData)) stop("args.NMscanData must be a list.")
    if(any(names(args.NMscanData)=="")) stop("All elements in args.NMscanData must be named.")
  }
  args.NMscanData.default <- list(merge.by.row=FALSE,col.model=NULL)
  
  if(missing(progress)) progress <- NULL
  
  if(missing(dir.psn)) dir.psn <- NULL
  if(missing(path.nonmem)) path.nonmem <- NULL
  if(missing(method.execute)) method.execute <- NULL
  if(missing(nmfe.options)) nmfe.options <- NULL
  NMsimConf <- NMsimTestConf(path.nonmem=path.nonmem,dir.psn=dir.psn,method.execute=method.execute,must.work=FALSE)

  
  ## after definition of wait and wait.exec, wait is used by
  ## NMreadSim(), wait.exec used by NMexec().
  if(missing(wait)) wait <- !sge
  wait.exec <- !sge && wait
  ## If we already wait on the simulation, no reason to wait for
  ## data. Especially, if NMTRAN fails in exec, NMreadSim() will
  ## wait indefinitely.
  if(wait.exec) wait <- FALSE
  

  ## args.psn.execute
  if(missing(args.psn.execute)) args.psn.execute <- NULL
  if(missing(clean)) clean <- 1
  
  if(missing(file.ext)) file.ext <- NULL

  if(missing(inits)) inits <- NULL
  if(missing(method.update.inits)) method.update.inits <- NULL
  inits <- adjust.method.update.inits(method.update.inits,system.type=NMsimConf$system.type,dir.psn=NMsimConf$dir.psn,cmd.update.inits=cmd.update.inits,file.ext=file.ext,inits=inits)
  method.update.inits <- inits$method
  file.ext <- inits$file.ext

  if(missing(filters)) filters <- NULL

  ### seed.R
  if(missing(seed.R)) seed.R <- NULL
  if(!is.null(seed.R)){
    set.seed(seed.R)
  }
  if(missing(seed.nm)) seed.nm <- NULL
  
  ## seed.nm
  ## seed is deprecated
  if(!missing(seed)){
    if(!is.null(seed.nm)){
      stop("`seed` and `seed.nm` supplied. Use (most commonly) `seed.R` or `seed.nm`, and not the deprecated `seed`.")
    }
    message("`seed` is deprecated. Use (most commonly) `seed.R` or `seed.nm`.")
    seed.nm <- seed
    seed <- NULL
  }

  
  ## if(missing(seed)) seed <- NULL
  ## arg.seed is the user-supplied seed. Don't confuse with seed.args
  ### in case of "asis", how should the user be allowed to disable touching the seed? seed.nm="asis"?

  ## to not touch nonmem seed, set seed.nm to FALSE or "asis" 
  arg.seed.nm <- seed.nm
  do.seed <- TRUE
  if( (is.logical(seed.nm) && seed.nm==FALSE) ||
        (is.character(seed.nm) && tolower(seed.nm)=="asis")){
    do.seed <- FALSE
  }
  if(is.numeric(seed.nm) || is.data.frame(seed.nm)){
    seed.nm <- list(values=seed.nm)
  }

  
  ## name.sim
  if(!missing(suffix.sim)){
    if(!missing(name.sim)){
      stop("name.sim and suffix.sim supplied. Use name.sim and not the deprecated suffix.sim. ")
    }
    message("suffix.sim is deprecated. Use name.sim.")
    name.sim <- suffix.sim
  }
  if(missing(name.sim)) name.sim <- NULL
  name.sim <- simpleCharArg("name.sim",name.sim,"noname",accepted=NULL,lower=FALSE,clean=FALSE)
  name.sim.paths <- cleanStrings(name.sim)
  modelname <- NULL
  input.archive <- FALSE

  if(!missing(list.sections)){
    stop("`list.sections` is deprecated. Use `modify`.")
  }
  
  if(missing(modify)) modify <- NULL
  if(!missing(modify.model)){
    if(!is.null(modify)){
      stop("both `modify.model` (deprecated argument) and `modify` supplied. Please use only `modify`.")
    }
    message("`modify.model` is deprecated. Please use `modify`.")
    modify <- modify.model
  }

  if(missing(subproblems)|| is.null(subproblems)) subproblems <- 0

  if(missing(sizes)) sizes <- NULL
  
  ###  Section end: Checking aguments

  dt.models <- data.table(file.mod=file.mod)
  ##dt.models[,run.mod:=fnExtension(basename(file.mod),"")]
  dt.models[,model:=fnExtension(basename(file.mod),"")]
  dt.models[,name.sim:=..name.sim]
  dt.models[,fast.tables:=FALSE]
  dt.models[,carry.out:=list(..carry.out)]
  dt.models[,NMsimVersion:=packageVersion("NMsim")]
  dt.models[,NMsimTime:=Sys.time()]

  
  warn.notransform <- function(transform){
    if(is.null(transform)) return(invisible(NULL))
    warning("`transform` (argument) ignored since NMsim is not reading the simulation results.")
  }
  
  if(missing(nmrep)||is.null(nmrep)) nmrep <- subproblems>0
  if(missing(table.vars)) table.vars <- NULL
  if(missing(table.options)) table.options <- NULL

  if(missing(text.table)) {
    text.table <- NULL
  }

  if(!is.null(text.table)) {
    if(!is.null(table.vars) || !is.null(table.options)){
      stop("argument \'text.table\' is deprecated. Please use \'table.vars\' and/or \'table.options\' instead.")
    } else {
      warning("argument \'text.table\' is deprecated and should be avoided. Please use \'table.vars\' and/or \'table.options\' instead.")
    }
  }

  ## if(missing(table.format)) table.format <- NULL
  

  ### fast.tables is true if table.vars is provided and table.options are untouched.
  cols.table.add <- c()
  if(nmrep){
    
    ## if(subproblems>0 &&
    ##    !is.null(table.vars)
    ## this has not been resolved in NMdata
    ## && packageVersion("NMdata")<"1.1.7"
    ## ){

    if(is.null(table.vars)){
      cols.table.add <- c(cols.table.add,"NMREP")
    } else {
      tabv2 <- paste(table.vars,collapse=" ")
      ### don't add col.row here. It is model dependent and will be added when writing $TABLE
      ##tabv2 <- paste(col.row,tabv2)
      ### NMREP can be added here because it is not used if $TABLE isn't overwritten
      ## if(nmrep) {
      tabv2 <- paste(tabv2,"NMREP")
      ## }
      tabv2 <- gsub(" +"," ",tabv2 )
      table.vars <- strsplit(tabv2," ")[[1]]
      table.vars <- unique(table.vars)
    }

    ### Create NMREP in $ERROR. Adding 1 to start counting at 1.
    
    modify <- c(modify,
                list(PRED=add("NMREP=IREP")),
                list(PK=add("NMREP=IREP"))
                )
  }
  
  if(!is.null(table.vars)){
    names.table.vars <- names(table.vars)
    if(!is.null(names.table.vars)){
      
      names.table.vars <- sub("(.+)","\\1=",names.table.vars)
      table.vars <-
        paste(names.table.vars,table.vars,sep="")
    }
  }
  
  ### generate text.table as the combination of table.vars and table.options
  if(is.null(text.table)){
    if(!is.null(table.vars)){
      if(is.null(table.options)){
        ### this is prefered. The fast.tables option. But ONEHEADERALL requires NONMEM 7.4 or later
        table.options <- c("NOPRINT","NOAPPEND","ONEHEADERALL", "NOTITLE")
        dt.models[,fast.tables:=TRUE]
      }
      if(!is.null(table.format)){
        table.options <- c(table.options,sprintf("FORMAT=%s",table.format))
      }
      text.table <- paste(paste(table.vars,collapse=" "),paste(table.options,collapse=" "))
    } else {
      if(!missing(table.format)){
        message("`table.format` is ignored. Only used when `table.vars` is supplied.")
      }
    }
  }

  ## this should only be tested if fast.tables is FALSE
  if(!is.null(table.vars)&&any(!dt.models$fast.tables)&&length(table.vars)<3){
    message("Using less than three variables in table.vars in combination with subproblems may cause issues. If you get an error, try to add any variable or two to table.vars.")
  }
  
  if(missing(nmquiet)) nmquiet <- NULL

  ##if(missing(modelname)) modelname <- NULL
  ## modelname <- NMdataDecideOption("modelname",modelname)
  if(is.null(modelname)) modelname <- function(fn) fnExtension(basename(fn),"")

 
  #### Section start: Defining additional paths based on arguments ####

  ## dir.sim
  
  if(missing(dir.sims)) dir.sims <- NULL
  dir.sims <- try(NMdata:::NMdataDecideOption("dir.sims",dir.sims,allow.unknown=TRUE),silent=TRUE)
  if(inherits(dir.sims,"try-error")){
    dir.sims <- NULL
  }
  ## dir.sims <- simpleCharArg("dir.sims",dir.sims,default=NULL,accepted=NULL,lower=FALSE)
  dir.sims <- simpleCharArg("dir.sims",dir.sims,file.path(dirname(file.mod),"NMsim"),accepted=NULL,lower=FALSE)

  
  if(!dir.exists(dir.sims)){
    if(!create.dirs){
      stop(paste("dir.sims does not point to an existing directory. dir.sims is\n",NMdata:::filePathSimple(dir.sims)))
    }
    res.dc <- tryCatch(dir.create(dir.sims),warning=function(w)w)
    if("warning"%in%class(res.dc)){
      stop("Problems creating dir.sims. Please check that the parent directory exists and is writable.")
    }
  }
  
  if(missing(file.res)) file.res <- NULL
  if(is.null(file.res)) {

    if(missing(dir.res)) dir.res <- NULL
    dir.res <- try(NMdata:::NMdataDecideOption("dir.res",dir.res,allow.unknown=TRUE),silent=TRUE)
    if(inherits(dir.res,"try-error")){
      dir.res <- NULL
    }
    dir.res <- simpleCharArg("dir.res",dir.res,default=dir.sims,accepted=NULL,lower=FALSE)
    
    ## if(missing(dir.res) || is.null(dir.res)) dir.res <- dir.sims
  } else {
    dir.res <- dirname(file.res)
  }
  
  if(!dir.exists(dir.res)){
    if(!create.dirs){
      stop(paste("dir.res does not point to an existing directory. dir.res is\n",NMdata:::filePathSimple(dir.res)))
    }
    ## dir.create(dir.res)
    res.dc <- tryCatch(dir.create(dir.res),warning=function(w)w)
    if("warning"%in%class(res.dc)){
      message(dir.res)
      stop("Problems creating dir.res. Please check that the parent directory exists and is writable.")
    }
    
  }

  
  relpathResFromSims <- relative_path(dir.res,dir.sims)
  relpathSimsFromRes <- relative_path(dir.sims,dir.res)
  

  
  ## dt.models[,name.mod:=run.mod]
  ## dt.models[,name.mod:=model]
  dt.models[,pathResFromSims:=relpathResFromSims]
  dt.models[,pathSimsFromRes:=relpathSimsFromRes]
  if(!is.null(names(file.mod))){
    
    names.mod <- names(file.mod)
    names.mod[names.mod==""] <- file.mod[names.mod==""]
    ## dt.models[,name.mod:=names.mod]
    dt.models[,model:=names.mod]
    rm(names.mod)
  }
  dt.models[,ROWMODEL:=.I]

  ## fn.sim is the file name of the simulation control stream created by NMsim
  ## fn.sim <- sub("^run","NMsim",basename(file.mod))
  dt.models[,fn.mod:=basename(file.mod)]
  ### prepending NMsim to model names
  ## dt.models[,fn.sim:=fnExtension(name.mod,".mod")]
  ### This cannot be done with fnExtension() because that would strip
  ### part of the model name after a ".". Instead, ".mod" is simply
  ### appended.
  ## dt.models[,fn.sim:=fnExtension(model,".mod")]
  dt.models[,fn.sim:=paste0(model,".mod")]
  dt.models[,fn.sim:=cleanStrings(fn.sim)]

  ## fn.sim should be unique
  dt.models[,n.fn.sim:=.N,by=fn.sim]
  dt.models[n.fn.sim>1,fn.sim:=fnAppend(fn.sim,pad0=floor(log10(n.fn.sim))+1)]
  dt.models[,n.fn.sim:=NULL]

  ## dt.models[,model:=modelname(fn.sim)]
  

  

  
  ### file.ext
  if(is.null(file.ext)) {
    dt.models[,file.ext:=fnExtension(file.mod,"ext"),by=.(ROWMODEL)]
  } else {
    if(length(file.ext) != length(file.mod)){
      stop("If `file.ext` is provided, it must be of same length as `file.mod`.")
    }
  }
  

  ### prepare data sets
  data <- NMsimDataPrepare(data,auto.dv=auto.dv,order.columns=order.columns)

  

  ## dt.data.tmp <- data.table(DATAROW=1:length(data$data),data.name=names.data)
  ## if(dt.data.tmp[,.N]==1) dt.data.tmp[,data.name:=""]

  ### doesn't work when dt.models contains columns of type list 
  ## dt.models <- dt.models[,data$dt.data,by=dt.models]
  dt.models <- egdt(dt.models,data$dt.data,quiet=TRUE)
  

  
  dt.models[,ROWMODEL:=.I]
  dt.models[,RMODORIG:=ROWMODEL]

  ####### TODO
  ## construct model-specific paths to data sets on file. say parent dir of fn.sim, then data/name_data.csv. They must be a column in dt.models
  
  ## save the unique data:datapath combinations

  ## indicate for those that data should not be re-saved. The caveat is the VPC style probably has te be different.

  ## rewrite where NMwriteData is done to only generate text. Or even do that here?
  

  
  if(is.null(data)){
    dt.models[,data.name:=""]
  } 

  

  ### name.mod and name.sim are confusing. name.mod is the name
  ### specified for the mod, like
  ### file.mod=c(ref="run01.mod"). name.sim is the name that was
  ### given for the who sim.
  
  
  dt.models[,fn.sim.predata:=fnAppend(fn.sim,name.sim.paths)]
  dt.models[,fn.sim:=fnAppend(fn.sim.predata,as.character(data.name)),by=.(ROWMODEL)]
  
  ## spaces not allowed in model file names
  ## dt.models[,fn.sim:=gsub(" ","_",fn.sim)]
  dt.models[,fn.sim:=cleanStrings(fn.sim)]
  ## run.sim should be deprecated. model.sim is what is used in results data. No model is used in results data. But model.sim is the necesary clean name
  
  ## dt.models[,run.sim:=modelname(fn.sim)]
  dt.models[,model.sim:=modelname(fn.sim)]
  ## dt.models[,model.sim:=modelname(fn.sim.predata)]

  
  ## dir.sim is the model-individual directory in which the model will be run
  ## dt.models[,
  ##        dir.sim:=file.path(dir.sims,paste(name.mod,name.sim.paths,sep="_"))]

  if(dir.sim.sub){
    dt.models[,
              dir.sim:=file.path(dir.sims,cleanStrings(paste(model,name.sim.paths,sep="_")))]
  } else {
    dt.models[,
              dir.sim:=dir.sims]
  }
  
  ## path.sim.tmp is a temporary path to the sim control stream - it
  ## will be moved to path.sim once created.
  dt.models[,fn.sim.tmp:=fnAppend(fn.sim,"tmp")]
  ## path.sim: full path to simulation control stream
  dt.models[,path.sim:=NMdata:::filePathSimple(file.path(dir.sim,fn.sim))]
  

  ## where tosave input data to be read by simulation control stream
  ## fn.data is the data file name, no path
  
  ## dt.models[,fn.data:=paste0("NMsimData_",fnAppend(fnExtension(name.mod,".csv"),name.sim))]
  dt.models[,fn.data:=paste0("NMsimData_",fnAppend(fnExtension(model,".csv"),name.sim.paths))]
  dt.models[,fn.data:=fnAppend(fn.data,data.name),by=.(ROWMODEL)]
  ## dt.models[,fn.data:=gsub(" ","_",fn.data)]
  dt.models[,fn.data:=cleanStrings(fn.data)]

  dt.models[,dir.data.sim:=dir.sim]
  #### A data-efficient way to store data sets as needed
  if(FALSE){
    dt.models[,dir.data.sim:=file.path(dir.sim,"data")]
  }

  dt.models[,path.data:=file.path(dir.data.sim,fn.data)]
  
  ## path.rds - Where to save table of runs
  if(missing(dir.res)) {
    dt.models[,dir.res:=dir.sim]
  } else {
    dt.models[,dir.res:=..dir.res]
  }
  
  if(is.null(file.res)){
    dt.models[,path.rds:=file.path(dir.res,fnAppend(fnExtension(fn.sim.predata,"rds"),"MetaData"))]
    dt.models[,path.digests:=file.path(dir.res,fnAppend(fnExtension(fn.sim.predata,"rds"),"digests"))]
    ## dt.models[,path.rds:=pathSimMeta())]
    dt.models[,path.results:=file.path(dir.res,fnAppend(fnExtension(fn.sim.predata,"fst"),"ResultsData"))]
  } else {
    dt.models[,path.rds:=fnExtension(file.res,"rds")]
    dt.models[,path.digests:=fnAppend(fnExtension(file.res,"rds"),"digests")]
    dt.models[,path.results:=fnAppend(fnExtension(file.res,"fst"),"ResultsData")]
  }


  #### calculate digest for recycle ####

  list.digests.all <- lapplydt(
    dt.models,by="RMODORIG",
    fun=function(x){
      
      args.this <- all.args.call
      args.this$file.mod <- x$file.mod
      args.this$recycle <- NULL
      
      ## compareCols(args.this,x)
      digs <- digest_list(args.this,
                          path.results=x$path.rds,
                          args.unwrap = list(
                            file.mod=function(x)readLines(x,warn=FALSE)
                          ))
      digs <- list(digests=digs,path.digests=x$path.digests)
      digs
    })


### End: calculate digest for recycle ###


  
  dt.models.recycle <- NULL
  if(recycle){
    
    list.digests <- lapplydt(
      ##unique(dt.models$RMODORIG),
dt.models,by="RMODORIG",
      ## FUN=function(rmod){
      fun=function(x){
        ## x <- dt.models[RMODORIG==rmod]
        args.this <- all.args.call
        args.this$file.mod <- x$file.mod
        args.this$recycle <- NULL
        rmod <- x[,RMODORIG]
        ## compareCols(args.this,x)
        res <- check_need_run(args=args.this,
                              path.results=x$path.rds,
                              path.digest=x$path.digests,
                              digests=list.digests.all[[rmod]]$digests,
                              force=FALSE,
                              args.unwrap = list(
                                file.mod=function(x)readLines(x,warn=FALSE)
                              )
                              )
        ## res$digest.all <- NULL
        res
      })
    
    
    
    ## merge in run? Would be duplicate and unnecessary. But might make sense?
    dt.run <- dtapply(list.digests,FUN=function(x)x$run,element.name="ROWMODEL",value.names="run",as.fun="data.table")
    dt.run[,ROWMODEL := as.integer(ROWMODEL)]

    

    dt.models <- mergeCheck(dt.models,dt.run,by="ROWMODEL",quiet=TRUE)

    dt.models.recycle <- dt.models[run==FALSE]
    dt.models <- dt.models[run==TRUE]
    
  }


  


  simres <- NULL
  ### path.rds.exists is whether the metadata rds existed prior to this function call. We don't want to save that in dt.models
  path.rds.exists <- dt.models[,file.exists(path.rds)]
  ### reading results from prior run
  ## if(reuse.results && all(dt.models[,path.rds.exists==TRUE])){
  if(reuse.results && all(path.rds.exists==TRUE)){
    if(!quiet) message(sprintf("Reading from simulation results on file:\n%s",dt.models[,paste(simplePath(unique(path.rds)),collapse="\n")]))
    
    simres <- try(NMreadSim(dt.models[,path.rds],wait=wait,quiet=quiet,progress=progress,as.fun=as.fun))
    if(inherits(simres,"try-error") || is.null(simres) || nrow(simres)==0) {
      message("Reading results on file returned error(s). Simulations will be re-run even though `reuse.results=TRUE`.")
    } else {
      return(returnSimres(simres))
    }
  }

  f <- NMsim_run_models
    environment(f) <- environment()
  res <- f()
  ## res <- NMsim_run_models(dt.models,env=environment())

  simres <- res$simres
  dt.models <- res$dt.models

  simres.recycle <- NULL
  if(recycle && nrow(dt.models.recycle)){
    
    
    ## simres.recycle <- NMreadSim()
    simres.recycle <- NMreadSim(dt.models.recycle[,path.rds],wait=wait,progress=FALSE,quiet=quiet,as.fun=as.fun)
  }

  

  simres.all <- rbind(simres,simres.recycle,fill=TRUE)
  ##  todo: not sure how to reorder. Look at file.mod from arguments? 
  ## setorder(simres.all,"ROWMODEL")
 
 #### always save digests for future recycling ####
## if(FALSE){  
  dt.models.all <- rbind(dt.models,dt.models.recycle,fill=TRUE)

  dt.models.digest <- unique(dt.models.all,by=c("RMODORIG"))

  list.digests.all <- lapplydt(
    dt.models.digest,by="RMODORIG",
    fun=function(x){
      
      args.this <- all.args.call
      args.this$file.mod <- x$file.mod
      args.this$recycle <- NULL
      
      ## compareCols(args.this,x)
      digs <- digest_list(args.this,
                          path.results=x$path.rds,
                          args.unwrap = list(
                            file.mod=function(x)readLines(x,warn=FALSE)
                          ))
      digs <- list(digests=digs,path.digests=x$path.digests)
      digs
    })

  ## list.digests.all
## }  

  ### extract new - not used
  ## digests <- lapply(list.digests,function(x)x$digest.new)
  

  if(length(list.digests.all)<1) {
    warning("Digests failed. Future recycling of this run not possible.")
  } else {
    
     ## must extract path digests
    tmp <- lapply(list.digests.all,function(x){
      saveRDS(x$digests, x$path.digests)
    })

  }

### End: always save digests for future recycling ###

 
  
  ##### return results to user
  
  ## if(!wait) return(simres$lst)
  ## if(execute && (wait.exec||wait)){
  if(is.NMsimRes(simres.all) || (execute && (wait.exec||wait))){
    if(!quiet){
      if(nrow(simres.all)==0){
        message("Simulation results are empty. An empty data.frame is returned.")
      } else {
      ## message("\nSimulation results returned. Re-read them without re-simulating using:\n",paste(sprintf("  simres <- NMreadSim(\"%s\")",dt.models.all[,simplePath(unique(path.rds))]),collapse="\n"))
        unique.path.rds <- dt.models.all[,simplePath(unique(path.rds))]
        if(length(unique.path.rds)==1){
          msg <- paste("\nSimulation results returned. Re-read them without re-simulating using:\n",
                   paste(sprintf("  simres <- NMreadSim(\"%s\")",unique.path.rds)))
        }
        if(length(unique.path.rds)>1){
          msg <- paste("\nSimulation results returned. Re-read them without re-simulating using:\n",
                   paste(sprintf("  simres <- NMreadSim(\n     \"%s\")",
                                 paste(unique.path.rds,collapse="\",\n     \"")
                                 ))
                   )          
        }
      }
      message(msg)
         return(returnSimres(simres.all))
    }
  } else {
    if(!quiet & execute){
      message(sprintf("\nRead results with:\n  simres <- NMreadSim(c(\"%s\"))\nThe first time the results are read, they will be efficiently stored in the simulation results folder. Until then, they only exist as Nonmem result files.\nTrick: `NMreadSim()` also supports the `wait` argument to watch over Nonmem runs and return results once ready.",paste(dt.models[,simplePath(unique(path.rds))],collapse="\",\n    \"")))
    }
    addClass(dt.models,"NMsimModTab")
    return(invisible(dt.models.all[,unique(path.rds)]))
  }

}
