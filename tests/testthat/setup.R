# testthat setup file

base_path <- Sys.getenv("RXD_DATA")
local_test_path <- "./../../inst/extdata"

test_file_path <- "test/"
cre_test_files <- c("adsl.sas7bdat", "adae.sas7bdat")
cre_file_names <- c("adsl", "adae")
local_test_files <- c("dummyads1.sas7bdat", "dummyads2.sas7bdat")
local_file_names <- c("dummyads1", "dummyads2")

expected_meta_cols <- c(
  "size", "isdir", "mode", "mtime",
  "ctime", "atime", "path", "file_name"
)
