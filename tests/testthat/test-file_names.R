test_that(
  desc = vdoc[["add_spec"]](
    desc = "appropriate error messages are thrown when the required 'file_names' argument is not provided",
    spec = specs$file_names
  ),
  code = {
    lifecycle::expect_deprecated(
      # load_data(): expect an error when the file_names argument is missing
      load_data(sub_dir = ".")
    ) |>
      expect_error('argument "file_names" is missing, with no default')

    # Expected error message
    error_msg <- 'argument "files" is missing, with no default'

    # load_rds(): expect an error when the files argument is missing
    expect_error(dv.loader::load_rds(), error_msg)

    # load_sas(): expect an error when the files argument is missing
    expect_error(dv.loader::load_sas(), error_msg)

    # load_xpt(): expect an error when the files argument is missing
    expect_error(dv.loader::load_xpt(), error_msg)
  }
)
