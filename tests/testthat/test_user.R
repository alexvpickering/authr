library(authr)

# setup
email <- 'alexvpickering@gmail.com'
password <- '12345'
db <- 'test'
secret <- 'secret'


test_that("add_user won't add the same user twice", {

  add_user(email, password, db, secret)
  expect_error(add_user(email, password, db, secret))
})






# clean up
con <- mongolite::mongo(collection = 'users', db = 'test')
con$drop()
