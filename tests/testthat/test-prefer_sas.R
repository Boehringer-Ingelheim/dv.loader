test_that(
  desc = vdoc[["add_spec"]](
    desc = "load_data() loads the RDS file if prefer_sas is FALSE, and it loads the SAS file if prefer_sas is TRUE.",
    spec = specs$prefer_sas
  ), 
  code = {
    # load_data(): load the RDS file with prefer_sas = FALSE
    lifecycle::expect_deprecated(
      data_rds <- dv.loader::load_data(
        sub_dir = ".",
        file_names = "iris.rds",
        prefer_sas = FALSE 
      )
    )
    
    # load_data(): load the SAS file with prefer_sas = TRUE
    lifecycle::expect_deprecated(
      data_sas <- load_data(
        sub_dir = ".", 
        file_names = "iris.sas7bdat",
        prefer_sas = TRUE
      )
    )
    
    # Get metadata for RDS file
    meta_rds <- attr(data_rds[["iris.rds"]], "meta")
    
    # Get metadata for SAS file
    meta_sas <- attr(data_sas[["iris.sas7bdat"]], "meta")
    
    # Check if the correct RDS file is loaded
    expect_equal(basename(meta_rds[["path"]]), "iris.rds")  
    
    # Check if the correct file is loaded
    expect_equal(basename(meta_sas[["path"]]), "iris.sas7bdat")
  }
)
