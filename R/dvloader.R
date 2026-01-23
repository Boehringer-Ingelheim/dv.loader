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
load_data <- function(sub_dir = NULL, file_names, use_wd = FALSE, prefer_sas = FALSE, reduce_memory_footprint = TRUE) {
  if (length(file_names) == 0) {
    stop("Usage: load_data: file_names: Must supply at least one file name")
  }

  # create the output
  paths <- collect_data_list_paths(sub_dir, file_names, use_wd, prefer_sas)
  data_list <- load_files(file_paths = paths, reduce_memory_footprint = reduce_memory_footprint)

  return(data_list)
}

#' Read a data file and attach metadata
#'
#' Reads an .rds or .sas7bdat file from the given path and attaches metadata about the file
#' as an attribute.
#'
#' @param path `[character(1)]` Path to the data file to read
#'
#' @return A data frame with metadata attached as an attribute named "meta".
#'
#' @keywords internal
read_file_and_attach_metadata <- function(path) {
  meta <- file.info(path, extra_cols = FALSE)
  extension <- tools::file_ext(path)

  if (toupper(extension) == "RDS") {
    data <- readRDS(path)
  } else if (toupper(extension) == "SAS7BDAT") {
    # Preload file into OS file cache to get faster loads on high-latency media (e.g. network shares)
    try( # If the file is too large to fit into memory, the caching fails instantly and silently
      readBin(path, raw(), meta[["size"]]), # The return value goes unassigned on purpose
      silent = TRUE
    )
    data <- as.data.frame(haven::read_sas(path))
  } else {
    stop(sprintf("Unrecognized extension for file `.%s`. dv.loader supports only `.rds` and `.sas7bdat` files. ", path))
  }

  meta[["path"]] <- path
  meta[["file_name"]] <- basename(path)
  row.names(meta) <- NULL

  attr(data, "meta") <- meta

  return(data)
}

#' Load data files from explicit paths
#'
#' Read data from provided paths and return it as a list of data frames.
#' Supports both .rds and .sas7bdat formats.
#'
#' @param file_paths `[character(1+)]` Files to read. Optionally named.
#'
#' @return `[list]` A named list of data frames, where each name is either:
#'  - the name associated to the element in the `file_paths` argument, or, if not provided...
#'  - the name of the file itself, after stripping it of its leading path and trailing extension
#'
#' @export
load_files <- function(file_paths, reduce_memory_footprint = TRUE) {
  checkmate::assert_character(file_paths, min.len = 1)
  checkmate::assert_file_exists(file_paths, access = "r", extension = c(".rds", ".sas7bdat"))

  data_list <- list()
  for (path in file_paths){
    df <- read_file_and_attach_metadata(path)
    if (isTRUE(reduce_memory_footprint)) df <- reduce_data_frame_memory_footprint(df)
    data_list[[path]] <- df
  }

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

#' Transform data.frame columns to use leaner types
#'
#' Transforms character columns into factors and numeric content into integer vectors, when it does not
#' lead to loss of precision.
#'
#' @param df `[data.frame]` Data frame to transform
#'
#' @return `[data.frame]` Transformed data frame
#'
#' @export
reduce_data_frame_memory_footprint <- function(df) {
  known_allowed_classes <- c("Date", "difftime", "POSIXct", "POSIXt")
 
  input_size <- as.integer(utils::object.size(structure(df, meta = NULL)))
  mapped_column_indices <- integer(0)
  
  for (i_col in seq_len(ncol(df))){
    col_data <- df[[i_col]]
    
    saved_attr <- attributes(col_data)
    attributes(col_data) <- NULL
    if (length(saved_attr[["class"]]) > 0 && !length(intersect(known_allowed_classes, saved_attr[["class"]]))) next
    
    if (is.character(col_data)) {
      df[[i_col]] <- as.factor(col_data)
    } else if (inherits(col_data, "numeric")) {
      integer_values <- as.integer(col_data)
      numeric_values <- as.numeric(integer_values)
      if (identical(numeric_values, col_data)) {
        df[[i_col]] <- integer_values
      }
    } else {
      browser() # TODO: Remove for release
      next
    }
    # TODO? Recommend dropping single-valued columns?
    
    mapped_column_indices <- c(mapped_column_indices, i_col)
    
    # if there are repeats, newest attribute value prevails
    attributes(df[[i_col]]) <- append(saved_attr, attributes(df[[i_col]]))
  }
 
  if (length(mapped_column_indices)) {
    attr(df, "meta")[["original_memory_footprint_in_bytes"]] <- input_size
    attr(df, "meta")[["remapped_column_indices"]] <- list(mapped_column_indices)
  }
  
  return(df)
}

#' Print data remapping report of the transformations performed by `reduce_data_frame_memory_footprint`
#'
#' @param df `[data.frame]` Output from `reduce_data_frame_memory_footprint`
#'
#' @return `[character(1)]` Report
#'
#' @export
memory_use_report <- function(df) {
  integer_as_human_readable_size <- function(v) {
    return(capture.output(
      print(structure(v, class = "object_size"),  units = "auto", standard = "IEC")
    ))
  }
  
  res <- "No data was remapped"
  
  meta <- attr(df, "meta")
  
  mapped_column_indices <- meta[["remapped_column_indices"]][[1]]
  if (length(mapped_column_indices)) {
    mapped_columns <- paste(names(df)[mapped_column_indices], collapse = ", ")
    original_size <- meta[["original_memory_footprint_in_bytes"]]
    current_size <- as.integer(utils::object.size(structure(df, meta = NULL)))
    res <- sprintf("Saved %s (%.2f%%) after re-encoding columns: %s.", 
                   integer_as_human_readable_size(original_size - current_size),
                   100 * (original_size - current_size) / original_size,
                   mapped_columns)
  }
  
  return(res)
}
