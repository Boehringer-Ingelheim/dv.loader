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

    output <- read_file(file_path, file_name_to_load)

    return(output)
  })

  names(data_list) <- file_names

  return(data_list)
}


#' Reads RDS/SAS file and metadatas from first 6 items from file.info() its file path
#' @param file_path a path to a file
#' @param file_name name of a file
#' @return a data object with an extra attribute of metadata
read_file <- function(file_path, file_name) {
  ext <- tools::file_ext(file_name)

  if (!(toupper(ext) %in% c("RDS", "SAS7BDAT"))) {
    stop("Usage error: read_file: file_name: file must either be RDS or SAS7BDAT.")
  }

  is_rds <- toupper(ext) == "RDS"

  file <- file.path(file_path, file_name)
  file_name <- tools::file_path_sans_ext(file_name)

  # grab file info
  meta <- file.info(file)[1L:6L]
  meta[["path"]] <- row.names(meta)
  meta[["file_name"]] <- file_name
  meta <- data.frame(meta, stringsAsFactors = FALSE)
  row.names(meta) <- NULL

  if (is_rds) {
    out <- readRDS(file)
  } else {
    out <- haven::read_sas(file)
  }
  attr(out, "meta") <- meta

  return(out)
}
