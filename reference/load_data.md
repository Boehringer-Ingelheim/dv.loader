# Loads data into memory based on study directory and one or more file names

Loads data into memory based on study directory and one or more file
names

## Usage

``` r
load_data(
  sub_dir = NULL,
  file_names,
  use_wd = FALSE,
  prefer_sas = FALSE,
  reduce_memory_footprint = TRUE
)
```

## Arguments

- sub_dir:

  A relative directory/folder that will be appended to a base path
  defined by `Sys.getenv("RXD_DATA")`. If the argument is left as NULL,
  the function will load data from the working directory
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- file_names:

  Study file or file_names name(s) - can be a vector of strings. This is
  the only required argument.

- use_wd:

  for "use working directory" - a flag used when importing local files
  not on NFS - default value is FALSE

- prefer_sas:

  if TRUE, imports .sas7bdat files first instead of .RDS files

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

a list of dataframes

## Examples

``` r
if (FALSE) { # \dontrun{
test_data_path <- "../inst/extdata/"
data_list <- load_data(
  sub_dir = test_data_path,
  file_names = "dummyads2",
  use_wd = TRUE
)
} # }
```
