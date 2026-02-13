test_that("Output of character_to_factor is identical to that of base::as.factor for character(n) inputs" |> vdoc[["add_spec"]](specs$leaner_data_types), {
  # set a known random seed to allow reproducing failed tests
  rng_seed <- local({
    runif(1)
    return(.Random.seed)
  })
  int_seed <- as.integer(Sys.time()) # Force random seed to get fresh tests
  set.seed(int_seed)
  
  # test proper 
  tests <- list()
 
  # edge cases 
  tests[["empty input"]] <- character(0)
  tests[["NA"]] <- c(NA_character_)
  tests[["empty string"]] <- c('')
  tests[["power of two levels and rows"]] <- c('b', 'a', 'd', 'c')
  tests[["power of two levels and rows and NA"]] <- c('b', 'a', NA, 'd', 'c')
  tests[["single value"]] <- c('a', 'a', 'a', 'a')
 
  # one biggish random test
  tests[[sprintf("many strings (seed %d)", int_seed)]] <- local({
    test <- as.character(sample.int(sample.int(1e6, 1), replace = TRUE))
    replace_some_element_with_NAs <- sample(c(TRUE, FALSE), size = 1)
    if(isTRUE(replace_some_element_with_NAs)) {
      NA_indices <- sample(length(test), size = sample(length(test), size = 1))
      test[NA_indices] <- NA_character_
    }
    return(test)
  })
  
  for(i in seq_along(tests)){
    desc <- names(tests)[[i]]
    test <- tests[[i]]
    expect_identical(as.factor(test), dv.loader:::character_to_factor(test), 
                     info = sprintf('Issue in test: "%s"', desc))
  }
  
  set.seed(rng_seed) # restore old RNG state, just in case
})

test_that("reduce_column_memory_footprint transforms known reduceable types" |> vdoc[["add_spec"]](specs$leaner_data_types), {
  tests <- list()
  tests[["character"]] <- list(character(0), TRUE)
  tests[["integer"]] <- list(integer(0), FALSE)
  tests[["numeric"]] <- list(numeric(0), TRUE)
  tests[["fractional numeric"]] <- list(c(.5), FALSE)
  tests[["largest integer"]] <- list(c(2**31-1), TRUE)
  tests[["one past the largest integer"]] <- list(c(2**31), FALSE)
  tests[["smallest integer"]] <- list(c(-2**31+1), TRUE)
  tests[["one past the smallest integer"]] <- list(c(-2**31), FALSE)
  tests[["Date"]] <- list(as.Date(0), TRUE)
  tests[["difftime"]] <- list(as.Date(1)-as.Date(0), TRUE)
  tests[["POSIXct"]] <- list(as.POSIXct(0), TRUE)
  tests[["unknown class"]] <- list(structure(1, class = 'unknown_class'), FALSE)
  
  for(i in seq_along(tests)){
    desc <- names(tests)[[i]]
    test <- tests[[i]]
    test_input <- test[[1]]
    test_expected_outcome <- test[[2]]
    test_output <- dv.loader::reduce_column_memory_footprint(test_input)
    
    # conversion does not drop attributes
    lost_attributes <- setdiff(attributes(test_input), attributes(test_output[["data"]]))
    expect_length(lost_attributes, 0)
   
    # mapping behaves as expected
    outcome <- identical(test_output[["summary"]], "Mapped")
    expect_identical(outcome, test_expected_outcome, info = sprintf('Issue in test: "%s"', desc))
  }
})
