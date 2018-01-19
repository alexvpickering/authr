#' Forgot password API endpoint.
#'
#' Checks if user exists, generates unique time-limited (24 hour) reset token,
#' and sends reset email. Reset token is hashed then stored in database
#' to prevent password resets if database is compromised.
#'
#' @param email Email address of user that forgot password.
#'
#' @return NULL
#' @export
#'
#' @examples
forgot_password <- function(email) {

  # confirm that users email is in db
  con <- mongolite::mongo('users', Sys.getenv('USERS_DB'))
  is_user <- con$count(sprintf('{"email": "%s"}', email))

  # dont give away if user exists
  if (!is_user) return()

  # generate unique reset token
  while (!exists('hash') ||
         con$count(sprintf('{"reset": "%s"}', hash)) != 0) {

    token <- stringi::stri_rand_strings(1, 20)
    hash  <- rawToChar(sodium::hash(charToRaw(token)))
  }

  # store hashed token
  con$update(
    sprintf('{"email": "%s"}', email),
    sprintf('{"$set": {"reset": "%s", "reset_expire": %s}}',
            hash, unclass(Sys.time()) + 86400)
  )

  # send reset email
  send_reset(email, token)
  return()
}

#' Sends reset password email
#'
#' Called by forgot_password. Requires EMAIL_VARS environment
#' variable (see vignette).
#'
#' @inheritParams forgot_password
#' @param token Reset token
#'
#' @return NULL
#'
#' @examples
send_reset <- function(email, token) {

  # get needed variables
  source(Sys.getenv('EMAIL_VARS'), local = TRUE)

  # checks
  if (is.null(reset_template$url)) stop("No 'url' variable (prepends reset token).")

  # append token to reset url
  reset_vars$url <- paste0(reset_vars$url, token)

  # construct body from template
  reset_mailr$body <- use_template(reset_vars)
  reset_mailr$to <- email

  do.call(mailR::send.mail, reset_mailr)
  return()
}

#' Construct email body from template.
#'
#' Template variables specified with {{ variable_name }}
#'
#' @param vars
#'
#' @return
#' @export
#'
#' @examples
use_template <- function(vars) {

  # checks
  if (is.null(vars$template))
    stop ("No 'template' variable (specifies path to template).")

  # read in template
  template <- paste(readLines(vars$template), collapse="\n")

  # get handlebar and corresponding substitute variables
  hbars <- stringi::stri_extract_all_regex(template, '\\{\\{ .+? \\}\\}')[[1]]
  subs  <- gsub('\\{\\{ (.+?) \\}\\}', '\\1', hbars)

  # check for missing substitutes
  missing <- setdiff(subs, names(vars))

  if (length(missing))
    stop('Email template expects variables that are not defined: ', missing)

  # make substitutions
  body <- stringi::stri_replace_all_fixed(template, hbars, unlist(vars)[subs], vectorize_all=FALSE)
  return(body)
}
