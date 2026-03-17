test_that("deleteTmpDirs identifies NMsim temporary directories", {
    skip_if_not_installed("NMdata")
    
    # Create a temporary test directory
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create some NMsim-style temporary directories
    dir.create(file.path(test_dir, "model_dir1"))
    dir.create(file.path(test_dir, "model_dir2"))
    dir.create(file.path(test_dir, "simulation_dir10"))
    
    # Create a non-matching directory
    dir.create(file.path(test_dir, "regular_folder"))
    
    # Find but don't delete
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check that NMsim directories were found
    expect_true(nrow(result) >= 3)
    expect_true(all(grepl("_dir[0-9]+$", result$find)))
    
    # Check that regular folder was not found
    expect_false(any(grepl("regular_folder", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs identifies PSN temporary directories", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create PSN-style temporary directories
    dir.create(file.path(test_dir, "m1.dir1"))
    dir.create(file.path(test_dir, "run001.dir5"))
    dir.create(file.path(test_dir, "_test.dir99"))
    
    # Create a non-matching directory
    dir.create(file.path(test_dir, "model.directory"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "psn",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check that PSN directories were found
    expect_true(nrow(result) >= 3)
    expect_true(all(grepl("\\.dir[0-9]+$", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs identifies PSN modelfit directories", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create PSN modelfit-style directories
    dir.create(file.path(test_dir, "modelfit_dir1"))
    dir.create(file.path(test_dir, "modelfit_dir25"))
    dir.create(file.path(test_dir, "run1_modelfit_dir3"))
    
    # Create a non-matching directory
    dir.create(file.path(test_dir, "modelfit"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "psnfit",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check that modelfit directories were found
    expect_true(nrow(result) >= 3)
    expect_true(all(grepl("modelfit_dir\\d+", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs identifies backup files", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create backup-style files/directories
    dir.create(file.path(test_dir, "backup_001"))
    dir.create(file.path(test_dir, "backup_old"))
    dir.create(file.path(test_dir, "backup_2024"))
    
    # Create a non-matching directory
    dir.create(file.path(test_dir, "backup"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "backup",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check that backup directories were found
    expect_true(nrow(result) >= 3)
    expect_true(all(grepl("backup_.+", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs works with multiple methods", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create directories matching different patterns
    dir.create(file.path(test_dir, "model_dir1"))
    dir.create(file.path(test_dir, "run.dir2"))
    dir.create(file.path(test_dir, "modelfit_dir3"))
    dir.create(file.path(test_dir, "backup_old"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = c("nmsim", "psn", "psnfit", "backup"),
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check that all types were found
    expect_true(nrow(result) >= 4)
    expect_true(any(result$method == "nmsim"))
    expect_true(any(result$method == "psn"))
    expect_true(any(result$method == "psnfit"))
    expect_true(any(result$method == "backup"))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs actually deletes when delete=TRUE", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create temporary directories
    tmp_dir1 <- file.path(test_dir, "test_dir1")
    tmp_dir2 <- file.path(test_dir, "test_dir2")
    dir.create(tmp_dir1)
    dir.create(tmp_dir2)
    
    # Verify they exist
    expect_true(dir.exists(tmp_dir1))
    expect_true(dir.exists(tmp_dir2))
    
    # Delete them
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = TRUE,
        as.fun = as.data.frame
    )
    
    # Verify they were deleted
    expect_false(dir.exists(tmp_dir1))
    expect_false(dir.exists(tmp_dir2))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs does not delete when delete=FALSE", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create temporary directories
    tmp_dir1 <- file.path(test_dir, "test_dir1")
    tmp_dir2 <- file.path(test_dir, "test_dir2")
    dir.create(tmp_dir1)
    dir.create(tmp_dir2)
    
    # Find but don't delete
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Verify they still exist
    expect_true(dir.exists(tmp_dir1))
    expect_true(dir.exists(tmp_dir2))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs works recursively", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create nested structure
    subdir <- file.path(test_dir, "subdir")
    dir.create(subdir)
    dir.create(file.path(subdir, "nested_dir1"))
    dir.create(file.path(test_dir, "top_dir1"))
    
    # Search recursively
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        recursive = TRUE,
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Should find both top-level and nested directories
    expect_true(nrow(result) >= 2)
    expect_true(any(grepl("nested_dir1", result$find)))
    expect_true(any(grepl("top_dir1", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs works non-recursively", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create nested structure
    subdir <- file.path(test_dir, "subdir")
    dir.create(subdir)
    dir.create(file.path(subdir, "nested_dir1"))
    dir.create(file.path(test_dir, "top_dir1"))
    
    # Search non-recursively
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        recursive = FALSE,
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Should only find top-level directory
    expect_true(nrow(result) >= 1)
    expect_false(any(grepl("nested_dir1", result$find)))
    expect_true(any(grepl("top_dir1", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs handles empty directory", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # No matching directories
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Should return empty result
    expect_equal(nrow(result), 0)
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs handles non-existent directory gracefully", {
    skip_if_not_installed("NMdata")
    
    non_existent_dir <- file.path(tempdir(), "does_not_exist_12345")
    
    # Should not error
    expect_error(
        deleteTmpDirs(
            dir = non_existent_dir,
            methods = "nmsim",
            delete = FALSE,
            as.fun = as.data.frame
        ),
        NA
    )
})

test_that("deleteTmpDirs returns correct structure", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    dir.create(file.path(test_dir, "test_dir1"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Check structure
    expect_true(is.data.frame(result))
    expect_true("method" %in% names(result))
    expect_true("pattern" %in% names(result))
    expect_true("find" %in% names(result))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs uses default methods when methods=NULL", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create directories matching different default patterns
    dir.create(file.path(test_dir, "model_dir1"))
    dir.create(file.path(test_dir, "run.dir2"))
    
    # Use default methods (should be all)
    result <- deleteTmpDirs(
        dir = test_dir,
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Should find directories with default methods
    expect_true(nrow(result) >= 2)
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs handles files with content", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create directory with files inside
    tmp_dir <- file.path(test_dir, "test_dir1")
    dir.create(tmp_dir)
    writeLines("test content", file.path(tmp_dir, "file.txt"))
    
    # Delete should work recursively
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = TRUE,
        as.fun = as.data.frame
    )
    
    # Directory and its contents should be deleted
    expect_false(dir.exists(tmp_dir))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs preserves data.table class when requested", {
    skip_if_not_installed("NMdata")
    skip_if_not_installed("data.table")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    dir.create(file.path(test_dir, "test_dir1"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = "data.table"
    )
    
    expect_true(data.table::is.data.table(result))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs case sensitivity works correctly", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create directories with different cases
    dir.create(file.path(test_dir, "test_dir1"))
    dir.create(file.path(test_dir, "TEST_dir2"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # At least the lowercase one should be found
    # Case sensitivity depends on the file system
    expect_true(nrow(result) >= 1)
    expect_true(any(grepl("test_dir1", result$find)))
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})

test_that("deleteTmpDirs handles special characters in directory names", {
    skip_if_not_installed("NMdata")
    
    test_dir <- tempfile()
    dir.create(test_dir)
    
    # Create directory with special characters (that still match pattern)
    dir.create(file.path(test_dir, "test-model_dir1"))
    dir.create(file.path(test_dir, "test.model_dir2"))
    
    result <- deleteTmpDirs(
        dir = test_dir,
        methods = "nmsim",
        delete = FALSE,
        as.fun = as.data.frame
    )
    
    # Should find directories ending with _dir[0-9]+
    expect_true(nrow(result) >= 2)
    
    # Clean up
    unlink(test_dir, recursive = TRUE)
})
