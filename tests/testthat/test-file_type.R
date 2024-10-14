test_that(
  desc = vdoc[["add_spec"]](
    desc = "appropriate error messages are thrown when attempting to load or
    read file with types that are not supported.",
    spec = specs$file_type
  ),
  code = {
    # load_data(): expect an error when the file type is not supported
    lifecycle::expect_deprecated(
      dv.loader::load_data(sub_dir = ".", file_names = "iris.txt")
    ) |>
      expect_error("file must either be RDS or SAS7BDAT")

    # Expected error message
    error_msg <- "Must be element of set \\{'rds','sas7bdat','xpt'\\}, but is 'txt'."

    # load_rds(): expect an error when the file extension is not supported
    expect_error(dv.loader::load_rds(files = iris_txt_file), error_msg)

    # load_sas(): expect an error when the file extension is not supported
    expect_error(dv.loader::load_sas(files = iris_txt_file), error_msg)

    # load_xpt(): expect an error when the file extension is not supported
    expect_error(dv.loader::load_xpt(files = iris_txt_file), error_msg)
  }
)
