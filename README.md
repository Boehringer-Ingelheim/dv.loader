# dv.loader

The {dv.loader} package offers a unified approach for loading various data file formats in R. It provides a set of functions to import RDS, SAS, and XPT files, with built-in error handling and metadata extraction. The package is specifically designed to work seamlessly with the [{dv.manager}](https://boehringer-ingelheim.github.io/dv.manager/) package, facilitating the creation of modular Shiny applications within the DaVinci framework.

## Key Features

Below are the key features of {dv.loader}:

- **Versatile File Formats**: Currently supports RDS, SAS, and XPT files.
- **Rich Metadata**: Includes file-specific metadata for each dataset.
- **Error Handling**: Checks for file existence and format for each file.
- **Consistent Output**: Returns a named list of data frames and associated metadata.
- **DaVinci Framework Integration**: Works seamlessly with other DaVinci framework packages.

## Installation

While {dv.loader} is not currently available on CRAN, you can obtain the development version from GitHub using the following method:

```r
# Install the {remotes} package if you haven't already
if (!require("remotes")) install.packages("remotes")

# Install the development version of {dv.loader}
remotes::install_github("Boehringer-Ingelheim/dv.loader")

# Check the package version
packageVersion("dv.loader")
```

NOTE: The legacy `load_data()` function has been deprecated in version 3.0.0 of {dv.loader}. It is strongly recommended to transition to the new set of functions for data loading. See the [Migration Guide](https://boehringer-ingelheim.github.io/dv.loader/articles/migration-guide.html) vignette for more details.

## Main Functions

The package includes a collection of functions designed to handle various file formats. 

- `load_rds()`: Imports RDS files (extension: `.rds`)
- `load_sas()`: Imports SAS files (extension: `.sas7bdat`)
- `load_xpt()`: Imports XPT files (extension: `.xpt`)

These functions provide error handling, metadata extraction, and return a consistent output format of named lists containing data frames and associated metadata, streamlining the process of importing multiple data files in R.

## Working Example

To illustrate the usage of {dv.loader}, let's explore a hands-on example using the `load_sas()` function to import SAS data. This example serves as a template for working with other file formats, as `load_rds()` and `load_xpt()` functions operate in a similar manner.

```r
# Identify the path to the directory containing the data files
data_dir <- system.file("extdata", "pharmaverseadam", package = "dv.loader")

# Provide the vector of file names to be loaded
file_names <- paste0(c("adsl", "adae"), ".sas7bdat")

# Load SAS data files from the specified directory
dv.loader::load_sas(files = file.path(data_dir, file_names))
```
