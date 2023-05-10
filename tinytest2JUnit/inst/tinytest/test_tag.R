

# tag is correctly constructed with an empty content
# Which is the case for an empty test folder!
result_empty = tinytest2JUnit:::tag(
  name = "testsuites",
  attributes = list(name = "tinytest results", tests = 0L, failures = 0L),
  content = list()
)

expect_inherits(result_empty, class = "XMLtag")
expect_equal(typeof(result_empty), target = "list")
expect_equal(result_empty$content, list())

# Format works correctly on an empty result
expect_inherits(format(result_empty), class = "character")
expect_true(length(format(result_empty)) == 1L)
