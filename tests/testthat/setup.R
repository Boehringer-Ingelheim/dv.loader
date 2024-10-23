# validation (S)
vdoc <- local({
  # package_name is used # INSIDE # the sourced file below
  package_name <- "dv.loader" 
  utils_file_path <- system.file("validation", "utils-validation.R", package = package_name, mustWork = TRUE)
  source(utils_file_path, local = TRUE)[["value"]]
})
specs <- vdoc[["specs"]]
#  validation (F)

Sys.setenv("RXD_DATA" = find.package(package = "dv.loader"))
local_test_path <- "inst/extdata"

test_file_path <- "test/"
cre_test_files <- c("adsl.sas7bdat", "adae.sas7bdat")
cre_file_names <- c("adsl", "adae")
local_test_files <- c("dummyads1.sas7bdat", "dummyads2.sas7bdat")
local_file_names <- c("dummyads1", "dummyads2")

expected_meta_cols <- c(
  "size", "isdir", "mode", "mtime",
  "ctime", "atime", "path", "file_name"
)
