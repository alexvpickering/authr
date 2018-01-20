reset_password <- function(password, token) {

  # confirm that user with non-expired token is in db
  con <- mongolite::mongo('users', get_env('USERS_DB'))
  hash_token <- hash_string(token)

  user <- con$find(sprintf('{"reset": "%s"}', hash_token))

  if (!nrow(user)) stop('Reset token does not exist.')
  if (Sys.time() > user$reset_expire) stop('Reset token is expired.')

  # store new password and remove reset hash and expire
  con$update(
    sprintf('{"email": "%s"}', user$email),
    sprintf('{"$set": {"password": "%s"},
            "$unset": {"reset": "", "reset_expire": ""}}',
            sodium::password_store(password)
  ))
  return()
}
