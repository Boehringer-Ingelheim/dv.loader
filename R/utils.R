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
  checkmate::assert_character(dir_path, len = 1)
  checkmate::assert_character(file_names, min.len = 1)
  checkmate::assert_logical(prefer_sas, len = 1)

  file_paths <- lapply(file_names, function(x) {
    extensions <- c("", ".rds", ".sas7bdat")
    if (prefer_sas) {
      extensions <- c("", ".sas7bdat", ".rds")
    }

    file_name_to_load <- NULL

    candidates <- list.files(dir_path)
    uppercase_candidates <- Map(toupper, candidates)

    for (ext in extensions) {
      # Case insensitive file name match
      uppercase_file_name <- toupper(paste0(x, ext))

      match_count <- sum(uppercase_candidates == uppercase_file_name)
      if (match_count > 1) {
        stop(paste("get_file_paths(): More than one case-insensitive file name match for", dir_path, x))
      }

      index <- match(uppercase_file_name, uppercase_candidates)
      if (!is.na(index)) {
        file_name_to_load <- candidates[[index]]
        break
      }
    }

    if (is.null(file_name_to_load)) {
      stop(paste("create_data_list(): No RDS or SAS files found for", dir_path, x))
    }

    return(file.path(dir_path, file_name_to_load))
  })

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
  checkmate::assert_character(file_paths, min.len = 1)
  checkmate::assert_file_exists(file_paths)

  data_list <- lapply(file_paths, function(file_path) {
    extension <- tools::file_ext(file_path)

    if (tolower(extension) == "rds") {
      data <- readRDS(file_path)
    } else if (tolower(extension) == "sas7bdat") {
      data <- haven::read_sas(file_path)
    } else {
      stop("Unsupported file extension: ", extension)
    }

    meta <- file.info(file_path, extra_cols = FALSE)
    meta[["path"]] <- file_path
    meta[["file_name"]] <- basename(file_path)

    rownames(data) <- NULL
    attr(data, "meta") <- meta

    return(data)
  })

  names(data_list) <- tools::file_path_sans_ext(basename(file_paths))

  if (any(duplicated(names(data_list)))) {
    stop("load_data_files(): Duplicate file names detected. Please ensure all file names are unique.")
  }

  return(data_list)
}
