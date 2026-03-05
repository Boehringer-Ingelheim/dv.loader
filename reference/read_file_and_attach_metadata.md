# Read a data file and attach metadata

Reads an .rds or .sas7bdat file from the given path and attaches
metadata about the file as an attribute.

## Usage

``` r
read_file_and_attach_metadata(path)
```

## Arguments

- path:

  `[character(1)]` Path to the data file to read

## Value

A data frame with metadata attached as an attribute named "meta".
