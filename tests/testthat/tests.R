test_that(
  "defaults to using the working directory when sub_dir arg is NULL" %>%
    vdoc[["add_spec"]](specs$default_dir),
  {
    expect_error(
      load_data(file_names = local_file_names)
    )
  }
)

test_that(
  "throws an error if you don't provide 'file_names'" %>%
    vdoc[["add_spec"]](specs$file_names),
  {
    expect_error(
      load_data(file_names = NULL)
    )
  }
)

test_that(
  "throws an error if you provide a file type which is not supported" %>%
    vdoc[["add_spec"]](specs$file_type),
  {
    expect_error(
      load_data(
        sub_dir = local_test_path,
        file_names = "bad_file_type"
      )
    )
  }
)

test_that(
  "does not throw an error if provided valid extensions" %>%
    vdoc[["add_spec"]](specs$file_extensions),
  {
    expect_error(
      load_data(
        sub_dir = local_test_path,
        file_names = "dummyads1.RDS",
        use_wd = TRUE
      ),
      NA
    )
  }
)


test_that(
  "can mix file_names with valid extensions" %>%
    vdoc[["add_spec"]](specs$file_extensions),
  {
    actual <- load_data(
      sub_dir = local_test_path,
      file_names = c("dummyads1.RDS", "dummyads2.sas7bdat"),
      use_wd = TRUE
    )
    actual <- c(
      tools::file_ext(attributes(actual[[1]])$meta$path),
      tools::file_ext(attributes(actual[[2]])$meta$path)
    )
    expected <- c("RDS", "sas7bdat")
    expect_equal(actual, expected)
  }
)

test_that(
  "can mix file_names with and without valid extensions" %>%
    vdoc[["add_spec"]](specs$file_extensions),
  {
    expect_error(
      load_data(
        sub_dir = local_test_path,
        file_names = c("dummyads1", "dummyads2.RDS"),
        use_wd = TRUE
      ),
      NA
    )
  }
)

test_that(
  "does not throw an error if you provide valid extensions" %>%
    vdoc[["add_spec"]](specs$file_extensions),
  {
    expect_error(
      load_data(
        sub_dir = local_test_path,
        file_names = c("bad_file_type.txt"),
        use_wd = TRUE
      )
    )
    expect_error(
      load_data(
        sub_dir = local_test_path,
        file_names = c("bad_file_type.myrds"),
        use_wd = TRUE
      )
    )
  }
)

test_that(
  "maintains integrity of data from producing system to consuming system" %>%
    vdoc[["add_spec"]](specs$data_integrity),
  {
    actual <- load_data(
      sub_dir = local_test_path,
      file_names = local_file_names[2],
      use_wd = TRUE,
      prefer_sas = TRUE
    )

    actual <- actual[[1]]

    attr(actual, "meta") <- NULL
    attr(actual, "label") <- "dummyads2"

    expected <- haven::read_sas(file.path(local_test_path, local_test_files[2]))
    attr(expected, "label") <- "dummyads2"

    expect_equal(
      actual,
      expected
    )
  }
)

test_that(
  "has correct metadata" %>%
    vdoc[["add_spec"]](specs$meta_data),
  {
    actual <- load_data(
      sub_dir = local_test_path,
      file_names = local_file_names[2],
      use_wd = TRUE
    )
    actual_meta <- attr(actual[[1]], "meta")
    expect_equal(
      c(
        "size", "isdir", "mode",
        "mtime", "ctime", "atime",
        "path", "file_name"
      ),
      names(actual_meta)
    )
  }
)

test_that(
  "loads an RDS file when prefer_sas is FALSE (default) and both SAS and RDS files exist" %>%
    vdoc[["add_spec"]](specs$prefer_sas),
  {
    actual <- load_data(
      sub_dir = local_test_path,
      file_names = local_file_names[2],
      use_wd = TRUE
    )
    actual <- attr(actual[[1]], "meta")[["path"]]
    expect_equal(grepl(".RDS$", actual, ignore.case = FALSE), TRUE)
  }
)

test_that(
  "loads a SAS file when prefer_sas is FALSE (default) and an RDS file doesn't exist" %>%
    vdoc[["add_spec"]](specs$prefer_sas),
  {
    actual <- load_data(
      sub_dir = file.path(local_test_path, "just_sas"),
      file_names = local_file_names[2],
      use_wd = TRUE
    )
    actual <- attr(actual[[1]], "meta")[["path"]]
    expect_equal(grepl(".sas7bdat$", actual, ignore.case = TRUE), TRUE)
  }
)

test_that(
  "loads a SAS file when prefer_sas is TRUE and both SAS and RDS files exist" %>%
    vdoc[["add_spec"]](specs$prefer_sas),
  {
    actual <- load_data(
      sub_dir = local_test_path,
      file_names = local_file_names[2],
      use_wd = TRUE,
      prefer_sas = TRUE
    )
    actual <- attr(actual[[1]], "meta")[["path"]]
    expect_equal(grepl(".sas7bdat$", actual), TRUE)
  }
)

test_that(
  "loads an RDS file when prefer_sas is TRUE and a SAS file doesn't exist" %>%
    vdoc[["add_spec"]](specs$prefer_sas),
  {
    actual <- load_data(
      sub_dir = file.path(local_test_path, "just_rds"),
      file_names = local_file_names[2],
      use_wd = TRUE,
      prefer_sas = TRUE
    )
    actual <- attr(actual[[1]], "meta")[["path"]]
    expect_equal(grepl(".RDS$", actual), TRUE)
  }
)

test_that(
  "prefer_sas is not used if file extension is included in file_names" %>%
    vdoc[["add_spec"]](specs$prefer_sas),
  {
    data_list <- load_data(
      sub_dir = local_test_path,
      file_names = c("dummyads1.RDS", "dummyads2.sas7bdat"),
      use_wd = TRUE,
      prefer_sas = FALSE
    )
    expect_equal(tools::file_ext(attr(data_list[[1]], "meta")$path), "RDS")
    expect_equal(tools::file_ext(attr(data_list[[2]], "meta")$path), "sas7bdat")
  }
)
