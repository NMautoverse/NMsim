##' Process args.unwrap specification into unwrap functions
##'
##' Converts the user-friendly args.unwrap specification into a list of
##' functions that can be applied to arguments. Handles the "function" keyword
##' and validates custom functions.
##'
##' @param args.unwrap Named list with unwrap specifications. Values can be:
##'   - "function" (string) to unwrap functions by code only
##'   - A function to apply to the argument
##'   - NULL (ignored)
##' @param args Named list of actual argument values (used to auto-detect functions)
##' @return Named list of functions to apply to arguments
##' @keywords internal

### Copied from recycle. Don't edit, don't export.

process_args_unwrap <- function(args.unwrap, args = NULL) {
  
  # Validate args.unwrap if provided
  if (!is.null(args.unwrap)) {
    if (!is.list(args.unwrap)) {
      stop("'args.unwrap' must be a named list")
    }
    
    if (is.null(names(args.unwrap)) || any(names(args.unwrap) == "")) {
      stop("'args.unwrap' must be a named list with all elements named")
    }
  }
  
  funs.unwrap <- list()

  
  
  # Auto-detect function arguments and add default "function" unwrapping
  if (!is.null(args)) {
    for (arg_name in names(args)) {
      if (is.function(args[[arg_name]])) {
        # Only add if not already specified in args.unwrap
        if (is.null(args.unwrap) || is.null(args.unwrap[[arg_name]])) {
          funs.unwrap[[arg_name]] <- function(f) {
            if (is.function(f)) {
              list(as.character(body(f)), formals(f))
            } else {
              f
            }
          }
        }
      }
    }
  }
  
  # Process explicit args.unwrap specifications (these override auto-detection)
  if (is.null(args.unwrap)) {
    return(if (length(funs.unwrap) > 0) funs.unwrap else NULL)
  }
  
  for (arg_name in names(args.unwrap)) {
    unwrap_spec <- args.unwrap[[arg_name]]
    
    if (is.null(unwrap_spec)) {
      # Skip NULL entries
      next
    }  else if (is.function(unwrap_spec)) {
      # Use the provided function directly
      funs.unwrap[[arg_name]] <- unwrap_spec
    } else {
      stop(sprintf("Invalid unwrap specification for argument '%s'. Must be 'function' keyword or a function",
                   arg_name))
    }
  }
  
  return(funs.unwrap)
}
