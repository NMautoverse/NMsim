context("NMseed")

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

