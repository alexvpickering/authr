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
  con <- mongolite::mongo('users', Sys.getenv('USERS_DB'))
  is_user <- con$count(sprintf('{"email": "%s"}', email))

  if (is_user)
    stop('User with email ', email, ' already exists.')

  hashid <- get_hashid(con$count()+1)

  # insert user
  con$insert(sprintf(
      '{"email": "%s", "hashid": "%s", "password": "%s"}',
      email, hashid, sodium::password_store(password)
    ))

  # return JSON web token
  jwt <- create_jwt(email = email, hashid = hashid)
  return(jwt)
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
  jose::jwt_encode_hmac(claim, Sys.getenv('JWT_SECRET'))
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
