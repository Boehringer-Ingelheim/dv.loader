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
