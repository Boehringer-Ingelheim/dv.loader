#' @noRd
#' @useDynLib dv.loader, .registration = TRUE
#' @keywords internal
character_to_factor <- function(v) {
  stopifnot(is.character(v))
  return(.Call(C_character_to_factor, v))
}