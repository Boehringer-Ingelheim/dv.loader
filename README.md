# Data Loading

The `dv.loader` package provides functionality for loading `.rds` and `.sas7bdat` data files into R. It offers two main functions:

- `load_data()`: A legacy function that loads data files from a specified subdirectory of the base path defined by the environment variable "RXD_DATA".
- `load_files()`: A newer function that provides more flexibility by accepting file paths directly and supports custom names for the returned data list.

NOTE: The `load_files()` function is recommended for its enhanced capabilities and flexibility.

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

### Using `load_files()`

Load data files with default names:

```r
load_files(
    file_paths = c(
        "path/to/file1.rds",
        "path/to/file2.sas7bdat"
    )
)
```

Load data files with custom names:

```r
load_files(
    file_paths = c(
        "file1 (rds)" = "path/to/file1.rds",
        "file2 (sas)" = "path/to/file2.sas7bdat"
    )
)
```

### Using `load_data()`

Set the `RXD_DATA` environment variable:

```r
Sys.setenv(RXD_DATA = "path/to/data/folder")
```

Load data from the specified subdirectory relative to `RXD_DATA`:

```r
# path/to/data/folder/subdir1
load_data(
    sub_dir = "subdir1",
    file_names = c("file1", "file2")
)

# path/to/data/folder/subdir1/subdir2
load_data(
    sub_dir = "subdir1/subdir2",
    file_names = c("file1", "file2")
)
```

For more details, please refer to the package vignettes and function documentation.
