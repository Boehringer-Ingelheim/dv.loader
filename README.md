# dv.loader

The `dv.loader` package is designed to simplify the data loading process for creating modular Shiny applications within the DaVinci framework.

Key features of `dv.loader` include:

1. Capability to import multiple files from a data directory.

2. Compatibility with both `.rds` and `.sas7bdat` file types.

3. Smooth integration with other packages in the DaVinci ecosystem.


## Installation

You can install the `dv.loader` package from GitHub using the `remotes` package:

```r
# Install the remotes package if not already installed
if (!require("remotes")) install.packages("remotes")

# Install the dv.loader package from GitHub
remotes::install_github("Boehringer-Ingelheim/dv.loader")
```

## Examples

The `dv.loader` package provides two main functions for loading data:

1. `load_data_files()`: A flexible function that loads multiple data files from any specified file paths, regardless of whether they are in the same directory or not.

2. `load_data()`: A convenience wrapper around `load_data_files()` that simplifies loading multiple files from a single sub-directory of a base path.

### Example 1: `load_data_files()`

```r
# Load data files from the specified file paths
dv.loader::load_data_files(
    file_paths = c("path/to/adsl.sas7bdat", "path/to/adae.sas7bdat")
)
```

### Example 2: `load_data()`

In order to use `load_data()`, you need to set the base path as an environment variable called `RXD_DATA`.

```r
# Load data files from the specified sub-directory of a base path
dv.loader::load_data(
    sub_dir = "sub-directory/of/base-path",
    file_names = c("adsl.sas7bdat", "adae.sas7bdat")
)
```

Additional examples can be found in the package vignettes.
