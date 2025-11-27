# Simulation of residual variability

## Add residual variability

The best way to simulate with residual variability is to include the it
in the estimation control stream as described in this vignette. `NMsim`
currently does not provide any automated way to add simulation of
residual variability with Nonmem. It does provide a method to simulate
residual variability in R, based on the Nonmem parameter estimates. This
should only be used in case one has an existing Nonmem without residual
variability simulated, and it is not feasible to modify the model
control stream for some reason. The function is called
[`addResVar()`](https://nmautoverse.github.io/NMsim/reference/addResVar.md)
and supports additive, proportional, and combined (additive and
proportional) error models. It can also add the residual error on log
scale (exponential error model).

`addResVar` supports both estimation using `$SIGMA` and `$THETA` (in
Nonmem). The user has to specify which of the two methods were used in
the Nonmem model using the `par.type` argument. The other thing that
must be specified is the parameter numbers for the standard deviations
or variances. The model simulated in this vignette has this combined
error model estimated using the `$SIGMA` matrix:

    Y=F+F*ERR(1)+ERR(2)

We now specify for `addResVar` to find the variance for the proportional
component in `$SIGMA[1,1]` and the one for the additive component in
`$SIGMA[2,2]`. In this case where `SIGMA` is used, the off-diagonal
(covariance) elements of the `$SIGMA` matrix are also used for the
simulation.

``` r
file.mod <- file.project("nonmem/xgxr021.mod")

simres <- NMsim(file.mod=file.mod,
                data=dat.sim)
```

``` r
simres.with.resvar <- addResVar(simres,path.ext=fnExtension(file.mod,"ext"),par.type="SIGMA",prop=1,add=2)
```

If `par.type="THETA"` the default assumption is that the thetas
represent standard deviation (in contrast to when using
`par.type="SIGMA"`). This can be modified using the `scale.par`
argument. There are arguments to avoid negative observations and several
other features. But again, this should be the last resort.
