# Requirements and Configuration

## Objectives

This vignettes aims at enabling you to

- Understand requirements for using NMsim

- Configure `NMsim` to use `PSN` or methods provided by `NMsim` to
  update Nonmem control stream initial values and to run Nonmem

- Understand pros and cons of using `PSN` vs. methods provided by
  `NMsim`.

- Configure `NMsim` to store results in desired locations and separate
  storage of temporary files and storage of selected and efficiently
  stored key result data.

## Requirements

`NMsim` itself and many features will work in any newer R installation.
For a seamless simulation experience within R, Nonmem installations on
linux, Windows and Mac are supported. Multi-threaded execution may
currently not work on Windows.

`NMsim` relies on Nonmem for running simulations. For a fully seamless
simulation experience within R, NMsim must be able to execute Nonmem.
The simplest example where this is easily achieved, is when R and Nonmem
run on the same system. If they are on separate systems, the questions
are: Do R and Nonmem share access to a data structure where the relevant
files can be stored and executed? And can R login to that other system
to run Nonmem, for instance through SSH? In case these two criteria are
met, the fully seamless experience should still be possible.

If your system does not meet these requirements, it does not mean that
NMsim can’t work. It can still put together your Nonmem simulation
control streams and data and make everything ready for Nonmem to
execute. Once you have run Nonmem, you can then use
[`NMsim::NMreadSim()`](https://nmautoverse.github.io/NMsim/reference/NMreadSim.md)
to collect the results.

## Configuration of NMsim

Below this section, some background discussion is provided to understand
which methods to choose. No matter what you prefer to use, the best is
to set up `NMsim` to be able to use both Nonmem and (if available) PSN.
Then you have the flexibility to switch between methods as preferred.

### Specify the Nonmem paths

For `NMsim` to run Nonmem, it needs to know where to find the Nonmem
executable. This step is recommended.

The easiest way to configure this is through NMdata’s configuration
function. Say you want to run Nonmem with `/opt/NONMEM/nm75/run/nmfe`,
insert this after loading `NMdata` in the beginning of your script

``` r
NMdataConf(path.nonmem="/opt/NONMEM/nm75/run/nmfe75")
```

On Windows, the executable has a `.bat` extension. The path could look
be

``` r
NMdataConf(path.nonmem ="C:/nm75g64/run/nmfe75.bat")
```

If you normally use PSN as your Nonmem interface, and you do not know
where Nonmem is installed, you can check this using PSN. The following
command should give you the Nonmem installation paths that PSN is
configured with. However, you likely still need to add the last piece of
the path from the installation directory to the nonmem binary.

    psn -nm_versions

If you need to execute scripts on systems with different Nonmem
installation paths, you can select between a prioritized set of paths
like this, taking the first one found:

``` r
paths.nm <- c("/opt/NONMEM/nm75/run/nmfe75",
              "/opt/nonmem/nm751/run/nmfe75",
              "C:/nm75g64/run/nmfe75.bat")
path.nonmem <- paths.nm[min(which(file.exists(paths.nm)))]

NMdataConf(path.nonmem=path.nonmem)
```

### Specify the PSN installation path

If PSN is available, and you can run `execute` and `update_inits` in a
terminal, you don’t need to configure how NMsim finds PSN. If you have
PSN installed, but you have to provide the paths to those two
executables when running them (something like
`/opt/PSN/execute run1.mod`), you will have to tell NMsim where to find
them. In this case, the easiest is loading NMdata and then running:

``` r
NMdataConf(dir.psn="/opt/PSN")
```

Notice `dir.psn` refers to a directory while `path.nonmem` refers to a
file.

### Test NMsim Configuration

Whether NMsim finds Nonmem after the configuration steps above can be
checked by running
[`NMsimTestConf()`](https://nmautoverse.github.io/NMsim/reference/NMsimTestConf.md).
Look for `$path.nonmem` (where NMsim is looking for the executable),
`$exists.path.nonmem` (whether the executable is found), and
`$method.execute` (which method is selected - “nmsim” is prefered).

### Configure the directories `NMsim` writes to

`NMsim` creates two main directories for its output.

#### `dir.sims`

- simulation control streams and other data created by NMsim

- output written by Nonmem

- By far, the largest directory

These files are not necessarily needed for further storage.

#### `dir.res`

Selected and efficiently stored simulation output data.

- `_paths.rds` which contains an index table for \`NMreadSim()1. It does
  not contain any simulated data and is of insignificant size.

- `.fst` is the full simulation output data set.
  [`NMreadSim()`](https://nmautoverse.github.io/NMsim/reference/NMreadSim.md)
  will automatically create this file the first time it reads
  `_paths.rds`. The user does not need to know about the `fst` format as
  they will keep reading the simulation results via
  [`NMreadSim()`](https://nmautoverse.github.io/NMsim/reference/NMreadSim.md)
  on `_paths.rds`.

You must make sure to preserve this directory in case you will need to
re-analyze or further analyze the simulation output without re-running
the simulations.

## Additional configuration options

### Choosing Nonmem execution method

NMsim can call Nonmem using PSN’s `execute` or through similar
functionality included in NMsim. We will refer to those methods by the
way they are referred to in the
[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
function argument that controls which one is used,
i.e. `method.execute="psn"` and `method.execute="nmsim"`. While `PSN`
users will be familiar with what `PSN`’s `execute` does,
`method.execute="nmsim"` needs a few words of explanation. It is
essentially an R-based method similar to `PSN`’s `execute`, meaning it
creates a temporary folder containing necessary files for running
Nonmem, then runs `nmfe` (as specified using `path.nonmem`) and then
copies the desired result files back to the location of the input
control stream. `NMsim` can control the behavior of this function better
than it can `PSN`’s execute which enables NMsim to do additional things
with `method.execute="nmsim"`.

For simulations, `method.execute="psn"` does not provide advantages over
`method.execute="nmsim"`. In contrast, there are simulation types that
will only work with `method.execute="nmsim"`. You need to tell NMsim
where to find Nonmem (by setting `path.nonmem`) for this to work.

### Choosing method for updating initial values

NMsim needs to update initial values using the model estimate prior to
running a simulation.

PSN provides the `update_inits` function to do this. We refer to this by
how it is enabled in NMsim, `inits=list(method="psn")`.

NMsim also provides a similar functionality internally, referred to as
`inits=list(method="NMsim")`. This is the default method and comes with
advanced features such as conservation of structure and comments of
parameter sections, and a fully featured interface to specify values and
features such as “fix” or limits of parameters.

`inits=list(method="psn")` may be prefered by users who are familiar
with PSN. `inits=list(method="psn")` has additional features, and no
known down-sides.

In order to make use of `inits=list(method="psn")`, you need to make
sure NMsim can find PSN. If you want to use `inits=list(method="NMsim")`
you don’t need to do anything.

## Note on file name extensions

The following requirements to file name and their contents concerns the
“input model”. It does not concern files generated by `NMsim`.

There is no requirement to the file name extension of the input control
stream. The input control stream can have any extension (e.g., `.ctl` or
`.txt`). However, `NMsim` documentation and `file.mod` - the important
argument to
[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md) and
other functions - refer to input control streams by the PSN inspired
`.mod` extension.

The estimate files (`.ext`, `.phi` if known subjects simulated, `.cov`
if simulating parameters from the covariance step) are by default
expected to carry the same file name but with those file name extension.
See arguments like `file.ext` and `file.phi` to specify other paths.
Currently, the default behavior cannot be customized and the two
arguments will have to be provided at each NMsim() call to the extend
relevant for the simulation.

Output table files from input model may be needed. This is the case
using `NMsim_known` on models estimated using Bayesian `$ESTIMATION`
methods like `SAEM` and/or `$IMP`. In this case `NMsim` will need to
find all the `ETA` values for all subjects, even if spread across the
output tables. This is because these estimation methods leave `PHI`
instead of `ETA` in the `.phi` file. For emperical Bayes estimates,
`NMsim` needs the `ETA`s.

There are no limitations to the file names of the output tables.
