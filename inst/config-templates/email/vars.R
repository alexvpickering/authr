# for authr to send emails using Amazon SES

# Forgot Password Email ----

# arguments to aws.ses::send_email
# NOTE: 'html' or 'message' and 'to' get added
forgot_pw_ses <- list(
  from         = '',
  subject      = 'Reset your Password'
)


# variables for forgot password template
forgot_pw_vars <- list(

  # required
  template  = '/path/to/email/forgot_pw.txt',
  reset_url = 'http://<URL_TO_PASSWORD_RESET_PAGE>?token=',

  # additional values to substitute in template
  product_name   = 'RWidget',
  company_name   = 'R Widgets'
)

# Welcome Email ----

welcome_ses <- list(
  from         = '',
  subject      = ''
)


welcome_vars <- list(

  # required
  template  = '/path/to/email/welcome.txt',

  # additional values to substitute in template
  product_name     = '',
  company_name     = '',
  sender_name      = '',

  support_email    = '',
  action_url       = '',
  live_chat_url    = '',
  help_url         = '',

  trial_length     = 30,
  trial_start_date = as.character(Sys.Date()),
  trial_end_date   = as.character(Sys.Date() + 30)

)

