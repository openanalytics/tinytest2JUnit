

escaped <- tinytest2JUnit:::escapeXmlText(c("Hello <- world & !", "Leave > me ' \" alone"))
expect_equal(escaped, c( "Hello &lt- world &amp !", "Leave > me ' \" alone"))
