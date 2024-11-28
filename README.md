# Data Loading

The `dv.loader` package provides two functions for loading `.rds` and `.sas7bdat` files into R.

- `load_data()`: loads data files from a specified subdirectory of the base path defined by the environment variable "RXD_DATA". This function is useful when working with data files stored in a centralized location.
- `load_files()`: accepts explicit file paths to load data files from any location on your system. You can optionally provide custom names for the data frames in the returned list.

## Installation

The `dv.loader` package is available on GitHub. To install it, you can use the following commands:

```r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("Boehringer-Ingelheim/dv.loader")
```

After installation, you can load the package using:

```r
library(dv.loader)
```

## Basic Usage

### Using `load_data()`

The `load_data()` function loads data from the specified subdirectory relative to `RXD_DATA`. For the `file_names` argument, you can optionally specify the file extensions in the names. If not provided, the function will attempt to search for `.rds` and `.sas7bdat` files in the subdirectory and decide which one to load based on the `prefer_sas` argument when both file types are present. By default, `prefer_sas` is `FALSE`, meaning `.rds` files are preferred due to their smaller file size and faster loading time.

```r
# Set the RXD_DATA environment variable
Sys.setenv(RXD_DATA = "path/to/data/folder")

# Load data from path/to/data/folder/subdir1
load_data(
    sub_dir = "subdir1",
    file_names = c("file1", "file2"),
    prefer_sas = TRUE
)

# Load data from path/to/data/folder/subdir1/subdir2
load_data(
    sub_dir = "subdir1/subdir2",
    file_names = c("file1.rds", "file2.sas7bdat"),
)
```

### Using `load_files()`

The `load_files()` function requires you to provide explicit file paths including the file extensions for the data files you want to load. You can optionally provide custom names for the data frames in the returned list.


```r
# Load data files with default names
load_files(
    file_paths = c(
        "path/to/file1.rds",
        "path/to/file2.sas7bdat"
    )
)

# Load data files with custom names
load_files(
    file_paths = c(
        "file1 (rds)" = "path/to/file1.rds",
        "file2 (sas)" = "path/to/file2.sas7bdat"
    )
)
```

For more details, please refer to the package vignettes and function documentation.
