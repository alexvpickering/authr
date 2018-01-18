#' Login user
#'
#' @inheritParams add_user
#'
#' @return JSON web token.
#' @export
#'
#' @examples
login_user <- function(email, password, db, secret) {

  # check if user exists
  con   <- mongolite::mongo('users', db)
  saved <- con$find(
    sprintf('{"email" : "%s"}', email)
  )

  if (!nrow(saved)) stop("Invalid email/password.")

  # check if password is correct
  valid <- sodium::password_verify(saved$password, password)

  if (!valid) stop("Invalid email/password.")

  jwt <- create_jwt(secret, email = email, hashid = saved$hashid)
  return(jwt)
}
