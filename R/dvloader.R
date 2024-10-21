#' Get Base Directory Path
#'
#' This function retrieves the base directory path from a specified environment variable.
#' It checks if the environment variable is set and if the directory exists.
#'
#' @param env_var [character(1)] The name of the environment variable containing the base directory path.
#'
#' @return [character(1)] The normalized path to the base directory.
#'
#' @examples
#' # Create a temporary directory
#' temp_dir <- tempdir()
#' 
#' # Set the BASE_DIR environment variable
#' Sys.setenv(BASE_DIR = temp_dir)
#' 
#' # Get the base directory path
#' get_base_dir("BASE_DIR")
#' 
get_base_dir <- function(env_var) {
  # Ensure env_var is a single character string
  checkmate::assert_character(env_var, len = 1)

  # Get the value of the environment variable
  base_dir <- Sys.getenv(env_var)

  # Stop if the environment variable is not set
  if (base_dir == "") {
    stop("Environment variable ", env_var, " is not set")
  }

  # Ensure the directory exists
  checkmate::assert_directory_exists(base_dir)

  # Return the normalized path
  return(normalizePath(base_dir))
}


#' Get CRE Path
#'
#' This function retrieves the path to the CRE (Clinical Research Environment) directory.
#' It uses the "RXD_DATA" environment variable as the base directory.
#'
#' @return [character(1)] The path to the CRE directory.
#'
#' @export
get_cre_path <- function() {
    get_base_dir(env_var = "RXD_DATA")
}


#' Load Data Files
#'
#' This function loads data files from a specified directory or the current working directory.
#' It supports loading both RDS and SAS7BDAT files.
#'
#' @param sub_dir [character(1)] Optional character string specifying a subdirectory. Default is NULL.
#' @param file_names [character(1+)] Character vector of file names to load (without extension).
#' @param use_wd [logical(1)] Logical indicating whether to use the current working directory. Default is FALSE.
#' @param prefer_sas [logical(1)] Logical indicating whether to prefer SAS7BDAT files over RDS. Default is FALSE.
#' @param env_var [character(1)] The environment variable name for the base directory. Default is "RXD_DATA".
#' @param print_file_paths [logical(1)] Logical indicating whether to print the directory path and file names. Default is FALSE.
#'
#' @return A named list of data frames, where each name corresponds to a loaded file.
#'
#' @examples
#' # Get the current value of the RXD_DATA environment variable
#' base_dir <- Sys.getenv("RXD_DATA")
#' 
#' # Set the RXD_DATA environment variable to the path of the haven package
#' Sys.setenv(RXD_DATA = find.package("haven"))
#' 
#' data_list <- load_data(sub_dir = "examples", file_names = c("iris.sas7bdat"))
#' str(data_list)
#' 
#' # Reset the RXD_DATA environment variable to its original value
#' Sys.setenv(RXD_DATA = base_dir)
#' 
#' @export
load_data <- function(sub_dir = NULL, file_names, use_wd = FALSE, prefer_sas = FALSE, env_var = "RXD_DATA", print_file_paths = FALSE) {
  # Input validation
  checkmate::assert_character(sub_dir, len = 1, null.ok = TRUE)
  checkmate::assert_character(file_names, min.len = 1)
  checkmate::assert_logical(use_wd, len = 1)
  checkmate::assert_logical(prefer_sas, len = 1)
  checkmate::assert_character(env_var, len = 1)

  # Determine the base directory
  if (use_wd) {
    base_dir <- getwd()
  } else {
    base_dir <- get_base_dir(env_var = env_var)
  }
  
  # Construct the full directory path
  dir_path <- if (is.null(sub_dir)) base_dir else file.path(base_dir, sub_dir)

  # Determine the file extension based on preference
  file_ext <- if (prefer_sas) "sas7bdat" else "rds"

  # Get the full file paths
  file_paths <- get_file_paths(dir_path = dir_path, file_names = file_names, prefer_sas = prefer_sas)

  # Print the directory path and file names if requested
  if (isTRUE(print_file_paths)) { 
    cat("Loading data from", dir_path, "\n")
    cat("Loading data file(s):", basename(file_paths), "\n")
  }

  # Load the data files
  data_list <- load_data_files(file_paths)

  names(data_list) <- file_names

  return(data_list)
}
