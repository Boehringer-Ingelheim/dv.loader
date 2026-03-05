# Load data files from explicit paths

Read data from provided paths and return it as a list of data frames.
Supports both .rds and .sas7bdat formats.

## Usage

``` r
load_files(file_paths, reduce_memory_footprint = TRUE)
```

## Arguments

- file_paths:

  `[character(1+)]` Files to read. Optionally named.

- reduce_memory_footprint:

  `[logical(1)]`

  If TRUE, character variables are mapped into factors and
  floating-point variables are mapped into integers, as long as the
  conversion does not lead to loss of precision.

  If FALSE, this function respects the original types returned by the
  underlying calls to
  [`base::readRDS`](https://rdrr.io/r/base/readRDS.html) and
  [`haven::read_sas`](https://haven.tidyverse.org/reference/read_sas.html).

## Value

`[list]` A named list of data frames, where each name is either:

- the name associated to the element in the `file_paths` argument, or,
  if not provided...

- the name of the file itself, after stripping it of its leading path
  and trailing extension
