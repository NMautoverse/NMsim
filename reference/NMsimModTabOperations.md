# Remove NMsimModTab class and discard NMsimModTab meta data

Remove NMsimModTab class and discard NMsimModTab meta data

Check if an object is 'NMsimModTab'

Basic arithmetic on NMsimModTab objects

## Usage

``` r
unNMsimModTab(x)

is.NMsimModTab(x)

# S3 method for class 'NMsimModTab'
merge(x, ...)

# S3 method for class 'NMsimModTab'
t(x, ...)

# S3 method for class 'NMsimModTab'
dimnames(x, ...)

# S3 method for class 'NMsimModTab'
rbind(x, ...)

# S3 method for class 'NMsimModTab'
cbind(x, ...)
```

## Arguments

- x:

  an NMsimModTab object

- ...:

  arguments passed to other methods.

## Value

x stripped from the 'NMsimModTab' class

logical if x is an 'NMsimModTab' object

An object that is not of class 'NMsimModTab'.

## Details

When 'dimnames', 'merge', 'cbind', 'rbind', or 't' is called on an
'NMsimModTab' object, the 'NMsimModTab' class is dropped, and then the
operation is performed. So if and 'NMsimModTab' object inherits from
'data.frame' and no other classes (which is default), these operations
will be performed using the 'data.frame' methods. But for example, if
you use 'as.fun' to get a 'data.table' or 'tbl', their respective
methods are used instead.
