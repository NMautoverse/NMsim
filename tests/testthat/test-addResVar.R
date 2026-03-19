test_that("addResVar works with SIGMA parameters - proportional error only", {
    skip_if_not_installed("NMdata",minimum_version = "0.2.3.920")
    
                                        # Create test data
    data <- data.frame(
        ID = rep(1:10, each = 5),
        TIME = rep(0:4, 10),
        IPRED = rep(c(10, 20, 30, 40, 50), 10)
    )
    
                                        # Create mock ext file content
    ## ext_content <- data.frame(
    ##     ITERATION = -1000000000,
    ##     THETA1 = 1.0,
    ##     "SIGMA(1,1)" = 0.04,
    ##     "SIGMA(2,1)" = 0,
    ##     "SIGMA(2,2)" = 0.01
    ## )



    
                                        # Create temporary ext file
    temp_ext <- tempfile(fileext = ".ext")
    if(file.exists(temp_ext)) unlink(temp_ext)
    cat("ITERATION THETA1 SIGMA(1,1) SIGMA(2,1) SIGMA(2,2)\n
-1e+09 1 0.04 0 0.01",file=temp_ext)

    ## write.table(ext_content, temp_ext, row.names = FALSE, quote = FALSE)

    
    pars <- NMreadExt(temp_ext,as.fun="data.table",return="pars")

                                        # Run addResVar
    result <- addResVar(
        data = data,
        path.ext = temp_ext,
        prop = 1,
        add = NULL,
        par.type = "SIGMA",
        seed = 123,
        as.fun = as.data.frame
    )
    
                                        # Check that IPREDVAR column was created
    expect_true("IPREDVAR" %in% names(result))
    
                                        # Check that all rows have IPREDVAR values
    expect_equal(nrow(result), nrow(data))
    expect_true(all(!is.na(result$IPREDVAR)))
    
                                        # Check that IPREDVAR is different from IPRED (due to error)
    expect_false(all(result$IPREDVAR == result$IPRED))
    
                                        # Clean up
    unlink(temp_ext)
})
