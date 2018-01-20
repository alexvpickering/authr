library(authr)
context("add and login user")

Sys.setenv(USERS_DB = 'test', JWT_SECRET = 'secret')

test_that("add_user won't add the same user twice", {

  # setup
  email <- 'test1@gmail.com'
  password <- '12345'
  db <- 'test'
  secret <- 'secret'

  # try adding user twice
  add_user(email, password)
  expect_error(add_user(email, password))
})

test_that("login_user returns correct JWT with invalid credentials", {

  # setup
  email <- 'test2@gmail.com'
  password <- '12345'
  db <- 'test'
  secret <- 'secret'

  # add user then login
  jwt1 <- add_user(email, password)
  jwt2 <- login_user(email, password)

  jwt1 <- jose::jwt_decode_hmac(jwt1, secret)
  jwt2 <- jose::jwt_decode_hmac(jwt2, secret)

  # check claims
  expect_equal(jwt1$email, jwt2$email, email)
  expect_equal(jwt1$hashid, jwt2$hashid)

  # incorrect credentials
  expect_error(login_user(email, 'FakePassword'))
  expect_error(login_user('wrongemail@gmail.com', password))

})



# clean up
Sys.unsetenv(c('USERS_DB', 'JWT_SECRET'))
con <- mongolite::mongo(collection = 'users', db = 'test')
try(con$drop(), silent = TRUE)
