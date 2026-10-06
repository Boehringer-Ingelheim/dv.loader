# Collect file paths based on file names without extensions

Constructs a list of file paths based on an input vector of file names
without extensions. Preference is given to `.parquet` files, if present,
over `.rds` and `.sas7bdat` files unless `prefer_sas` or `prefer_rds` is
`TRUE`. `prefer_sas` and `prefer_rds` are mutually exclusive.

## Usage

``` r
collect_data_list_paths(
  sub_dir,
  file_names,
  use_wd,
  prefer_sas,
  prefer_rds = FALSE
)
```

## Arguments

- sub_dir:

  A relative directory/folder that will be appended to a base path
  defined by `Sys.getenv("RXD_DATA")`. If the argument is left as NULL,
  the function will load data from the working directory
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- file_names:

  CDISC names for the files

- use_wd:

  for "use working directory" - a flag used when importing local files
  not on NFS - default value is FALSE

- prefer_sas:

  if TRUE, imports `.sas7bdat` files first instead of `.parquet` and
  `.rds` files

- prefer_rds:

  if TRUE, imports `.rds` files first instead of `.parquet` and
  `.sas7bdat` files

## Value

a character vector of resolved file paths
