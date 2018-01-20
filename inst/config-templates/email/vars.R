# for authr to send emails using Amazon SES

# arguments to aws.ses::send_email ----
# NOTE: 'html' or 'message' and 'to' get added

reset_ses <- list(
  from         = '',
  subject      = 'Reset your Password'
)


# variables for reset template ----
reset_vars <- list(

  # required
  template  = '/path/to/email/reset.txt',
  reset_url = 'http://<URL_TO_PASSWORD_RESET_PAGE>?token=',

  # additional values to substitute in template
  product   = 'authr'
)




