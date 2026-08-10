check_rbuildignore <- function(path) {
  rules <- readLines(".Rbuildignore")
  rules <- rules[nzchar(rules) & !grepl("^#", rules)]  # drop blanks/comments
  
  matches <- sapply(rules, function(rule) grepl(rule, path, perl = TRUE))
  
  if (any(matches)) {
    cat("Path matched by:\n")
    print(rules[matches])
  } else {
    cat("No rules match this path.\n")
  }
}

## check_rbuildignore("inst/testdata/somefile.csv")
