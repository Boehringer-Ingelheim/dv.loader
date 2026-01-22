#' For each file name provided, reads in the first matching file and its meta data/attributes.
#' Preference is given to RDS because its faster
#' @param sub_dir A relative directory/folder that will be appended to a base path defined by `Sys.getenv("RXD_DATA")`.
#' If the argument is left as NULL, the function will load data from the working directory `getwd()`.
#' @param file_names CDISC names for the files
#' @param use_wd for "use working directory" - a flag used when importing local files
#' not on NFS - default value is FALSE
#' @param prefer_sas if TRUE, imports .sas7bdat files first instead of .RDS files
#' @return returns a list of dataframes with metadata as an attribute on each dataframe
collect_data_list_paths <- function(sub_dir, file_names, use_wd, prefer_sas) {
  
  file_path <- "" # will be built using args

  if (is.null(sub_dir)) {
    file_path <- getwd()
  } else {
    if (use_wd) {
      file_path <- file.path(getwd(), sub_dir)
    } else {
      file_path <- file.path(get_cre_path(), sub_dir)
    }
  }
  
  data_list <- sapply(file_names, function(x) {
    extensions <- c("", ".rds", ".sas7bdat")
    if (prefer_sas) {
      extensions <- c("", ".sas7bdat", ".rds")
    }

    file_name_to_load <- NULL

    candidates <- list.files(file_path)
    uppercase_candidates <- Map(toupper, candidates)

    for (ext in extensions) {
      # Case insensitive file name match
      uppercase_file_name <- toupper(paste0(x, ext))

      match_count <- sum(uppercase_candidates == uppercase_file_name)
      if (match_count > 1) {
        stop(paste("collect_data_list_paths(): More than one case-insensitive file name match for", file_path, x))
      }

      index <- match(uppercase_file_name, uppercase_candidates)
      if (!is.na(index)) {
        file_name_to_load <- candidates[[index]]
        break
      }
    }

    if (is.null(file_name_to_load)) {
      stop(paste("collect_data_list_paths(): No RDS or SAS files found for", file_path, x))
    }

    output <- file.path(file_path, file_name_to_load)
    return(output)
  })

  names(data_list) <- file_names

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
      readBin(path, raw(), meta[["size"]]), # The return value goes unasigned on purpose
      silent = TRUE
    )
    data <- haven::read_sas(path)
  } else {
    stop(sprintf("Unrecognized extension for file `.%s`. dv.loader supports only `.rds` and `.sas7bdat` files. ", path))
  }

  meta[["path"]] <- path
  meta[["file_name"]] <- basename(path)
  row.names(meta) <- NULL

  attr(data, "meta") <- meta

  return(data)
}
