test_that(
  desc = vdoc[["add_spec"]](
    desc = "load_data(), load_rds(), load_sas(), and load_xpt() functions correctly extract and
    attach metadata of the file to the loaded data",
    spec = specs$meta_data
  ),
  code = {
    # Get the file info for the iris files
    rds_file_info <- file.info(iris_rds_file, extra_cols = FALSE)
    sas_file_info <- file.info(iris_sas_file, extra_cols = FALSE)
    xpt_file_info <- file.info(iris_xpt_file, extra_cols = FALSE)

    # load_data(): check metadata for RDS file
    expect_equal(
      as.list(attr(iris_data_rds[["iris.rds"]], "meta")[names(rds_file_info)]),
      as.list(rds_file_info)
    )

    # load_data(): check metadata for SAS file
    expect_equal(
      as.list(attr(iris_data_sas[["iris.sas7bdat"]], "meta")[names(sas_file_info)]),
      as.list(sas_file_info)
    )

    # load_rds(): check metadata for RDS file
    expect_equal(
      as.list(attr(iris_rds[["iris.rds"]], "meta")[names(rds_file_info)]),
      as.list(rds_file_info)
    )

    # load_sas(): check metadata for SAS file
    expect_equal(
      as.list(attr(iris_sas[["iris.sas7bdat"]], "meta")[names(sas_file_info)]),
      as.list(sas_file_info)
    )

    # load_xpt(): check metadata for XPT file
    expect_equal(
      as.list(attr(iris_xpt[["iris.xpt"]], "meta")[names(xpt_file_info)]),
      as.list(xpt_file_info)
    )
  }
)
