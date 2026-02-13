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

#' Loads data into memory based on study directory and one or more file names
#' @inheritParams collect_data_list_paths
#' @param file_names Study file or file_names name(s) - can be a vector of strings.
#' This is the only required argument.
#' @inheritParams load_files
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
    preload_file_in_chunks <- function(path, file_size) {
      bytes_left <- file_size
      chunk_size <- 1024**3 # read at most 1 GiB each time
      con <- file(path, "rb")
      on.exit(close(con))
      
      while (bytes_left > 0L) {
        bytes_read <- length(readBin(con, raw(), n = min(chunk_size, bytes_left)))
        if (bytes_read == 0L) break
        bytes_left <- bytes_left - chunk_size
      }
      
      return(NULL)
    }
    
    # Preload file into OS file cache to get faster loads on high-latency media (e.g. network shares)
    try( # If the file is too large to fit into memory, the caching fails instantly and silently
      preload_file_in_chunks(path, meta[["size"]]),
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
#' @param reduce_memory_footprint `[logical(1)]` 
#' 
#' If TRUE, character variables are mapped into factors and floating-point
#' variables are mapped into integers, as long as the conversion does not lead to loss of precision.
#' 
#' If FALSE, this function respects the original types returned by the underlying calls to `base::readRDS` and 
#' `haven::read_sas`.
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

    if (isTRUE(reduce_memory_footprint)) {
      t0 <- Sys.time()
      
      input_size <- as.numeric(utils::object.size(structure(df, meta = NULL)))
      mapped_column_indices <- integer(0)
      
      for (i_col in seq_len(ncol(df))){
        data_and_summary <- reduce_column_memory_footprint(df[[i_col]])
        df[[i_col]] <- data_and_summary[["data"]]
        if (length(data_and_summary[["summary"]])) mapped_column_indices <- c(mapped_column_indices, i_col)
      }
      
      t1 <- Sys.time()
      
      if (length(mapped_column_indices)) {
        attr(df, "meta")[["original_memory_footprint_in_bytes"]] <- input_size
        attr(df, "meta")[["remapped_column_indices"]] <- list(mapped_column_indices)
        attr(df, "meta")[["remapping_time"]] <- t1 - t0
      }
    }
    
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
reduce_column_memory_footprint <- function(col_data) {
  res <- list(data = col_data, summary = character(0))

  known_allowed_classes <- c("Date", "difftime", "POSIXct", "POSIXt")
 
  saved_attr <- attributes(col_data)
  attributes(col_data) <- NULL
  if (length(saved_attr[["class"]]) > 0 && !length(intersect(known_allowed_classes, saved_attr[["class"]]))) {
    return(res)
  }

  if (is.character(col_data)) {
    col_data <- character_to_factor(col_data)
  } else if (inherits(unclass(col_data), "numeric")) {
    # TODO: It may be faster to write a C function that checks whether the original data fits in signed 32-bit integers
    # TODO: Recommend dropping single-valued columns entirely? 
    integer_values <- suppressWarnings(as.integer(col_data))
    numeric_values <- as.numeric(integer_values)
    if (identical(numeric_values, col_data)) {
      col_data <- integer_values
    } else {
      return(res)
    }
  } else {
    return(res)
  }
  
  # if there are repeats, newest attribute value prevails
  attributes(col_data) <- append(saved_attr, attributes(col_data))

  res[["data"]] <- col_data
  res[["summary"]] <- "Mapped"

  return(res)
}

#' Print data remapping report of the transformations performed by `reduce_data_frame_memory_footprint`
#'
#' @param df `[data.frame]` Output from `reduce_data_frame_memory_footprint`
#'
#' @return `[character(1)]` Report
#'
#' @export
memory_use_report <- function(df) {
  numeric_as_human_readable_size <- function(v) {
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
    current_size <- as.numeric(utils::object.size(structure(df, meta = NULL)))
    res <- sprintf("Saved %s (%.2f%%) after re-encoding columns: %s in %.2f seconds", 
                   numeric_as_human_readable_size(original_size - current_size),
                   100 * (original_size - current_size) / original_size,
                   mapped_columns, meta[["remapping_time"]])
  }
  
  return(res)
}
