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

#' Load data files from explicit paths
#'
#' Read data from provided paths and return it as a list of data frames.
#' Supports both .rds and .sas7bdat formats.
#'
#' @param file_paths [character(1+)] Files to read. Optionally named.
#'
#' @return [list] A named list of data frames, where each name is either:
#'  - the name associated to the element in the `file_paths` argument, or, if not provided...
#'  - the name of the file itself, after stripping it of its leading path and trailing extension
#'
#' @export
load <- function(file_paths) {
  checkmate::assert_character(file_paths, min.len = 1)
  checkmate::assert_file_exists(file_paths, access = "r", extension = c("rds", "sas7bdat"))

  read_file_and_attach_metadata <- function(path) {
    extension <- tools::file_ext(path)

    if (toupper(extension) == "RDS") {
      data <- readRDS(path)
    } else if (toupper(extension) == "SAS7BDAT") {
      data <- haven::read_sas(path)
    } else {
      stop("Internal error. Report this message to the maintainer of the `dv.loader` package.")
    }

    meta <- file.info(path, extra_cols = FALSE)
    meta[["path"]] <- path
    meta[["file_name"]] <- basename(path)
    row.names(meta) <- NULL

    attr(data, "meta") <- meta

    return(data)
  }

  data_list <- lapply(file_paths, read_file_and_attach_metadata)

  # Use names provided as arguments
  arg_names <- names(file_paths)
  if (is.null(arg_names)) arg_names <- rep("", length(file_paths))
  names(data_list) <- arg_names

  # If names are not provided, fall back to file names without leading path or trailing extension
  empty_name_indices <- which(arg_names == "")
  names(data_list)[empty_name_indices] <- tools::file_path_sans_ext(basename(file_paths[empty_name_indices]))

  dup_indices <- duplicated(names(data_list))
  if (any(dup_indices)) {
    stop(sprintf(
      "Duplicate entries detected (%s). Please review `file_paths` argument.",
      paste(names(data_list)[dup_indices], collapse = ", ")
    ))
  }

  return(data_list)
}
