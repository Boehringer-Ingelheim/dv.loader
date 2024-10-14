# Save data to inst/extdata
data_dir <- "inst/extdata"

# Create directory for pharmaverseadam data
if (!dir.exists(file.path(data_dir, "pharmaverseadam"))) {
  dir.create(file.path(data_dir, "pharmaverseadam"), recursive = TRUE)
}

# Save adsl data
haven::write_sas(
  data = pharmaverseadam::adsl,
  path = file.path(data_dir, "pharmaverseadam", "adsl.sas7bdat")
)

# Save adae data
haven::write_sas(
  data = pharmaverseadam::adae,
  path = file.path(data_dir, "pharmaverseadam", "adae.sas7bdat")
)

# Create directory for pharmaversesdtm data
if (!dir.exists(file.path(data_dir, "pharmaversesdtm"))) {
  dir.create(file.path(data_dir, "pharmaversesdtm"), recursive = TRUE)
}

# Save dm data
haven::write_sas(
  data = pharmaversesdtm::dm,
  path = file.path(data_dir, "pharmaversesdtm", "dm.sas7bdat")
)

# Save ae data
haven::write_sas(
  data = pharmaversesdtm::ae,
  path = file.path(data_dir, "pharmaversesdtm", "ae.sas7bdat")
)
