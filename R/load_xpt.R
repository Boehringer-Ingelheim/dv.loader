#' Load XPT files
#'
#' This function loads XPT files via haven::read_xpt() and returns a list of data frames.
#'
#' @param files A character vector of file paths to XPT files.
#' @return A list of data frames, each containing the data from an XPT file.
#' @examples
#' # Create temporary directory and files
#' temp_dir <- tempdir()
#' adsl_xpt_file <- file.path(temp_dir, "adsl.xpt")
#' adae_xpt_file <- file.path(temp_dir, "adae.xpt")
#'
#' # Write example data to XPT files
#' haven::write_xpt(pharmaverseadam::adsl, adsl_xpt_file)
#' haven::write_xpt(pharmaverseadam::adae, adae_xpt_file)
#'
#' # Load XPT files
#' xpt_data_list <- load_xpt(c(adsl_xpt_file, adae_xpt_file))
#'
#' # Clean up
#' unlink(c(adsl_xpt_file, adae_xpt_file))
#' @export
load_xpt <- function(files) {
  # Check if files is a character vector
  checkmate::assert_character(files)

  # Read each file and add metadata
  data_list <- lapply(files, function(file) {
    # Check if file exists
    checkmate::assert_file_exists(file)
    # Check if file is an XPT file
    check_file_ext(file, extension = "xpt")

    # Read XPT file
    data <- haven::read_xpt(file)

    # Get file info and add to data as an attribute
    attr(data, "meta") <- file_info(file)

    return(data)
  })

  # Set names of data_list to the file names
  names(data_list) <- basename(files)

  return(data_list)
}
