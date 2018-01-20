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
  con <- mongolite::mongo('users', get_env('USERS_DB'))
  is_user <- con$count(sprintf('{"email": "%s"}', email))

  # dont give away if user exists
  if (!is_user) return()

  # generate unique reset token
  while (!exists('hash_token') ||
         con$count(sprintf('{"reset": "%s"}', hash_token)) != 0) {

    token <- stringi::stri_rand_strings(1, 20)
    hash_token <- hash_string(token)
  }

  # store hashed token
  con$update(
    sprintf('{"email": "%s"}', email),
    sprintf('{"$set": {"reset": "%s", "reset_expire": %s}}',
            hash_token, unclass(Sys.time()) + 86400)
  )

  # send forgot password email
  send_email(email, type='forgot_pw')
  return()
}

hash_string <- function(string) {
  sodium::bin2hex(sodium::hash(charToRaw(string)))
}

