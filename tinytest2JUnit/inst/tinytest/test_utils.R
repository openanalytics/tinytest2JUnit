
expect_true(
  tinytest2JUnit:::isSingleLengthCharNonNA("!"),
  info = "isSingleLengthIntNonNA works with valid characters"
)
expect_true(
  tinytest2JUnit:::isSingleLengthCharNonNA(""),
  info = "isSingleLengthIntNonNA works ''"
)

expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(NA),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)
expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(NA_character_),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)
expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(NaN),
  info = "isSingleLengthIntNonNA correctly falsifies with NA"
)


expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(c("A", "B")),
  info = "isSingleLengthIntNonNA is false for length != 1"
)
expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(c(NA_character_, NA_character_)),
  info = "isSingleLengthIntNonNA is false for length != 1"
)
expect_false(
  tinytest2JUnit:::isSingleLengthCharNonNA(character(0L)),
  info = "isSingleLengthIntNonNA is false for length != 1"
)
