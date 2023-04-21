
test_that('skip_partial_tests', {
			
testthat::expect_true(TRUE)

skip_if_not(TRUE)

expect_true(FALSE, "this should not be run")
})
