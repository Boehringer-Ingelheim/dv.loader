test_that("load() can return both default and custom names for loaded data", {
  temp_dir <- tempdir()
  
  iris_file_path <- file.path(temp_dir, "iris.rds")
  mtcars_file_path <- file.path(temp_dir, "mtcars.rds")

  saveRDS(iris, iris_file_path)
  saveRDS(mtcars, mtcars_file_path)
  
  # Loading files with default names
  data_list1 <- load(
    file_paths = c(
      iris_file_path,
      mtcars_file_path
    )
  )
  
  expect_equal(names(data_list1), c("iris", "mtcars"))

  # Loading files with custom names
  data_list2 <- load(
    file_paths = c(
      "iris_data" = iris_file_path,
      "mtcars_data" = mtcars_file_path
    )
  )
  
  expect_equal(names(data_list2), c("iris_data", "mtcars_data"))

  # Loading files with mixed naming (custom and default)
  data_list3 <- load(
    file_paths = c(
      iris_file_path,
      "mtcars_data" = mtcars_file_path
    )
  ) 

  expect_equal(names(data_list3), c("iris", "mtcars_data"))
  
  unlink(temp_dir, recursive = TRUE)
})
