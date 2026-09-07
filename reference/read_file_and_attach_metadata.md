# Read a data file and attach metadata

Reads an .rds or .sas7bdat file from the given path and attaches
metadata about the file as an attribute.

## Usage

``` r
read_file_and_attach_metadata(path, encoding = NULL)
```

## Arguments

- path:

  `[character(1)]` Path to the data file to read

- encoding:

  `[character(1) | NULL]` Character encoding to use when reading
  `.sas7bdat` files. A value of `NULL` (the default) uses the encoding
  declared in the file. Ignored for `.rds` files.

## Value

A data frame with metadata attached as an attribute named "meta".
