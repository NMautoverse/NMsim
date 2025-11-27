# Simulate from a Nonmem model

Supply a data set and an estimation input control stream, and NMsim can
create neccesary files (control stream, data files), run the simulation
and read the results. It has additional methods for other simulation
types available, can do multiple simulations at once and more. Please
see vignettes for an introduction to how to get the most out of this.

## Usage

``` r
NMsim(
  file.mod,
  data,
  subproblems = NULL,
  reuse.results = FALSE,
  seed.R,
  seed.nm,
  name.sim,
  table.vars,
  table.options,
  table.format = "s1PE16.9",
  carry.out = TRUE,
  method.sim = NMsim_default,
  typical = FALSE,
  inits,
  modify,
  filters,
  sizes,
  path.nonmem = NULL,
  sge = FALSE,
  nc = 1,
  execute = TRUE,
  script = NULL,
  transform = NULL,
  order.columns = TRUE,
  method.execute,
  nmfe.options,
  nmrep,
  col.flagn = FALSE,
  dir.psn,
  args.psn.execute,
  args.NMscanData,
  as.fun,
  system.type = NULL,
  dir.sims,
  dir.res,
  file.res,
  dir.sim.sub = TRUE,
  wait,
  text.sim = "",
  auto.dv = TRUE,
  clean,
  sim.dir.from.scratch = TRUE,
  create.dirs = TRUE,
  quiet = FALSE,
  nmquiet,
  progress,
  check.mod = TRUE,
  format.data.complete = "rds",
  text.table,
  suffix.sim,
  seed,
  file.ext = NULL,
  method.update.inits,
  modify.model,
  list.sections,
  ...
)
```

## Arguments

- file.mod:

  Path(s) to the input control stream(s) to run the simulation on. The
  output control stream is for now assumed to be stored next to the
  input control stream and ending in .lst instead of .mod. The .ext file
  must also be present. If simulating known subjects, the .phi is
  necessary too.

- data:

  The simulation data as a `data.frame` or a list of `data.frame`s. If a
  list, the model(s) will be run on each of the data sets in the list.

- subproblems:

  Number of subproblems to use as `SUBPROBLEMS` in `$SIMULATION` block
  in Nonmem. The default is subproblem=0 which means not to use
  `SUBPROBLEMS`.

- reuse.results:

  If simulation results found on file, should they be used? If TRUE and
  reading the results fail, the simulations will still be rerun.

- seed.R:

  A value passed to [`set.seed()`](https://rdrr.io/r/base/Random.html).
  It is recommended to use `seed.R` rather than calling
  [`set.seed()`](https://rdrr.io/r/base/Random.html) manually because
  the seed can then be captured and stored by `NMsim()` for
  reproducibility. See `seed.nm` for finer control of the seeds that are
  used in the Nonmem control streams.

- seed.nm:

  Control Nonmem seeds. If a numeric, a vector or a \`data.frame\`,
  these are used as the the seed values (a single value or vector will
  be recycled so make sure the dimesnsions are right, the number of
  columns in a `data.frame` will dictate the number of seeds in each
  Nonmem control stream. Use a list with elements \`values\`, and
  \`dist\` and others for detailed control of the random sources. See
  [`?NMseed`](https://nmautoverse.github.io/NMsim/reference/NMseed.md)
  for details on what arguments can be passed this way.

  Default is to draw seeds betwen 0 and 2147483647 (the values supported
  by Nonmem) for each simulation. You can pass a function that will be
  evaluated (say to choose a different pool of seeds to draw from).

  To avoid changing an exisiting seed in a control stream, use
  `seed.nm="asis"`.

  In case `method.sim=NMsim_EBE`, seeds are not used.

- name.sim:

  Give all filenames related to the simulation a suffix. A short string
  describing the sim is recommended like "ph3_regimens".

- table.vars:

  Variables to be printed in output table as a character vector or a
  space-separated string of variable names. The default is to export the
  same tables as listed in the input control stream. If `table.vars` is
  provided, all output tables in estimation control streams are dropped
  and replaced by a new one with just the provided variables. If many
  variables are exported, and much fewer are used, it can speed up NMsim
  significantly to only export what is needed (sometimes this is as
  little as "PRED IPRED"). Nonmem writes data slowly so reducing output
  data can make a very big difference in execution time. See
  `table.options` too.

- table.options:

  A character vector or a string of space-separated options. Only used
  if `table.vars` is provided. If constructing a new output table with
  `table.vars` the default is to add two options, `NOAPPEND` and
  `NOPRINT`. You can modify that with `table.options`. Do not try to
  modify output filename - `NMsim` takes care of that. See
  \`table.format\` too.

- table.format:

  A format for \`\$TABLE\`. Only used if \`table.vars\` is provided.
  Default is "s1PE16.9". NMsim needs a high-resolution format. The
  Nonmem default "s1PE11.4" is insufficient for simulation data sets of
  1e5 rows or more.

- carry.out:

  Variables from input data that should be included in results. Default
  is to include everything. If working with large data sets, it may be
  wanted to provide a subset of the columns here. If doing very large
  simulations, this may also be a way to save memory.

- method.sim:

  A function (not quoted) that creates the simulation control stream and
  other necessary files for a simulation based on the estimation control
  stream, the data, etc. The default is called `NMsim_default` which
  will replace any estimation and covariance step by a simulation step.
  See details section on oter methods, and see examples and especially
  vignettes on how to use the different provided methods.

- typical:

  Run with all ETAs fixed to zero? Technically all ETAs=0 is obtained by
  replacing `$OMEGA` by a zero matrix. Default is \`FALSE\`. Instead of
  a logical \`TRUE/FALSE\`, a character vector can be used to specify
  what parameter types to set to zero and fix. Examples:
  \`typical=c("OMEGA","SIGMA")\`,
  \`typical=c("THETAPV","OMEGA","OMEGAP","OMEGAPD")\`. In fact, if
  \`typical=TRUE\`, both \`\$OMEGA\` itself and - if found - their
  priors will be fixed at zero.

- inits:

  Control the parameter values. \`inits\` is a list and contains (any
  of) the \`method\` used to edit the parameters, and what modifications
  to do.

  Using the defaul \`method\`, all other list elements are passed as
  arguments to \`NMwriteInits()\`. Please see \`?NMwriteInits\` and the
  examples on the NMsim website for how to edit the parameter values:
  <https://nmautoverse.github.io/NMsim/articles/NMsim-modify-model.html>

  The \`method\` element controls which method is used to do this, and
  this corresponds to the old \`method.update.initxfgs\` argument.
  Normally, the user should not need to deal with this as the default
  \`nmsim\` method is very flexible and powerful. If using the new
  \`method=nmsim\` you can specify parameter values, fix/unfix them, and
  edit lower and upper limits for estimation.

  - \`method="nmsim"\` (default) A highly flexible internal method,
    allows for modification of the parameter values. All other elements
    in \`inits\` are passed to \`NMwriteInits()\`. Example where
    \`THETA(2)\` is customized:
    \`inits=list("THETA(2)"=list(init=1.3))\`. See \`?NMwriteInits\`
    too.

  - \`method="psn"\` Uses PSN's "update_inits". Requires a functioning
    PSN installation and possibly that `dir.psn` is correctly set. The
    advantages of this method are that it keeps comments in the control
    stream and that it is a method known to many.

  - \`method="simple"\` Uses a simple internal method to update the
    parameter values based on the ext file. The advantages are it does
    not require PSN, and that it does not rely on code-interpretation
    for generation of simulation control streams. "simple" fixes the
    whole OMEGA and SIGMA matrices as single blocks which is robust
    because it avoids any interpretation of BLOCK structure or other
    code in the control streams. The downside is it strips all comments,
    and generally makes the \$OMEGA and \$SIGMA sections of the
    simulation control streams less easy to read. "simple" can be used
    as a fallback in case of any issues with \`method="nmsim"\`.

  - \`method="none"\` Do nothing. This is useful if the model to
    simulate has not been estimated but parameter values have been
    manually put into the respective sections in the control stream.

  See also \`file.ext\` which can now be handled by \`inits\` too. This
  change collects the update of the "initial" parameter values into one
  interface rather than multiple arguments.

- modify:

  Named list of additional control stream section edits. Note, these can
  be functions that define how to edit sections. This is an advanced
  feature which is not needed to run most simulations. It is however
  powerful for some types of analyses, like modifying parameter values.
  See vignettes for further information.

- filters:

  Edit data filters (\`IGNORE\`/\`ACCEPT\` statements) before running
  model. This should normally only be used if no data set is provided.
  It can be useful if simulating for a VPC but a different subset of
  data needs to be simulated than the one used for estimation. A common
  example on this is inclusion of BLQ's in the VPC even if they were
  excluded in the estimation. See \`?NMreadFilters\` which returns a
  table you can edit and pass to \`filters\`. You can also just pass a
  string representing the full set of filters to be used. If you pass a
  string, consider including "IGN=@" to avoid character rows, like the
  column headers.

- sizes:

  If needed, adjust the \`\$SIZES\` section by providing a list of
  arguments to \`NMupdateSizes()\`. Example: \`sizes=list(PD=80)\`. See
  \`?NMupdateSizes\` for details. Don't use arguments like \`file.mod\`
  and \`newfile\` which are handled internally.

- path.nonmem:

  The path to the Nonmem executable to use. The could be something like
  "/usr/local/NONMEM/run/nmfe75" (which is a made up example). No
  default is available. You should be able to figure this out through
  how you normally execute Nonmem, or ask a colleague.

- sge:

  Submit to cluster? Default is not to, but this is very useful if
  creating a large number of simulations, e.g. simulate with all
  parameter estimates from a bootstrap result.

- nc:

  Number of cores used in parallelization. Only used if \`sge=TRUE\`.

- execute:

  Execute the simulation or only prepare it? \`execute=FALSE\` can be
  useful if you want to do additional tweaks or simulate using other
  parameter estimates.

- script:

  The path to the script where this is run. For stamping of dataset so
  results can be traced back to code.

- transform:

  A list defining transformations to be applied after the Nonmem
  simulations and before plotting. For each list element, its name
  refers to the name of the column to transform, the contents must be
  the function to apply.

- order.columns:

  reorder columns by calling
  [`NMdata::NMorderColumns`](https://nmautoverse.github.io/NMdata/reference/NMorderColumns.html)
  before saving dataset and running simulations? Default is TRUE.

- method.execute:

  Specify how to call Nonmem. Options are "psn" (PSN's execute), "nmsim"
  (an internal method similar to PSN's execute), and "direct" (just run
  Nonmem directly and dump all the temporary files). "nmsim" has
  advantages over "psn" that makes it the only supported method when
  type.sim="NMsim_EBE". "psn" has the simple advantage that the path to
  nonmem does not have to be specified if "execute" is in the system
  search path. So as long as you know where your Nonmem executable is,
  "nmsim" is recommended. The default is "nmsim" if path.nonmem is
  specified, and "psn" if not.

- nmfe.options:

  additional options that will be passed to nmfe. It is only used when
  path.nonmem is available (directly or using \`NMdataConf()\`). Default
  is "-maxlim=2" For PSN, see \`args.psn.execute\`.

- nmrep:

  Include \`NMREP\` as counter of subproblems? The default is to do so
  if \`subproblems\>0\`. This will insert a counter called \`NMREP\` in
  the \`\$ERROR\` section and include that in the output table(s). At
  this point, nothing is done to avoid overwriting existing variables.

- col.flagn:

  Only used if \`data\` is provided. Use this if you are including an
  exclusion flag column in data. However, what NMsim will then do is to
  require that column to equal \`0\` (zero) for the rows to be
  simulated. It is often better to subset the data before simulation.
  See \`filters\` too.

- dir.psn:

  The directory in which to find PSN's executables ('execute' and
  'update_inits'). The default is to rely on the system's search path.
  So if you can run 'execute' and 'update_inits' by just typing that in
  a terminal, you don't need to specify this unless you want to
  explicitly use a specific installation of PSN on your system.

- args.psn.execute:

  A charachter string that will be passed as arguments PSN's
  \`execute\`. The default is "-model_dir_name
  -nm_output=coi,cor,cov,ext,phi,shk,xml -nmfe_options=\\-maxlim=2\\" in
  addition to the "-clean" based on the \`clean\` argument. Notice, if
  \`path.nonmem\` is provided, the default is not to use PSN.

- args.NMscanData:

  If `execute=TRUE&sge=FALSE`, NMsim will normally read the results
  using `NMreadSim`. Use this argument to pass additional arguments (in
  a list) to that function if you want the results to be read in a
  specific way. This can be if the model for some reason drops rows, and
  you need to merge by a row identifier. You would do
  \`args.NMscanData=list(col.row="ROW")\` to merge by a column called
  \`ROW\`. This is only used in rare cases.

- as.fun:

  The default is to return data as a data.frame. Pass a function (say
  \`tibble::as_tibble\`) in as.fun to convert to something else. If
  data.tables are wanted, use as.fun="data.table". The default can be
  configured using NMdataConf.

- system.type:

  A charachter string, either "windows" or "linux" - case insensitive.
  Windows is only experimentally supported. Default is to use
  `Sys.info()[["sysname"]]`.

- dir.sims:

  The directory in which NMsim will store all generated files. Default
  is to create a folder called \`NMsim\` next to \`file.mod\`.

- dir.res:

  Provide a path to a directory in which to save rds files with paths to
  results. Default is to use dir.sims. After running \`NMreadSim()\` on
  these files, the original simulation files can be deleted. Hence,
  providing both \`dir.sims\` and \`dir.res\` provides a structure that
  is simple to clean. \`dir.sims\` can be purged when \`NMreadSim\` has
  been run and only small \`rds\` and \`fst\` files will be kept in
  \`dir.res\`. Notice, in case multiple models are simulated, multiple
  \`rds\` (to be read with \`NMreadSim()\`) files will be created by
  default. In cases where multiple models are simulated, see
  \`file.res\` to get just one file refering to all simulation results.

- file.res:

  Path to an rds file that will contain a table of the simulated models
  and other metadata. This is needed for subsequently retrieving all the
  results using \`NMreadSim()\`. The default is to create a file called
  \`NMsim\_...\_MetaData.rds\` under the `dir.res` directory where ...
  is based on the model name. However, if multiple models (`file.mod`)
  are simulated, this will result in multiple rds files. Specifying a
  path ensures that one rds file containing information about all
  simulated models will be created. Notice if `file.res` is supplied,
  `dir.res` is not used.

- dir.sim.sub:

  If \`TRUE\` (default) a dedicated subdirectory will be created for eac
  model run. This is normally the cleanest way to run simulations.
  However, when \`NMsim()\` is used for estimation, it may be better to
  provide model results in the same folder as the input control stream
  (like PSN would do). Use \`dir.sim.sub=FALSE\` to get this behavior.

- wait:

  Wait for simulations to finish? Default is to do so if simulations are
  run locally but not to if they are sent to the cluster. Waiting for
  them means that the results will be read when simulations are done. If
  not waiting, path(s) to \`rds\` files to read will be returned. Pass
  them through \`NMreadSim()\`. Conveniently, NMreadSim() also takes the
  \`wait\` argument too, allowing flexibility to run Nonmem in the
  background, and then read the results, still waiting for Nonmem to
  finish.

- text.sim:

  A character string to be pasted into \$SIMULATION. This must not
  contain seed or SUBPROBLEM which is handled separately. Default is to
  include "ONLYSIM". You cannot avoid that using \`text.sim\`. If
  needed, you can use \`onlysim=FALSE\` which will be passed to
  \`NMsim_default()\`.

- auto.dv:

  Add a column called \`DV\` to input data sets if a column of that name
  is not found? Nonmem is generally dependent on a \`DV\` column in
  input data but this is typically uninformative in simulation data sets
  and hence easily forgotten when generating simulation data sets. If
  `auto.dv=TRUE` and no \`DV\` column is found, \`DV=NA\` will be added.
  In this case (\`auto.dv=TRUE\` and no \`DV\` column found) a \`MDV=1\`
  column will also be added if none found.

- clean:

  The degree of cleaning (file removal) to do after Nonmem execution. If
  \`method.execute=="psn"\`, this is passed to PSN's \`execute\`. If
  \`method.execute=="nmsim"\` a similar behavior is applied, even though
  not as granular. NMsim's internal method only distinguishes between 0
  (no cleaning), any integer 1-4 (default, quite a bit of cleaning) and
  5 (remove temporary dir completely).

- sim.dir.from.scratch:

  If TRUE (default) this will wipe the simulation directory before
  running new simulations. The directory that will be emptied is \_not\_
  dir.sims where you may keep many or all your simulations. It is the
  subdirectory named based on the run name and `name.sim`. The reason it
  is advised to wipe this directory is that if you in a previous
  simulation created simulation runs that are now obsolete, you could
  end up reading those too when collecting the results. NMsim will
  delete previously generated simulation control streams with the same
  name, but this option goes further. An example where it is important
  is if you first ran 1000 replications, fixed something and now
  rand 500. If you choose FALSE here, you can end up with the results of
  500 new and 500 old simulations.

- create.dirs:

  If the directories specified in dir.sims and dir.res do not exists,
  should it be created? Default is TRUE.

- quiet:

  If TRUE, messages from what is going on will be suppressed.

- nmquiet:

  Silent console messages from Nonmem? The default behaviour depends. It
  is FALSE if there is only one model to execute and \`progress=FALSE\`.

- progress:

  Track progress? Default is \`TRUE\` if \`quiet\` is FALSE and more
  than one model is being simulated. The progress tracking is based on
  the number of models completed, not the status of the individual
  models.

- check.mod:

  Check the provided control streams for contents that may cause issues
  for simulation. Default is \`TRUE\`, and it is only recommended to
  disable this if you are fully aware of such a feature of your control
  stream, you know how it impacts simulation, and you want to get rid of
  warnings.

- format.data.complete:

  For development purposes - users do not need this argument. Controls
  what format the complete input data set is saved in. Possible values
  are \`rds\` (default), \`fst\` (experimental) and \`csv\`. \`fst\` may
  be faster and use less disk space but factor levels may be lost from
  input data to output data. \`csv\` will also lead to loss of
  additional information such as factor levels.

- text.table:

  Deprecated. Use \`table.vars\` and \`table.options\` instead.

- suffix.sim:

  Deprecated. Use name.sim instead.

- seed:

  Deprecated. See `seed.R` and `seed.nm`.

- file.ext:

  Deprecated. Use \`inits=list(file.ext="path/to/file.ext")\` instead.
  Optionally provide a parameter estimate file from Nonmem. This is
  normally not needed since \`NMsim\` will by default use the ext file
  stored next to the input control stream (replacing the file name
  extension with \`.ext\`). If using method.update.inits="psn", this
  argument cannot be used.

- method.update.inits:

  Deprecated, please migrate to \`inits\` instead. The initial values of
  all parameters are by updated from the estimated model before running
  the simulation. NMsim can do this with a native function or use PSN to
  do it - or the step can be skipped to not update the values.

- modify.model:

  Deprecated. Use modify instead.

- list.sections:

  Deprecated. Use modify instead.

- ...:

  Additional arguments passed to `method.sim`.

## Value

A data.frame with simulation results (same number of rows as input
data). If \`sge=TRUE\` a character vector with paths to simulation
control streams.

## Details

Loosely speaking, the argument `method.sim` defines \_what\_ NMsim will
do, `method.execute` define \_how\_ it does it. `method.sim` takes a
function that converts an estimation control stream into whatever should
be run. Features like replacing \`\$INPUT\`, \`\$DATA\`, \`\$TABLE\`,
and handling seeds are NMsim features that are done in addition to the
`method.sim`. Also the `modeify.model` argument is handled in addition
to the `method.sim`. The `subproblems` and `seed.nm` arguments are
available to all methods creating a `$SIMULATION` section.

Notice, the following functions are internally available to \`NMsim\` so
you can run them by say `method.sim=NMsim_EBE` without quotes. To see
the code of that method, type `NMsim_EBE`.

- `NMsim_default` The default behaviour. Replaces any \$ESTIMATION and
  \$COVARIANCE sections by a \$SIMULATION section.

- `NMsim_asis` The simplest of all method. It does nothing (but again,
  `NMsim` handles \`\$INPUT\`, \`\$DATA\`, \`\$TABLE\` and more. Use
  this for instance if you already created a simulation (or estimation
  actually) control stream and want NMsim to run it on different data
  sets.

- `NMsim_EBE` Simulates \_known\_ ETAs. By default, the ETA values are
  automatically taken from the estimation run. This is what is refered
  to as emperical Bayes estimates, hence the name of the method
  "NMsim_EBE". However, the user can also provide a different \`.phi\`
  file which may contain simulated ETA values (see the \`file.phi\`
  argument). ID values in the simulation data set must match ID values
  in the phi file for this step to work. If refering to estimated
  subjects, the .phi file from the estimation run must be found next to
  the .lst file from the estimation with the same file name stem (say
  \`run1.lst\` and \`run1.phi\`). Again, ID values in the (simulation)
  input data must be ID values that were used in the estimation too. The
  method Runs an `$ESTIMATION MAXEVAL=0` but pulls in ETAs for the ID's
  found in data. No `$SIMULATION` step is run which unfortunately means
  no residual error will be simulated.

- `NMsim_VarCov` Like `NMsim_default` but \`\$THETA\`, \`\$OMEGA\`, and
  \`SIGMA\` are drawn from distribution estimated in covariance step.
  This means that a successful covariance step must be available from
  the estimation. NB. A multivariate normal distribution is used for all
  parameters, including \`\$OMEGA\` and \`\$SIGMA\` which is not the
  correct way to do this. In case the simulation leads to negative
  diagonal elements in \$OMEGA and \$SIGMA, those values are truncated
  at zero. This method is only valid for simulation of \`\$THETA\`
  variability. The method accepts a table of parameter values that can
  be produced with other tools than \`NMsim\`. For simulation with
  parameter variability based on bootstrap results, use `NMsim_default`.
