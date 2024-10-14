test_that(  
  desc = vdoc[["add_spec"]](
    desc = "Verifies that load_data() can correctly locate and load data files using 
    relative paths from the current working directory.",
    spec = specs$default_dir
  ), 
  code = {
    # Save the current working directory
    old_wd <- getwd()
    
    # Change the working directory to the temporary directory
    setwd(temp_dir)
    
    lifecycle::expect_deprecated(
      # load_data(): load the RDS file with use_wd = TRUE
      data1 <- dv.loader::load_data(
        sub_dir = ".",
        file_names = "iris.rds",
        use_wd = TRUE
      )    
    )

    lifecycle::expect_deprecated(
      # load_data(): load the SAS file with use_wd = TRUE
      data2 <- dv.loader::load_data(
        sub_dir = ".",
        file_names = "iris.sas7bdat",
        use_wd = TRUE
      )      
    )

    # Expect that the RDS file is loaded
    expect_named(data1, "iris.rds")

    # Expect that the SAS file is loaded
    expect_named(data2, "iris.sas7bdat")

    # Expect that the two data sets are the same
    expect_equal(data1, data2, ignore_attr = TRUE)

    # Set the working directory back to the original directory
    setwd(old_wd)
  }
)
