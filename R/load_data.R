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
#' @export
#' @importFrom lifecycle deprecate_warn
load_data <- function(sub_dir = NULL, file_names, use_wd = FALSE, prefer_sas = FALSE) {
  lifecycle::deprecate_warn("3.0.0", "load_data()", "read_data()")
  
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

#' gets the NFS base path from an env var
#' It assumes there is an env var
#' called RXD_DATA which holds the path suffix.
#' @return the NFS base path
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
get_cre_path <- get_nfs_path


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
