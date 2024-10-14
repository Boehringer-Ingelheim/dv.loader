#' Load RDS files
#'
#' This function loads RDS files via readRDS() and returns a list of data frames.
#'
#' @param files A character vector of file paths to RDS files.
#' @return A list of data frames, each containing the data from an RDS file.
#' @examples
#' # Create temporary directory and files
#' temp_dir <- tempdir()
#' adsl_rds_file <- file.path(temp_dir, "adsl.rds")
#' adae_rds_file <- file.path(temp_dir, "adae.rds")
#'
#' # Write example data to RDS files
#' saveRDS(pharmaverseadam::adsl, adsl_rds_file)
#' saveRDS(pharmaverseadam::adae, adae_rds_file)
#'
#' # Load RDS files
#' rds_data_list <- load_rds(c(adsl_rds_file, adae_rds_file))
#'
#' # Clean up
#' unlink(c(adsl_rds_file, adae_rds_file))
#' @export
load_rds <- function(files) {
  # Check if files is a character vector
  checkmate::assert_character(files)

  # Read each file and add metadata
  data_list <- lapply(files, function(file) {
    # Check if file exists
    checkmate::assert_file_exists(file)
    # Check if file is an RDS file
    check_file_ext(file, extension = "rds")

    # Read RDS file
    data <- readRDS(file)

    # Get file info and add to data as an attribute
    attr(data, "meta") <- file_info(file)

    return(data)
  })

  # Set names of data_list to the file names
  names(data_list) <- basename(files)

  return(data_list)
}
