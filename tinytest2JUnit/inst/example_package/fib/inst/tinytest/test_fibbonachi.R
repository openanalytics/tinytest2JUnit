

expect_equal(fibonacci(1), c(1))
expect_equal(fibonacci(2), c(1, 1))
expect_equal(fibonacci(3), c(1, 1, 2), info = "fibbonachi n=3 works")
expect_equal(fibonacci(4), c(1, 1, 2, 4), info = "A failing test!")
