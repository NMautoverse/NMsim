# Get NMsim model metadata

Get NMsim model metadata

## Usage

``` r
modTab(res)
```

## Arguments

- res:

  NMsim results (class \`NMsimRes\`).

## Value

A table with model details

## Details

- ROWMODEL (integer): A unique row identifier

- file.mod (character): Path to the originally provided input control
  stream, relative to current working directory.

- path.sim (character): Path to the simulation input control stream,
  relative to current working directory.

- path.rds (character): Path to the results meta data file (\_path.rds0)

- model (character): The name of the original model, no extension.
  Derived from file.mod. If file.mod is named, the provided name is
  used.;

- model.sim (character): A unique and cleaned (no special characters)
  name for the derived model, without extension. Notice if a simulation
  method generates multiple models, model.sim will be distinct for
  those. This is unlike model and name.sim.

- name.sim (character): The value of the NMsim() argument of the same
  name at function call.

- fn.sim (character): Name of the mod file to be simulated. Has .mod
  extension. It will differ from file mod in being derived from
  model.sim so it is unique and cleaned.

- dir.sim (character): Relative path from point of execution to
  simulation directory. Cleaned.

- path.mod.exec (character): Path to the control stream executed by
  Nonmem, relative to current working directory.
