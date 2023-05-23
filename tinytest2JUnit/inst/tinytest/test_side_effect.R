
# Test to be deleted but just to see how side-effects get's displayed in Jenkins

report_side_effects()

expect_true(TRUE, info = "Called before side-effect")
Sys.setenv(Hello="World")
expect_true(TRUE, info = "Called after side-effect")

