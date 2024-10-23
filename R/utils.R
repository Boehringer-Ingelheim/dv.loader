#' Get File Paths
#'
#' This function constructs file paths for given file names, handling both RDS and SAS7BDAT files.
#' It can prioritize SAS files over RDS files based on the `prefer_sas` parameter.
#'
#' @param dir_path [character(1)] The directory path where the files are located.
#' @param file_names [character(1+)] A vector of file names to process.
#' @param prefer_sas [logical(1)] Whether to prefer SAS files over RDS files. Default is FALSE.
#'
#' @return [character] A vector of normalized file paths.
#'
#' @examples
#' \dontrun{
#' temp_dir <- tempdir()
#'
#' file_names <- c("adsl", "adae")
#'
#' file.create(file.path(temp_dir, paste0(file_names, ".rds")))
#' file.create(file.path(temp_dir, paste0(file_names, ".sas7bdat")))
#'
#' list.files(temp_dir)
#'
#' get_file_paths(dir_path = temp_dir, file_names = file_names)
#' get_file_paths(dir_path = temp_dir, file_names = file_names, prefer_sas = TRUE)
#'
#' unlink(temp_dir, recursive = TRUE)
#' }
#'
#' @export
get_file_paths <- function(dir_path, file_names, prefer_sas = FALSE) {
  # Input validation
  checkmate::assert_character(dir_path, len = 1)
  checkmate::assert_character(file_names, min.len = 1)
  checkmate::assert_logical(prefer_sas, len = 1)

  file_paths <- lapply(file_names, function(file_name) {
    file_path <- file.path(dir_path, file_name)
    file_ext <- tools::file_ext(file_name)

    if (file_ext == "") {
      # Get all files in the directory
      candidates <- basename(list.files(dir_path))

      # Find matching RDS files
      rds_match <- grep(
        pattern = paste0("^", file_name, "\\.rds$"), 
        x = candidates,
        ignore.case = TRUE,
        value = TRUE
      )

      # Find matching SAS files
      sas_match <- grep(
        pattern = paste0("^", file_name, "\\.sas7bdat$"), 
        x = candidates, 
        ignore.case = TRUE,
        value = TRUE
      )

      # Prefer SAS file if it exists, otherwise use RDS
      if (isTRUE(prefer_sas)) {
        if (length(sas_match) > 0) {
          return(file.path(dir_path, sas_match[1]))
        } else if (length(rds_match) > 0) {
          return(file.path(dir_path, rds_match[1]))
        } else {
          stop(dir_path, " does not contain SAS or RDS file: ", file_name)
        }
      } else if (isFALSE(prefer_sas)) {
        if (length(rds_match) > 0) {
          return(file.path(dir_path, rds_match[1]))
        } else if (length(sas_match) > 0) {
          return(file.path(dir_path, sas_match[1]))
        } else {
          stop(dir_path, " does not contain RDS or SAS file: ", file_name)
        }
      }
    } else {
      # If an extension is provided, use the exact file name
      if (file.exists(file_path)) {
        return(file_path)
      } else {
        stop(dir_path, " does not contain: ", file_name)
      }
    }
  })

  # Normalize all file paths
  return(normalizePath(unlist(file_paths)))
}



#' Load Data Files
#'
#' This function reads data from multiple file paths and returns a list of data frames.
#' It supports reading RDS and SAS7BDAT files.
#'
#' @param file_paths [character(1+)] A vector of file paths to read.
#'
#' @return [list] A named list of data frames, where each name is the basename of the corresponding file path.
#'
#' @examples
#' path <- system.file("examples", "iris.sas7bdat", package = "haven")
#' data_list <- load_data_files(file_paths = path)
#' str(data_list)
#'
#' @export
load_data_files <- function(file_paths) {
  # Validate input parameters
  checkmate::assert_character(file_paths, min.len = 1)
  checkmate::assert_file_exists(file_paths)

  # Read each file and store in a list
  data_list <- lapply(file_paths, function(file_path) {
    # Get file extension
    extension <- tools::file_ext(file_path)

    # Read file based on its extension
    if (tolower(extension) == "rds") {
      data <- readRDS(file_path)
    } else if (tolower(extension) == "sas7bdat") {
      data <- haven::read_sas(file_path)
    } else {
      stop("Unsupported file extension: ", extension)
    }

    # Get file metadata
    meta <- file.info(file_path, extra_cols = FALSE)
    meta[["path"]] <- file_path
    meta[["file_name"]] <- basename(file_path)

    # Add metadata as an attribute to the data
    rownames(data) <- NULL
    attr(data, "meta") <- meta

    return(data)
  })

  # Set names of the list elements to the basenames of the file paths
  names(data_list) <- basename(file_paths)

  return(data_list)
}
