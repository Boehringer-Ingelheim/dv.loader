# validation (S)
vdoc <- local({
  package_name <- "dv.loader" # package_name is used *INSIDE* the sourced file below
  utils_file_path <- system.file("validation", "utils-validation.R", package = package_name, mustWork = TRUE)
  source(file = utils_file_path, local = TRUE)[["value"]]
})

specs <- vdoc[["specs"]]
# validation (F)

# Create a copy of the iris data
iris_data <- iris

# Change . to _ in column names
names(iris_data) <- gsub("\\.", "_", names(iris_data))

# Create a temporary directory
temp_dir <- tempdir()

# Path to the data files
iris_file <- file.path(temp_dir, "iris")
iris_rds_file <- file.path(temp_dir, "iris.rds")
iris_sas_file <- file.path(temp_dir, "iris.sas7bdat")
iris_xpt_file <- file.path(temp_dir, "iris.xpt")
iris_txt_file <- file.path(temp_dir, "iris.txt")

# Save data to file with no extension
saveRDS(iris_data, iris_file)

# Save iris data to RDS file
saveRDS(iris_data, iris_rds_file)

# Save iris data to SAS file
lifecycle::expect_deprecated(
  haven::write_sas(iris_data, iris_sas_file)
)

# Save iris data to XPT file
haven::write_xpt(iris_data, iris_xpt_file)

# Save iris data to TXT file
write.table(iris_data, file = iris_txt_file, row.names = FALSE)

# Set the RXD_DATA environment variable
Sys.setenv(RXD_DATA = temp_dir)

# Load RDS data via load_data()
lifecycle::expect_deprecated(
  iris_data_rds <- dv.loader::load_data(
    sub_dir = ".", 
    file_names = "iris.rds"
  )
)

# Load SAS data via load_data()
lifecycle::expect_deprecated(
  iris_data_sas <- dv.loader::load_data(
    sub_dir = ".", 
    file_names = "iris.sas7bdat"
  )
)

# Load the data from the files
iris_rds <- dv.loader::load_rds(files = iris_rds_file)
iris_sas <- dv.loader::load_sas(files = iris_sas_file)
iris_xpt <- dv.loader::load_xpt(files = iris_xpt_file)
