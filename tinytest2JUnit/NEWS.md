## 1.1.0 

### New Features:

* New function `testPackage`. This is a convenience that has the same interface as tinytest::test_package() 
  but automatically convert the test results to JUnit. 
  It also has the following advantages compared to just calling `tinytest::run_test_dir() |> writeJUnit()`:
    * Catches error thrown in test_files and reports them with stacktrace in the JUnit as error.
    * Records duration time per file (testsuite) and other metrics (see ?testPackage)
    * Optionally do not crash if an error occured. Usefull if you want to first do some other things in your CI.
* New function `runTestDir`. This is a drop-in replacement for `tinytest::run_test_dir()`. It is the work horse of 
  for the `testPackage` function. It has the following features:
    * Catches error thrown in test_files and reports them as a `tinytest` object in the result.
    * Return new subclass object `tinytests2JUnit` containing additional metrics recorded during the test execution for use in the JUnit.

For most users `testPackage` will be the convenience one-liner funciton to add in your CI. While with 
the `runTestDir` you have full controll over which directories you want to call. This can be usefull 
if you have multiple test stages written in tinytest.

* argument `file` of `writeJUnit` now also accepts `connection` object and now has a default argument `stdout()`.
     * This for ease of interacive debugging to see what writeJUnit produces.

### Adjustments to the JUnit report:

When using `testPackage` or the output of `runTestDir` the following additional information is reported in the JUnit:

* Amount of disabled tests. Here it assumed that a test file with no tests was conditionally early exited and thus viewed as a skipped test.
* Per test file (testsuite): the duration time.
* Per test file (testsuite): the hostname of the computer where the test ran. (usefull in cluster context)
* Per test file (testsuite): the timestamp when the test ran. 

Note, it is still possible to use normal `tinytests` results as returned by `tinytest::run_test_dir()` with `writeJUnit()`. 

* testsuite name property is now equal to the test_file (without the .R suffix).
* testsuite now has the `id` property filled in.
* testcase name has been updated to include `info` attribute of a tinytest object. 
* testcase classname is now specified this is equal to the test file name (without the .R suffix)
* failure tag message is now equal to that of the "diff" 
* New error tags are now also reported:
    * Message = mention uncaught error in which file + the error message. 
    * tag content = Full error message + stacktrace. 

### Fixes:

* Correctly report test duration with the "time" attribute. Previously this was wrongly done with "duration" attribute which not a formal spec of the JUnit.
* Correctly xml escape special character in the content (again).
* XML escape ALL attributes that are string. (if your file name had a special character it could have crashed the xml formatting)
* Correctly handle white space in xml tag. That is text content was also attempted to be indended. However this is wrong as each white space character. Including indendentation and newlines is revelant. This has been fixed.


### Misc:

* Previously 'tinytest' was listed as "Suggested" in the DESCRIPTION. It now is listed as Imports. This should have no impact as 'tinytest' was needed anyway to run the tests in the first place.
* Adjusted documentation in the README to be up to date with the new testPackage function + fixed some wrong statements in the Jenkinsfile.

## 1.0.3

* Fix: Escape the characters '<' and '&' in xml-text. 

## 1.0.2

* Docs: added BugReports to description file
* Docs: added NEWS file

## 1.0.1

* Docs: added url of github repo to description file
    
# 1.0.0

* Feature: added functionality to handle tests on side-effects
* Docs: reviewed documentation to fit CRAN's policy
* Fix: load exported functions before running tests in CI
    
## 0.1.3

* Docs: updated LICENSE to stick to CRAN policies

## 0.1.2
 
* Docs: updated package description

## 0.1.1

* Docs: changed maintainer role in DESCRIPTION file
* Docs: added LICENSE file
    
## 0.1.0

* initial version
* basic functionality
* added examples files for CI/CD runners
