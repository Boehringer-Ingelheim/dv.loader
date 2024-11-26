#' For each file name provided, reads in the first matching file and its meta data/attributes.
#' Preference is given to RDS because its faster
#' @param file_path the folder where the files are
#' @param file_names CDISC names for the files
#' @param prefer_sas if TRUE, imports .sas7bdat files first instead of .RDS files
#' @return returns a list of dataframes with metadata as an attribute on each dataframe
create_data_list <- function(file_path, file_names, prefer_sas) {
  data_list <- lapply(file_names, function(x) {
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
        stop(paste("create_data_list(): More than one case-insensitive file name match for", file_path, x))
      }

      index <- match(uppercase_file_name, uppercase_candidates)
      if (!is.na(index)) {
        file_name_to_load <- candidates[[index]]
        break
      }
    }

    if (is.null(file_name_to_load)) {
      stop(paste("create_data_list(): No RDS or SAS files found for", file_path, x))
    }

    output <- read_file_and_attach_metadata(file.path(file_path, file_name_to_load))
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
#' @param path [character(1)] Path to the data file to read
#'
#' @return A data frame with metadata attached as an attribute named "meta".
#'
#' @keywords internal
read_file_and_attach_metadata <- function(path) {
  extension <- tools::file_ext(path)
  
  if (toupper(extension) == "RDS") {
    data <- readRDS(path)
  } else if (toupper(extension) == "SAS7BDAT") {
    data <- haven::read_sas(path)
  } else {
    stop("Not supported file type, only .rds or .sas7bdat files can be loaded.")
  }
  
  meta <- file.info(path, extra_cols = FALSE)
  meta[["path"]] <- path
  meta[["file_name"]] <- basename(path)
  row.names(meta) <- NULL
  
  attr(data, "meta") <- meta
  
  return(data)
}
