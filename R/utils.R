#' Collect file paths based on file names without extensions
#' 
#' Constructs a list of file paths based on an input vector of file names without extensions.
#' Preference is given to `.rds` files, if present, over `.sas7bdat` files.
#' @param sub_dir A relative directory/folder that will be appended to a base path defined by `Sys.getenv("RXD_DATA")`.
#' If the argument is left as NULL, the function will load data from the working directory `getwd()`.
#' @param file_names CDISC names for the files
#' @param use_wd for "use working directory" - a flag used when importing local files
#' not on NFS - default value is FALSE
#' @param prefer_sas if TRUE, imports .sas7bdat files first instead of .RDS files
#' @return returns a list of dataframes with metadata as an attribute on each dataframe
#' 
#' @export
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