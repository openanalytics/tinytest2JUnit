# Tinytest2JUnit

Convert tinytest test's results ouptut to JUnit xml to allow it to be used by CI/CD pipelines, e.g. GitLab Runner or Jenkins.

## Install

From the OA public repository:

```r
install.packages("tinytest2JUnit", repos = c(OA = "https://repos.openanalytics.eu/repo/public/", CRAN = "https://cloud.r-project.org"))
```

## Core ideas:

* Extract needed info from a tinytest S3 result object (output of `tinytest::run_test_dir()`)
* Format the output to JUnit.xml specs as described in this reference: https://llg.cubic.org/docs/junit/

**(c) Copyright Open Analytics NV, 2012-2023 - Apache License 2.0**
