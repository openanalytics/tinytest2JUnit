
# Tinytest2JUnit

<!-- badges: start -->
[![R-CMD-check](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml/badge.svg)](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml)
<!-- badges: end -->

## Overview

A package to convert [tinytest](https://github.com/markvanderloo/tinytest) results to JUnit XML.
This enables processing of test results by CI/CD systems such as GitLab Runner or Jenkins.

## Core idea:

* Extract needed info from a tinytest S3 result object (output of `tinytest::run_test_dir()`)
* Format the output to JUnit.xml specs as described in this reference: https://llg.cubic.org/docs/junit/

## Basic Usage

The `writeJUnit()` function excepts any object of class tinytests and converts it to a JUnit XML file that can be interpreted by CI/CD systems.

```r
testresults <- tinytest::run_test_dir("pkgdir")
writeJUnit(testresults, file = "output.xml", overwrite = TRUE)

```

## Install

From the OA public repository:

```r
install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))
```



## Related

* tinytest package: https://github.com/markvanderloo/tinytest
* JUnit reporter in `testthat`: https://testthat.r-lib.org/reference/JunitReporter.html

**(c) Copyright Open Analytics NV, 2012-2023 - Apache License 2.0**
