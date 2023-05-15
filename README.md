
# Tinytest2JUnit

<!-- badges: start -->
[![R-CMD-check](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml/badge.svg)](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml)
<!-- badges: end -->

## Overview

A package to convert [tinytest](https://github.com/markvanderloo/tinytest) results to JUnit XML.
This enables processing of test results by CI/CD systems such as GitLab Runner or Jenkins.
Similar to the tinytest philosophy this packages comes with no-dependencies.

## Core idea:

* Extract needed info from a tinytest S3 result object (output of `tinytest::run_test_dir()`)
* Format the output to JUnit.xml specs as described in this reference: https://llg.cubic.org/docs/junit/

## Install

From the OA public repository:

```r
install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))
```

## Basic Usage

The `writeJUnit()` function excepts any object of class tinytests and converts it to a JUnit XML file that can be interpreted by CI/CD systems.

```r
testresults <- tinytest::run_test_dir("pkgdir")
writeJUnit(testresults, file = "output.xml", overwrite = TRUE)

```

## Example .yml files for CI/CD integration

### Github

```r
on:
  push:
  pull_request:

name: test-report

jobs:
  build-test:  
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      R_KEEP_PKG_SOURCE: yes
    name: Build & Test
    runs-on: ubuntu-latest
    permissions:
      statuses: write
      checks: write
      contents: write
      pull-requests: write
      actions: write
        
    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          working-directory: "./PkgName"          
          extra-packages: local::.          
      - run: |
          install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))
        shell: Rscript {0} 
      - run: |
          tinytest2JUnit::writeJUnit(tinytest::run_test_dir(system.file("tinytest", package ="PkgName")),
           file = file.path(getwd(), "results.xml"))
        shell: Rscript {0}   

      - name: Test Report
        uses: dorny/test-reporter@v1
        if: success() || failure()    # run this step even if previous step failed
        with:
          name: JUnit Tests           # Name of the check run which will be created
          path: results.xml           # Path to test results
          reporter: java-junit        # Format of test results
```

### Jenkins

Extract:

```r

stage('Install') {
   steps {
      sh 'R -q -e \'install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))''
     }
}
stage('Test and coverage') {
   steps {
      dir('PkgName') {
         sh '''R -q -e \'code <- "tinytest2JUnit::writeJUnit(tinytest::run_test_dir(system.file(\\"tinytest\\", package =\\"PkgName\\")), file = file.path(getwd(), \\"results.xml\\"))"
         packageCoverage <- covr::package_coverage(type = "none", code = code)
         cat(readLines(file.path(getwd(), "results.xml")), sep = "\n")
         covr::to_cobertura(packageCoverage)\''''
     }
}
post {
   always {
      dir('PkgName') {
         junit 'results.xml'
         cobertura autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'cobertura.xml', conditionalCoverageTargets: '70, 0, 0', failUnhealthy: false, failUnstable: false, lineCoverageTargets: '80, 0, 0', maxNumberOfBuilds: 0, methodCoverageTargets: '80, 0, 0', onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false
							}
			}
	}
}
```

## Related

* tinytest package: https://github.com/markvanderloo/tinytest
* JUnit reporter in `testthat`: https://testthat.r-lib.org/reference/JunitReporter.html
* test reporter for Github Action: https://github.com/dorny/test-reporter

**(c) Copyright Open Analytics NV, 2012-2023 - Apache License 2.0**
