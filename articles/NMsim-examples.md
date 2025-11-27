# NMsim Examples

The examples aim at sharing used code to handle simulation-based
workflows with NMsim. When building your own code, please also see the
manuals of key functions,
[`?NMsim`](https://nmautoverse.github.io/NMsim/reference/NMsim.html)
being an obvious example.

[NMsim - Seamless NONMEM Simulation Platform in
R](https://nmautoverse.github.io/NMsim/articles/NMsim-intro.md) is the
place to start. It contains basic information to get you started and
demonstrates the most common types of simulations.

You can let your interests guide your next topic. Use [Requirements and
Configuration](https://nmautoverse.github.io/NMsim/articles/NMsim-config.md)
as needed. If you have not yet run your first successful
[`NMsim()`](https://nmautoverse.github.io/NMsim/reference/NMsim.md)
calls, it’s worth a read, at least half-through.

For simulation with variability on parameters (`$THETA`’s, `$OMEGA`’s,
and `$SIGMA`’s), currently most up to date is [NMsim - Simulation-Based
Forest Plots with
NMsim](https://nmautoverse.github.io/NMsim/articles/NMsim-forest.md)

Also, see recent
[Publications](https://nmautoverse.github.io/NMsim/articles/NMsim-publications.md).

## [**NMsim - Seamless NONMEM Simulation Platform in R**](https://nmautoverse.github.io/NMsim/articles/NMsim-intro.md)

#### Philip Delff

- Configuration  
- Simulation of typical subjects and new subjects  
- Creation of Simulation data sets  
- Simulate multiple models  
- Reuse Emperical Bayes’ Estimates (known ETAs)  
- Read previously generated simulations

## [**Data Set Creation with NMsim**](https://nmautoverse.github.io/NMsim/articles/NMsim-DataCreate.md)

#### Philip Delff

- Create Dosing Events
- Add Sampling Events
- Add Time After Previous Dose and Related Information
- Multiple Endpoints (e.g. parent and metabolite)
- Cohort-Dependent or Individual Sampling Schemes

## [**Simulate Known Subjects Using Emperical Bayes Estimates (Etas)**](https://nmautoverse.github.io/NMsim/articles/NMsim-known.md)

#### Philip Delff

## [**VPC Simulations**](https://nmautoverse.github.io/NMsim/articles/NMsim-VPC.md)

#### Philip Delff

- Reuse Estimation Data for Simulation
- Plotting using `tidyvpc`
- Use a different input data set: Change the ACCEPT/IGNORE Statements
- Use a different input data set: Manually Subset Data

## [**Simulation-Based Forest Plots with NMsim**](https://nmautoverse.github.io/NMsim/articles/NMsim-forest.md)

#### Philip Delff, Boris Grinshpun

- Generation of Simulation Input Data
- Define Covariates to Analyze
- Simulation With Parameter Uncertainty
- Post processing
- Plotting
- Comparison of Different Simulation Methods
- Post-Processing Step-By-Step

## [**Simulation with Parameter Uncertainty**](https://nmautoverse.github.io/NMsim/articles/NMsim-ParamUncertain.md)

#### Philip Delff

## [**Simulation with Modifications to Parameters and Model Code**](https://nmautoverse.github.io/NMsim/articles/NMsim-modify-model.md)

#### Philip Delff, Simone Cassani

- Control whether and how to update parameter values according to the
  final model parameter estimates using the `inits` argument.
- Modify model parameter values (`$THETA`, `$OMEGA` and `SIGMA`) to
  specify values using the `inits` argument
- Use the `modify` argument to do custom manipulations of any parts of
  the control stream before simulation.
- Modify data exclusions/inclusions (`$IGNORE/$ACCEPT`) using the
  `filters` argument.
- Adjust `$SIZES` variables using the `sizes` argument.

## [**Requirements and Configuration**](https://nmautoverse.github.io/NMsim/articles/NMsim-config.md)

#### Philip Delff

- Specify the path to the Nonmem executable (`path.nonmem`).  
- Set default values for `path.nonmem` and output directories.

## Examples waiting for updates

## [**Simulation of residual variability**](https://nmautoverse.github.io/NMsim/articles/NMsim-ResidVar.md)

#### Philip Delff

## [**Reuse simulated subjects**](https://nmautoverse.github.io/NMsim/articles/NMsim-ReuseSimSubjects.md)

#### Philip Delff

## [**NMsim and speed**](https://nmautoverse.github.io/NMsim/articles/NMsim-speed.md)

#### Philip Delff
