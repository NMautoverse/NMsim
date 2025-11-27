# Remove NMsimRes class and discard NMsimRes meta data

Remove NMsimRes class and discard NMsimRes meta data

Check if an object is 'NMsimRes'

Basic arithmetic on NMsimRes objects

## Usage

``` r
unNMsimRes(x)

is.NMsimRes(x)

# S3 method for class 'NMsimRes'
merge(x, ...)

# S3 method for class 'NMsimRes'
t(x, ...)

# S3 method for class 'NMsimRes'
dimnames(x, ...)

# S3 method for class 'NMsimRes'
rbind(x, ...)

# S3 method for class 'NMsimRes'
cbind(x, ...)
```

## Arguments

- x:

  an NMsimRes object

- ...:

  arguments passed to other methods.

## Value

x stripped from the 'NMsimRes' class

logical if x is an 'NMsimRes' object

An object that is not of class 'NMsimRes'.

## Details

When 'dimnames', 'merge', 'cbind', 'rbind', or 't' is called on an
'NMsimRes' object, the 'NMsimRes' class is dropped, and then the
operation is performed. So if and 'NMsimRes' object inherits from
'data.frame' and no other classes (which is default), these operations
will be performed using the 'data.frame' methods. But for example, if
you use 'as.fun' to get a 'data.table' or 'tbl', their respective
methods are used instead.
