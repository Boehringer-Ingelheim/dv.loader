test_that("load_files() correctly loads both RDS and SAS files", {
  rds_file <- "inst/extdata/dummyads1.RDS"
  sas_file <- "inst/extdata/dummyads2.sas7bdat"

  data_list <- load_files(file_paths = c(rds_file, sas_file), reduce_memory_footprint = FALSE)

  # Check that default names are correctly assigned based on filenames
  expect_equal(names(data_list), c("dummyads1", "dummyads2"))

  # Verify RDS file contents match direct reading
  expect_equal(data_list[["dummyads1"]], readRDS(rds_file), ignore_attr = "meta")

  # Verify SAS file contents match direct reading
  expect_equal(data_list[["dummyads2"]], as.data.frame(haven::read_sas(sas_file)), ignore_attr = "meta")

  # Create expected metadata for comparison
  rds_metadata <- cbind(
    file.info(rds_file, extra_cols = FALSE),
    path = rds_file,
    file_name = basename(rds_file)
  )
  sas_metadata <- cbind(
    file.info(sas_file, extra_cols = FALSE),
    path = sas_file,
    file_name = basename(sas_file)
  )
  row.names(rds_metadata) <- NULL
  row.names(sas_metadata) <- NULL

  # Verify metadata is correctly attached to loaded data
  expect_equal(attr(data_list[["dummyads1"]], "meta"), rds_metadata)
  expect_equal(attr(data_list[["dummyads2"]], "meta"), sas_metadata)
})

test_that("load_files() works with different file extensions", {
  # GitHub Actions (Assertion on 'file_paths' failed: File does not exist)
  expect_error(
    load_files(file_paths = c(
      "inst/extdata/dummyads1.rds", # extension: RDS
      "inst/extdata/dummyads2.SAS7BDAT" # extension: sas7bdat
    ))
  )
})

test_that("load_files() properly validates file extensions", {
  expect_error(
    load_files(file_paths = c(
      "inst/extdata/bad_file_type.myrds",
      "inst/extdata/bad_file_type.txt"
    ))
  )
})

test_that("load_files() forwards the encoding argument to haven::read_sas", {
  sas_file <- "inst/extdata/dummyads2.sas7bdat"

  expect_equal(
    load_files(sas_file, reduce_memory_footprint = FALSE, encoding = "UTF-8"),
    load_files(sas_file, reduce_memory_footprint = FALSE),
    ignore_attr = "meta"
  )

  expect_error(
    load_files(sas_file, reduce_memory_footprint = FALSE, encoding = "invalid-encoding"),
    "File has an unsupported character set"
  )
})

test_that("load_files() validates the encoding argument", {
  sas_file <- "inst/extdata/dummyads2.sas7bdat"

  expect_error(
    load_files(sas_file, encoding = 1),
    "Must be of type 'string'"
  )
  expect_error(
    load_files(sas_file, encoding = c("UTF-8", "latin1")),
    "Must have length 1"
  )
})

test_that("load_files() ignores the encoding argument for RDS files", {
  rds_file <- "inst/extdata/dummyads1.RDS"

  data_list <- load_files(rds_file, reduce_memory_footprint = FALSE, encoding = "latin1")
  expect_equal(data_list[["dummyads1"]], readRDS(rds_file), ignore_attr = "meta")
})

test_that("load_files() can return both default and custom names for loaded data", {
  # Check that duplicate names are caught and error is thrown
  expect_error(
    load_files(file_paths = c(
      "inst/extdata/just_rds/dummyads1.RDS",
      "inst/extdata/just_sas/dummyads1.sas7bdat"
    )),
    "Duplicate entries detected \\(dummyads1\\). Please review `file_paths` argument."
  )

  # Loading files with default names
  data_list1 <- load_files(
    file_paths = c(
      "inst/extdata/just_rds/dummyads1.RDS",
      "inst/extdata/just_sas/dummyads2.sas7bdat"
    )
  )
  expect_equal(names(data_list1), c("dummyads1", "dummyads2"))

  # Loading files with custom names
  data_list2 <- load_files(
    file_paths = c(
      "rds_dummyads1" = "inst/extdata/just_rds/dummyads1.RDS",
      "sas_dummyads2" = "inst/extdata/just_sas/dummyads2.sas7bdat"
    )
  )
  expect_equal(names(data_list2), c("rds_dummyads1", "sas_dummyads2"))

  # Loading files with mixed naming (custom and default)
  data_list3 <- load_files(
    file_paths = c(
      "rds_dummyads1" = "inst/extdata/just_rds/dummyads1.RDS",
      "inst/extdata/dummyads2.sas7bdat"
    )
  )
  expect_equal(names(data_list3), c("rds_dummyads1", "dummyads2"))
})
