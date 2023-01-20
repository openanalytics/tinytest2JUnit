# tinytest2JUnit

Convert tinytest test's results ouptut to JUnit xml to allow it to be used in the jenkins pipeline.

# disclaimer

This package very much in exploration phase and has not any fixed api.
Also currently not functional.

# Core ideas:

Extract needed info from a tinytest S3 result object (output of `tinytest::run_test_dir()` for example)

See vingette in vignet `vignette("using_tinytest", package="tinytest")`
* section 2.3 to get an idea on what info is present
* section 3.1 to get info from a tinytests object to data.frame

Format the output to JUnit.xml specs as described in this reference: https://llg.cubic.org/docs/junit/