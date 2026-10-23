##' Get NMsim model metadata
##'
##' @param res NMsim results (class `NMsimRes`).
##' @return A table with model details
##' @details
##' \itemize{
##' \item ROWMODEL (integer): A unique row identifier
##' \item file.mod (character): Path to the originally provided input control stream, relative to current working directory.
##' \item path.sim (character): Path to the simulation input control stream, relative to current working directory.
##' \item path.rds (character):  Path to the results meta data file (_path.rds0)
##' \item model (character): The name of the original model, no extension. Derived from file.mod. If file.mod is named, the provided name is used.;
##' \item model.sim (character): A unique and cleaned (no special characters) name for the derived model, without extension. Notice if a simulation method generates multiple models, model.sim will be distinct for those. This is unlike model and name.sim.
##' \item name.sim (character): The value of the NMsim() argument of the same name at function call.
##' \item fn.sim (character): Name of the mod file to be simulated. Has .mod extension. It will differ from file mod in being derived from model.sim so it is unique and cleaned.
##' \item dir.sim (character): Relative path from point of execution to simulation directory. Cleaned.
##' \item path.mod.exec (character): Path to the control stream executed by Nonmem, relative to current working directory.
##' }
##' @export


modTab <- function(res){
  if(is.character(res)) {
    res <- readRDS(res)
  }
    attributes(res)$NMsimModTab
}
