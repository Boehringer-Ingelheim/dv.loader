#' gets the NFS base path from an env var
#' It assumes there is an env var
#' called RXD_DATA which holds the path suffix.
#' @return the NFS base path
#' @export
get_nfs_path <- function() {
  base_path <- Sys.getenv("RXD_DATA")
  # check that RXD_DATA is set
  if (base_path == "") {
    stop("Usage: get_nfs_path: RXD_DATA must be set")
  }
  return(base_path)
}

#' gets the NFS base path from an env var
#' alias for get_nfs_path to maintain backwards compatibility
#' @export
get_cre_path <- get_nfs_path

#' Loads data into memory based on study directory and one or more file_names.
#' @param sub_dir A relative directory/folder that will be appended to a base path defined by `Sys.getenv("RXD_DATA")`.
#' If the argument is left as NULL, the function will load data from the working directory `getwd()`.
#' @param file_names Study file or file_names name(s) - can be a vector of strings.
#' This is the only required argument.
#' @param use_wd for "use working directory" - a flag used when importing local files
#' not on NFS - default value is FALSE
#' @param prefer_sas if set to TRUE, imports sas7bdat files first before looking for
#' RDS files (the opposite of default behavior)
#' @return a list of dataframes
#' @export
#' @examples
#' \dontrun{
#' test_data_path <- "../inst/extdata/"
#' data_list <- load_data(
#'   sub_dir = test_data_path,
#'   file_names = "dummyads2",
#'   use_wd = TRUE
#' )
#' }
load_data <- function(sub_dir = NULL, file_names, use_wd = FALSE, prefer_sas = FALSE) {
  if (is.null(file_names)) {
    stop("Usage: load_data: file_names: Must supply at least one file name")
  }

  study_path <- "" # will be built using args

  if (is.null(sub_dir)) {
    study_path <- getwd()
  } else {
    if (use_wd) {
      study_path <- file.path(getwd(), sub_dir)
    } else {
      study_path <- file.path(get_cre_path(), sub_dir)
    }
  }

  # create the output
  data_list <- create_data_list(study_path, file_names, prefer_sas) # nolint

  return(data_list)
}
