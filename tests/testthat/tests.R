test_that("defaults to using the working directory when sub_dir arg is NULL", {
  expect_error(
    load_data(
      file_names = local_file_names
    )
  )
})

test_that("throws an error if you don't provide 'file_names'", {
  expect_error(
    load_data(file_names = NULL)
  )
})

test_that("throws an error if you provide a non CRE file type", {
  expect_error(
    load_data(
      sub_dir = local_test_path,
      file_names = "bad_file_type"
    )
  )
})

test_that("does not throw an error if provided valid extensions", {
  expect_error(
    load_data(
      sub_dir = local_test_path,
      file_names = "dummyads1.RDS",
      use_wd = TRUE
    ),
    NA
  )
})

test_that("can mix file_names with valid extensions", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = c("dummyads1.RDS", "dummyads1.sas7bdat"),
    use_wd = TRUE
  )
  actual <- c(
    tools::file_ext(attributes(actual[[1]])$meta$path),
    tools::file_ext(attributes(actual[[2]])$meta$path)
  )
  expected <- c("RDS", "sas7bdat")
  expect_equal(actual, expected)
})

test_that("can mix file_names with and without valid extensions", {
  expect_error(
    load_data(
      sub_dir = local_test_path,
      file_names = c("dummyads1", "dummyads2.RDS"),
      use_wd = TRUE
    ),
    NA
  )
})

test_that("does not throw an error if you provide valid extensions", {
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
})

test_that("maintains integrity of data from producing system to consuming system", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = local_file_names[2],
    use_wd = TRUE, prefer_sas = TRUE
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
})

test_that("has correct metadata", {
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
})

test_that("loads an RDS file when prefer_sas is FALSE (default) and both SAS and RDS files exist", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = local_file_names[2],
    use_wd = TRUE
  )
  actual <- attr(actual[[1]], "meta")[["path"]]
  expect_equal(grepl(".RDS$", actual, ignore.case = TRUE), TRUE)
})

test_that("loads a SAS file when prefer_sas is FALSE (default) and an RDS file doesn't exist", {
  actual <- load_data(
    sub_dir = file.path(local_test_path, "just_sas"),
    file_names = local_file_names[2],
    use_wd = TRUE
  )
  actual <- attr(actual[[1]], "meta")[["path"]]
  expect_equal(grepl(".sas7bdat$", actual, ignore.case = TRUE), TRUE)
})

test_that("loads a SAS file when prefer_sas is TRUE and both SAS and RDS files exist", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = local_file_names[2],
    use_wd = TRUE, prefer_sas = TRUE
  )
  actual <- attr(actual[[1]], "meta")[["path"]]
  expect_equal(grepl(".sas7bdat$", actual), TRUE)
})

test_that("loads an RDS file when prefer_sas is TRUE and a SAS file doesn't exist", {
  actual <- load_data(
    sub_dir = file.path(local_test_path, "just_rds"),
    file_names = local_file_names[2],
    use_wd = TRUE, prefer_sas = TRUE
  )
  actual <- attr(actual[[1]], "meta")[["path"]]
  expect_equal(grepl(".RDS$", actual), TRUE)
})

test_that("uses working directory when use_wd is set to TRUE", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = local_file_names[[2L]],
    use_wd = TRUE
  )
  actual <- attr(actual[[1L]], "meta")[["path"]]
  expect_equal(grepl(getwd(), actual), TRUE)
})

test_that("uses the sub_dir prefixed by the working directory when use_wd = TRUE", {
  actual <- load_data(
    sub_dir = local_test_path,
    file_names = local_file_names[[2L]],
    use_wd = TRUE
  )
  actual <- attr(actual[[1L]], "meta")[["path"]]
  expect_equal(grepl(getwd(), actual), TRUE)
})
