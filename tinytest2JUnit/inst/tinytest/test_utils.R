isSingleLengthCharNonNA <- tinytest2JUnit:::isSingleLengthCharNonNA
charVecToSingleLength <- tinytest2JUnit:::charVecToSingleLength

expect_true(
  isSingleLengthCharNonNA("!"),
  info = "isSingleLengthIntNonNA works with valid characters"
)
expect_true(
  isSingleLengthCharNonNA(""),
  info = "isSingleLengthIntNonNA works ''"
)

expect_false(
  isSingleLengthCharNonNA(NA),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)
expect_false(
  isSingleLengthCharNonNA(NA_character_),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)
expect_false(
  isSingleLengthCharNonNA(NaN),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)


expect_false(
  isSingleLengthCharNonNA(c("A", "B")),
  info = "isSingleLengthIntNonNA is false for length != 1"
)
expect_false(
  isSingleLengthCharNonNA(c(NA_character_, NA_character_)),
  info = "isSingleLengthIntNonNA is false for length != 1"
)
expect_false(
  isSingleLengthCharNonNA(character(0L)),
  info = "isSingleLengthIntNonNA is false for length != 1"
)


expect_equal(
  charVecToSingleLength("Hello\nWorld"),
  "Hello\nWorld",
  info = "Leaves normal length-1 alone"
)

expect_equal(
  charVecToSingleLength(c("Hello", "World")),
  "HelloWorld",
  info = "charVecToSingleLength concates them with empty space"
)

expect_equal(
  charVecToSingleLength(c("Hello", NA_character_, "World")),
  "HelloNAWorld",
  info = "NA is converted is converted to a literal NA"
)

expect_equal(
  charVecToSingleLength(character(0L)),
  "",
  info = "Zero-length is converted to empty string."
)
