test_that(
  desc = vdoc[["add_spec"]](
    desc = "Ensures that the data integrity is maintained across different file types and loading methods, comparing the loaded data against a known reference dataset.",
    spec = specs$data_integrity
  ), 
  code = { 
    # load_data(): check that the RDS file is loaded correctly
    expect_equal(
      object = iris_data_rds[["iris.rds"]],
      expected = iris_data,
      ignore_attr = TRUE
    )
    
    # load_data(): check that the SAS file is loaded correctly
    expect_equal(
      object = iris_data_sas[["iris.sas7bdat"]],
      expected = iris_data,
      ignore_attr = TRUE
    )

    # load_rds(): check that the RDS file is loaded correctly
    expect_equal(
      object = iris_rds[["iris.rds"]], 
      expected = iris_data,
      ignore_attr = TRUE
    )
    
    # load_sas(): check that the SAS file is loaded correctly
    expect_equal(
      object = iris_sas[["iris.sas7bdat"]], 
      expected = iris_data,
      ignore_attr = TRUE
    )
    
    # load_xpt(): check that the XPT file is loaded correctly
    expect_equal(
      object = iris_xpt[["iris.xpt"]], 
      expected = iris_data,
      ignore_attr = TRUE
    )
  }
)
