# for authr to send emails using Amazon SES
# see http://www.open-meta.org/technology/how-to-send-email-from-r-with-the-help-of-amazon-ses-and-mailr/

# smtp argument to mailR::send.mail
smtp = list(
  host.name = '',
  port      = '',
  user.name = '',
  passwd    = '',
  ssl       = TRUE
)

# other arguments to mailR::send.mail for send_reset ('body' and 'to' get added)
reset_mailr <- list(
  from         = '',
  subject      = '',
  smtp         = smtp,
  authenticate = TRUE,
  send         = TRUE,
  replyTo      = NULL,
  html         = FALSE,
  inline       = FALSE
)

# variables used by send_reset and use_template
reset_vars <- list(

  # required
  template  = '/path/to/email/reset.txt',
  reset_url = 'http://<URL_TO_PASSWORD_RESET_PAGE>?token=',

  # additional values to substitute in template
  product   = 'AuthR'
)


