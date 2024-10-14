#' Load SAS files
#'
#' This function loads SAS files via haven::read_sas() and returns a list of data frames.
#'
#' @param files A character vector of file paths to SAS files.
#' @return A list of data frames, each containing the data from a SAS file.
#' @examples
#' # Create temporary directory and files
#' temp_dir <- tempdir()
#' adsl_sas_file <- file.path(temp_dir, "adsl.sas7bdat")
#' adae_sas_file <- file.path(temp_dir, "adae.sas7bdat")
#'
#' # Write example data to SAS files
#' haven::write_sas(pharmaverseadam::adsl, adsl_sas_file)
#' haven::write_sas(pharmaverseadam::adae, adae_sas_file)
#'
#' # Load SAS files
#' sas_data_list <- load_sas(c(adsl_sas_file, adae_sas_file))
#'
#' # Clean up
#' unlink(c(adsl_sas_file, adae_sas_file))
#' @export
load_sas <- function(files) {
  # Check if files is a character vector
  checkmate::assert_character(files)

  # Read each file and add metadata
  data_list <- lapply(files, function(file) {
    # Check if file exists
    checkmate::assert_file_exists(file)
    # Check if file is a SAS file
    check_file_ext(file, extension = "sas7bdat")

    # Read SAS file
    data <- haven::read_sas(file)

    # Get file info and add to data as an attribute
    attr(data, "meta") <- file_info(file)

    return(data)
  })

  # Set names of data_list to the file names
  names(data_list) <- basename(files)
  return(data_list)
}
