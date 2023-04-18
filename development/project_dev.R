

roxygen2::roxygenize("tinytest2JUnit")

library(tinytest)

# tiny test examples

out <- tinytest::run_test_dir(system.file("tinytest", package="tinytest"), verbose=0)
summary(out)
tinytest::run_test_dir(system.file("tinytest", package="tinytest"))


tinytest::test_package("tinytest2JUnit", testdir = "inst/example_tests/heavy_calculations")
tinytest::test_package("tinytest2JUnit", testdir = "inst/tinytest")
	


out <- tinytest::run_test_dir("inst/tinytest", at_home = FALSE)

test_all(pkgdir = "tinytest2JUnit", testdir = "inst/example_tests/multiple_files")
summary(out)
#test_check("project_pkg")
#run all tests in package
#devtools::test('project_pkg')

#path <- file.path(pkg_root(), "project_pkg/tests/testthat")
#test_file(file.path(path, "test-fetchers.R"), reporter = default_reporter())
#test_file(file.path(path, "test-gwas.R"), reporter = default_reporter())


