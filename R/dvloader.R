#' Get Base Path from an Environment Variable
#'
#' This function assumes that there is an environment variable called `RXD_DATA`
#' which is set to the base path of the data directory.
#'
#' @return [character(1)] The normalized base path.
#'
#' @export
get_nfs_path <- function() {
  base_path <- Sys.getenv("RXD_DATA")

  if (base_path == "") {
    stop("Environment variable RXD_DATA must be set")
  }

  checkmate::assert_directory_exists(base_path)

  return(normalizePath(base_path))
}

#' Get Base Path from an Environment Variable
#'
#' This function is an alias for `get_nfs_path()` to maintain backwards compatibility.
#'
#' @return [character(1)] The normalized base path.
#'
#' @export
get_cre_path <- get_nfs_path


#' Load Data Files
#'
#' This function loads data files from a specified directory or the current working directory.
#' It supports loading both RDS and SAS7BDAT files.
#'
#' @param sub_dir [character(1)] Optional character string specifying a subdirectory. Default is NULL.
#' @param file_names [character(1+)] Character vector of file names to load (without extension).
#' @param use_wd [logical(1)] Logical indicating whether to use the current working directory. Default is FALSE.
#' @param prefer_sas [logical(1)] Logical indicating whether to prefer SAS7BDAT files over RDS. Default is FALSE.
#' @param print_file_paths [logical(1)] Logical indicating whether to print the directory path and file names.
#' Default is FALSE.
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
load_data <- function(
    sub_dir = NULL,
    file_names,
    use_wd = FALSE,
    prefer_sas = FALSE,
    print_file_paths = FALSE) {
  checkmate::assert_character(sub_dir, len = 1, null.ok = TRUE)
  checkmate::assert_character(file_names, min.len = 1)
  checkmate::assert_logical(use_wd, len = 1)
  checkmate::assert_logical(prefer_sas, len = 1)
  checkmate::assert_logical(print_file_paths, len = 1)

  if (use_wd) {
    base_dir <- getwd()
  } else {
    base_dir <- get_nfs_path()
  }

  dir_path <- if (is.null(sub_dir)) base_dir else file.path(base_dir, sub_dir)

  file_paths <- get_file_paths(dir_path = dir_path, file_names = file_names, prefer_sas = prefer_sas)

  if (isTRUE(print_file_paths)) {
    cat("Loading data from", dir_path, "\n")
    cat("Loading data file(s):", basename(file_paths), "\n")
  }

  data_list <- load_data_files(file_paths)

  return(data_list)
}
