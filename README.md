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

The main function is `dv.loader::load_data()`, which loads data files from sub-directories of a network file system (NFS) or the working directory.

### Example 1: Sub-directory of Network File System (NFS)

To load data files from a NFS, you need to set the NFS path as an environment variable. By default, the environment variable name is `RXD_DATA`.

You can run the following command to check the NFS path if it is already set.

```r
# Check the NFS path
dv.loader::get_nfs_path()
```

If the NFS path is not set, you can set it by running the following command.

```r
# Set the NFS path as an environment variable
Sys.setenv(RXD_DATA = "path/to/network-file-system")
```

The environment variable setup is not needed if you have already set the NFS path as an environment variable in your `.Renviron` or `.Rprofile` file. 

If the NFS path has been properly set, you can load data files from the NFS and its sub-directories.

```r
# Load data files from the specified sub-directory of a network file system (NFS)
dv.loader::load_data(
    sub_dir = "sub-directory/of/network-file-system",
    file_names = c("adsl.sas7bdat", "adae.sas7bdat")
)
```

For the `file_names` argument, it is recommended to use the full file names including the file extension. 

### Example 2: Sub-directory of the Working Directory

To load data files from a local directory, there is no need to set an environment variable. You use `use_wd = TRUE` to indicate that the data files are loaded from a sub-directory of the working directory.

```r
# Load data files from the specified sub-directory of the working directory
dv.loader::load_data(
    sub_dir = "sub-directory/of/working-directory",
    file_names = c("adsl.sas7bdat", "adae.sas7bdat"),
    use_wd = TRUE
)
```

Additional examples can be found in the package vignettes.
