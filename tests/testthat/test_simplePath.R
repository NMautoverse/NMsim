context("simplePath")

test_that("basic",{

    expect_equal(simplePath("hel/wee/ww"),"hel/wee/ww")
    expect_equal(simplePath("hel/wee/../wee/ww"),"hel/wee/ww")
    expect_equal(simplePath("/hel/wee/ww"),"/hel/wee/ww")
    expect_equal(simplePath("//hel/wee/ww"),"/hel/wee/ww")
    expect_equal(simplePath("c://hel/wee/ww"),"c:/hel/wee/ww")
    expect_equal(simplePath("c:/hel/wee/ww"),"c:/hel/wee/ww")
    expect_equal(simplePath("c:/hel/wee/ ww"),"c:/hel/wee/ ww")
    expect_equal(simplePath("c:/hel/wee/  ww"),"c:/hel/wee/  ww")

    expect_equal(simplePath("../hel/wee/ww"),"../hel/wee/ww")
    expect_equal(simplePath("./hel/wee/ww"),"hel/wee/ww")

})

test_that("tilde",{

    expect_equal(NMsim:::simplePath("~/hel/wee/ww"),"~/hel/wee/ww")
    
})


test_that("many ..",{

  expect_equal(
    NMsim:::simplePath("vignettes/simulate-results/../../../../tmp/simtmp_nmsim_readme/xgxr021_readme1/xgxr021_readme1.lst")
   ,
    "../../tmp/simtmp_nmsim_readme/xgxr021_readme1/xgxr021_readme1.lst"
  )

})
