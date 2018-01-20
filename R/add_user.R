#' Add user to MongoDB database
#'
#' Adds email, unique hashid (useful for example a user folder),
#' and hashed password to specified MongoDB database in 'users'
#' collection. JSON web token with email and hashid claim is
#' returned for subsequent API authorzation.
#'
#'
#' @param email Email address of user.
#' @param password Password of user.
#'
#' @return JSON web token.
#' @export
#'
#' @examples
add_user <- function(email, password) {

  # check if user exists
  con <- mongolite::mongo('users', get_env('USERS_DB'))
  is_user <- con$count(sprintf('{"email": "%s"}', email))

  if (is_user)
    stop('User with email ', email, ' already exists.')

  hashid <- get_hashid(con$count()+1)

  # insert user
  con$insert(sprintf(
      '{"email": "%s", "hashid": "%s", "password": "%s"}',
      email, hashid, sodium::password_store(password)
    ))

  # send welcome email
  send_email(email, type='welcome')

  # return JSON web token
  jwt <- create_jwt(email = email, hashid = hashid)
  return(jwt)
}

send_welcome <- function(email) {

  # get needed variables
  source(get_env('EMAIL_VARS'), local = TRUE)

  # construct body from template
  welcome_ses$message <- use_template(welcome_vars)
  welcome_ses$to <- email

  do.call(aws.ses::send_email, welcome_ses)
  return()
}




#' Create JSON web token
#'
#' @param claim Named list of claims.
#' @param ... Claims to include.
#'
#' @seealso \link[jose]{jwt_claim}
#'
#' @return JSON web token string.
#'
#' @examples
create_jwt <- function(...) {
  claim <- jose::jwt_claim(...)
  jose::jwt_encode_hmac(claim, get_env('JWT_SECRET'))
}

#' Generates unique hash identifier
#'
#'
#' @param int Integer or integer vector to encode.
#' @param salt An additional string to make hashids more unique.
#' @param min_length Minimum length for hashid.
#'
#' @return hashid string.
#'
#' @examples
get_hashid <- function(int, salt='salt', min_length=5) {
  h <- hashids::hashid_settings(salt, min_length)
  hashids::encode(int, h)
}

#' Get environment variable.
#'
#' Throws error is environment variable is not defined.
#'
#' @param var_name Environment variable to get.
#'
#' @return Value of environment variable.
#'
#' @examples
get_env <- function(var_name) {
  var <- Sys.getenv(var_name)
  if (var == '') stop(var_name, ' environment variable is not set.')
  return(var)
}

#' Open template files needed for authr.
#'
#' @return
#' @export
#'
#' @examples
open_templates <- function() {
  templates <- c('.Renviron', 'email/reset.txt', 'email/vars.R')
  file.edit(file.path(system.file(package='authr'), 'config-templates', templates))
}
