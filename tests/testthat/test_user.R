library(authr)
context("add and login user")

Sys.setenv(USERS_DB = 'test', JWT_SECRET = 'secret', EMAIL_VARS = '/var/www/R/email/vars.R', SEND_EMAIL = 'FALSE')

# clean up test database
con <- mongolite::mongo(collection = 'users', db = 'test')
try(con$drop(), silent = TRUE)

test_that("add_user won't add the same user twice", {

  # setup
  email <- 'blah@gmail.com'
  password <- '12345'

  # try adding user twice
  add_user(email, password)
  expect_error(add_user(email, password))
})

test_that("login_user returns correct JWT with invalid credentials", {

  # setup
  email <- 'blah@gmail.com'
  password <- '12345'

  # login
  jwt <- login_user(email, password)
  jwt <- jose::jwt_decode_hmac(jwt, Sys.getenv('JWT_SECRET'))

  # check claims
  expect_equal(jwt$email, email)

  # incorrect credentials
  expect_error(login_user(email, 'FakePassword'))
  expect_error(login_user('wrongemail@gmail.com', password))

})



# clean up
Sys.unsetenv(c('USERS_DB', 'JWT_SECRET', 'EMAIL_VARS', 'SEND_EMAIL'))
con <- mongolite::mongo(collection = 'users', db = 'test')
try(con$drop(), silent = TRUE)
