
# tinytest2JUnit

<!-- badges: start -->
[![R-CMD-check](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml/badge.svg)](https://github.com/openanalytics/tinytest2JUnit/actions/workflows/check-standard.yml)
[![codecov](https://codecov.io/gh/openanalytics/tinytest2JUnit/branch/master/graph/badge.svg)](https://app.codecov.io/gh/openanalytics/tinytest2JUnit)
<!-- badges: end -->

## Overview

A package to convert [tinytest](https://github.com/markvanderloo/tinytest) results to JUnit XML.
This enables processing of test results by CI/CD systems such as GitLab Runner or Jenkins.
Similar to the tinytest philosophy this packages comes with no-dependencies.

## Core idea

* Extract needed info from a tinytest S3 result object (output of `tinytest::run_test_dir()`)
* Convert the output to JUnit XML format as described in this reference: https://llg.cubic.org/docs/junit/

## Install

From the OA public repository:

```r
install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))
```

## Basic Usage

The `writeJUnit()` function accepts any object of class tinytests and converts it to a JUnit XML file that can be interpreted by CI/CD systems.

```r
testresults <- tinytest::run_test_dir("pkgdir")
writeJUnit(testresults, file = "output.xml", overwrite = TRUE)
```

## Example files for CI/CD integration

### Github Actions

`PkgName` needs to be replaced with the name of your package

```yaml
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
          library(PkgName);tinytest2JUnit::writeJUnit(tinytest::run_test_dir(system.file("tinytest", package ="PkgName")),
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

Download this file [here](./.github/workflows/test-report.yml).

### Gitlab CI/CD

`PkgName` needs to be replaced with the name of your package

```yaml

image: r-base:latest 

test:  
  script:
    - apt-get update && apt-get install --no-install-recommends -y libxml2-dev # xml2 library needed for roxygen2
    - echo "options(crayon.enabled=TRUE)" > .Rprofile   # force crayon  mode
    - echo "Installing dependencies"
    - R -e 'install.packages(c("roxygen2", "tinytest", "tinytest2JUnit"), repos = c(OA = "https://repos.openanalytics.eu/repo/public/","https://cloud.r-project.org"))'
    - R -e 'roxygen2::roxygenize("PkgName")'
    - R CMD build PkgName
    - R CMD check PkgName_*.tar.gz --no-manual --no-build-vignettes
    - R -e 'install.packages("PkgName", repos = NULL)'
    - R -e 'library(PkgName);tinytest2JUnit::writeJUnit(tinytest::run_test_dir(system.file("tinytest", package ="PkgName")), file = file.path(getwd(), "results.xml"))'
  artifacts:
    when: always
    paths:
      - results.xml
    reports:
      junit: results.xml

```

Download this file [here](./.gitlab-ci.yml).

### Jenkins

Extract from a full Jenkinsfile (replace `PkgName` with the name of your package):

```
stages {
   stage('PkgName') {
      stages {
         stage('Roxygen') {
            steps {
               sh 'R -q -e \'roxygen2::roxygenize("PkgName")\''
                            }
                        }
         stage('Build') {
            steps {
               sh 'R CMD build PkgName'
                            }
                        }
         stage('Check') {
            steps {
               script() {
                  switch(sh(script: 'ls PkgName_*.tar.gz && R CMD check PkgName_*.tar.gz --no-manual', returnStatus: true)) {
                     case 0: currentBuild.result = 'SUCCESS'
                     default: currentBuild.result = 'FAILURE'; error('script exited with failure status')
                             }
                          }
                       }
                    }
         stage('Install') {
            steps {
               sh 'R -q -e \'install.packages(list.files("PkgName", "tinytest2JUnit"), repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))\''
              }
         }
         stage('Test and coverage') {
            steps {
               dir('PkgName') {
                  sh '''R -q -e \'code <- "library(PkgName);tinytest2JUnit::writeJUnit(tinytest::run_test_dir(system.file(\\"tinytest\\", package =\\"PkgName\\")), file = file.path(getwd(), \\"results.xml\\"))"
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

Download the full Jenkinsfile [here](./Jenkinsfile).

## Related

* tinytest package: https://github.com/markvanderloo/tinytest
* JUnit reporter in `testthat`: https://testthat.r-lib.org/reference/JunitReporter.html
* test reporter for Github Action: https://github.com/dorny/test-reporter

**(c) Copyright Open Analytics NV, 2022-2023 - Apache License 2.0**
