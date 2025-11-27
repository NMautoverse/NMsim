# Internal method for handling modify argument to NMsim

Internal method for handling modify argument to NMsim

## Usage

``` r
modifyModel(modify, dt.models = NULL, list.ctl = NULL)
```

## Arguments

- modify:

  A list

- dt.models:

  a data.table

- list.ctl:

  List of coontrol streams as lines

## Value

dt.models (data.table) or result list.ctl (list) depending on whether
the \`dt.models\` or the \`list.ctl\` argument was provided.
