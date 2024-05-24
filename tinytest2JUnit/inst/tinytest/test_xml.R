
tag <- tinytest2JUnit:::tag

# tag is correctly constructed with an empty content
# Which is the case for an empty test folder!
resultEmpty <- tag(
  name = "testsuites",
  attributes = list(name = "tinytest results", tests = 0L, failures = 0L),
  content = list()
)

expect_inherits(resultEmpty, class = "XMLtag")
expect_equal(typeof(resultEmpty), target = "list")
expect_equal(resultEmpty$content, list())

# Format works correctly on an empty result
expect_inherits(format(resultEmpty), class = "character")
expect_true(length(format(resultEmpty)) == 1L)

expect_error(tag("t", content = list(0L)), info = "Only child-tags/char is in allowed content")
expect_error(
  tag("t", content = list(tag("t"), 0L)), 
  info = "Only child-tags/char is in allowed content"
)
expect_error(
  tag("t", content = list(tag("t"), "text")),
  info = "Mixed tag content is currently not supported"
)
expect_error(
  tag("t", content = list("text", "text")),
  info = "Only a single character string is allowed."
)

# No errors are expected below:
tag("t", content = list("text"))
tag("t", content = list(tag("t")))
tag("t", content = list(tag("t"), tag('t2')))


expect_equal(
  format(tag("t", attributes = list(a = "1", b = "2"))),
  "<t a='1' b='2'></t>",
  info = "Empty content tags are closed on the same line."
)

expect_equal(
  format(tag("t", attributes = list(a = "1", b = "2"), content = list("Hello\nWorld"))),
  "<t a='1' b='2'>Hello\nWorld</t>",
  info = "White space is respected for text content"
)

formatTagWithChild <- format(
  tag("t", attributes = list(a = "1", b = "2"), content = list(tag("a"), tag("b")))
)
expectedFormattedTag <- "<t a='1' b='2'>\n  <a></a>\n  <b></b>\n</t>"
expect_equal(
  formatTagWithChild,
  expectedFormattedTag,
  info = "Child tags are indented and on a newline."
)

escaped <- tinytest2JUnit:::escapeXmlText(c("Hello <- world & !", "Leave > me ' \" alone"))
expect_equal(escaped, c("Hello &lt- world &amp !", "Leave > me ' \" alone"))


escaped <- tinytest2JUnit:::escapeXml(c("<a b='t' c=\"d\">&</a>", "&"))
expect_equal(escaped, c("&lta b=&apost&apos c=&quotd&quot&gt&amp&lt/a&gt", "&amp"))
