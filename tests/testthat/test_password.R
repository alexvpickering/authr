library(authr)
context("forgot/reset password")

Sys.setenv(USERS_DB = 'test', JWT_SECRET = 'secret', EMAIL_VARS = '/var/www/R/email/vars.R', SEND_EMAIL = 'FALSE')

# clean up test database
con <- mongolite::mongo(collection = 'users', db = 'test')
try(con$drop(), silent = TRUE)


check_vars <- function() {
  vars_path <- Sys.getenv('EMAIL_VARS')
  if (!file.exists(vars_path))
    skip('EMAIL_VARS')
}

test_that('forgot_password returns silently regardless if user is in database', {

  check_vars()

  result <- forgot_password('fake_email@gmail.com')
  expect_null(result)

  add_user('blah@gmail.com', '12345')
  result <- forgot_password('blah@gmail.com')
  expect_null(result)
})

# clean up
Sys.unsetenv(c('USERS_DB', 'JWT_SECRET', 'EMAIL_VARS', 'SEND_EMAIL'))
con <- mongolite::mongo(collection = 'users', db = 'test')
try(con$drop(), silent = TRUE)
