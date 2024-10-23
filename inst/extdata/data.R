# Create directory for pharmaverseadam data if it doesn't exist
data_dir <- file.path("inst", "extdata", "pharmaverseadam")
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}

# Sample 10 subjects from adsl data
set.seed(123) # For reproducibility
adsl_sample <- pharmaverseadam::adsl |> 
  dplyr::sample_n(size = 10)

# Filter adae data for the 10 subjects in adsl_sample
adae_sample <- pharmaverseadam::adae |> 
  dplyr::filter(USUBJID %in% adsl_sample$USUBJID)

# Save adsl_sample to rds file
saveRDS(
  object = adsl_sample,
  file = file.path(data_dir, "adsl_sample.rds")
)

# Save adae_sample to rds file
saveRDS(
  object = adae_sample,
  file = file.path(data_dir, "adae_sample.rds")
)

# Write adsl_sample to sas7bdat file
haven::write_sas(
  data = adsl_sample,
  path = file.path(data_dir, "adsl_sample.sas7bdat")
)

# Write adae_sample to sas7bdat file
haven::write_sas(
  data = adae_sample,
  path = file.path(data_dir, "adae_sample.sas7bdat")
)

# Add a message to confirm data creation
message("Sample data files have been created in ", data_dir)
