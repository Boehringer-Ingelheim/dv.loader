#' Check if a file has a specific extension (case-insensitive)
#'
#' This function checks if a given file has a specific extension, ignoring case.
#'
#' @param file A character string specifying the path to the file.
#' @param extension A character string specifying the expected file extension (without the dot).
#' @return A logical value: TRUE if the file has the specified extension, FALSE otherwise.
check_file_ext <- function(file, extension) {
  # Check input types
  checkmate::assert_string(file)
  checkmate::assert_string(extension)
  
  # Extract file extension (case-insensitive)
  file_ext <- tolower(tools::file_ext(file))

  # Check that the file extension is not empty
  checkmate::assert_true(file_ext != "")

  # Check that the file extension is one of the allowed choices
  checkmate::assert_choice(file_ext, choices = c("rds", "sas7bdat", "xpt"))
  
  # Compare with the given extension (case-insensitive)
  return(file_ext == tolower(extension))
}


#' Extract file information based on file.info()
#'
#' This function extracts file information from a given file.
#'
#' @param file A character string specifying the path to the file.
#' @return A list containing file information from file.info(file, extra_cols = FALSE) and the path and file name.
file_info <- function(file) {
  # Check if the file exists
  checkmate::assert_file_exists(file)

  # Get file information from file.info()
  info <- file.info(file, extra_cols = FALSE)

  # Get the path from the rownames
  path <- rownames(info)
  
  # Check file and path are the same
  checkmate::assert_true(file == path)

  # Add path and file name
  info[["path"]] <- path
  info[["file_name"]] <- basename(path)

  # Convert to list to remove row names
  info <- as.list(info)
    
  # Return the file information as a list
  return(info)
}
