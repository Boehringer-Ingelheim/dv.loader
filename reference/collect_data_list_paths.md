# Collect file paths based on file names without extensions

Constructs a list of file paths based on an input vector of file names
without extensions. Preference is given to `.rds` files, if present,
over `.sas7bdat` files.

## Usage

``` r
collect_data_list_paths(sub_dir, file_names, use_wd, prefer_sas)
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

  if TRUE, imports .sas7bdat files first instead of .RDS files

## Value

returns a list of dataframes with metadata as an attribute on each
dataframe
