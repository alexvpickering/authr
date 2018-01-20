#' Send Email Using Amazon SES
#'
#' Requires path to email variables R script and corresponding
#' EMAIL_VARS environment variable (see README).
#'
#' @param email Email address.
#' @param type Type of email to send. Either \code{welcome} or \code{forgot_pw}.
#' @param token Token needed for \code{pw_forgot} email.
#'
#' @return
#' @export
#'
#' @examples
send_email <- function(email, type, token=NULL) {

  # for tests
  if (!as.logical(Sys.getenv('SEND_EMAIL'))) return()

  # get needed variables
  source(get_env('EMAIL_VARS'), local = TRUE)

  ses  <- get(paste0(type, '_ses'))
  vars <- get(paste0(type, '_vars'))

  if (type == 'forgot_pw') {
    if (is.null(vars$reset_url)) stop("No 'reset_url' variable (prepends reset token).")

    # append token to reset url
    vars$reset_url <- paste0(vars$reset_url, token)
  }

  # construct body from template
  body <- ifelse(grepl('html$', vars$template), 'html', 'message')
  ses[[body]] <- use_template(vars)

  ses$to <- email
  do.call(aws.ses::send_email, ses)
  return()
}




#' Construct email body from template.
#'
#' Template variables specified with {{ variable_name }}
#'
#' @param vars
#'
#' @return
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
