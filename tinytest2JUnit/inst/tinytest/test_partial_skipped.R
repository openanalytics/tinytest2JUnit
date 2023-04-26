
expect_true(TRUE, "this should be run")

exit_if_not(TRUE, msg = "Skipping the rest of the tests")

expect_true(FALSE, "this should not be run")