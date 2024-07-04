# Use a list to declare the specs

specs_list <- list

specs <- specs_list(
  "default_dir" = "loads data from the working directory by default",
  "file_names" = "returns an error if file_names is missing",
  "file_type" = "returns an error if the file type is not supported",
  "file_extensions" = "checks for valid file extensions",
  "data_integrity" = "ensures data is loaded correctly",
  "meta_data" = "reads metadata from the items of file.info()",
  "prefer_sas" = "loads a SAS or RDS file based on the prefer_sas flag"
)
