test_that(
  desc = vdoc[["add_spec"]](
    desc = "appropriate error messages are thrown when attempting to load or read files without valid extensions",
    spec = specs$file_extensions
  ), 
  code = {
    # load_data(): load data with no file extension
    lifecycle::expect_deprecated(
      dv.loader::load_data(sub_dir = ".", file_names = "iris")
    ) |>
      expect_error("file must either be RDS or SAS7BDAT")
    
    # Expected error message
    error_msg <- "Assertion on 'file_ext != \"\"' failed: Must be TRUE."

    # load_rds(): expect an error when the file extension is empty
    dv.loader::load_rds(files = iris_file) |> 
      expect_error(error_msg) 

    # load_sas(): expect an error when the file extension is empty
    dv.loader::load_sas(files = iris_file) |> 
      expect_error(error_msg)

    # load_xpt(): expect an error when the file extension is empty
    dv.loader::load_xpt(files = iris_file) |> 
      expect_error(error_msg)
  }
)
