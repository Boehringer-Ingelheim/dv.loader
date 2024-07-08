# Data Loading

The {dv.loader} package provides a simple interface for loading data from a network file storage folder or 
locally. It is designed to be used with `.RDS` and `.sas7bdat` file formats.
The package provides a simple function, `load_data()`, which loads R and SAS data files into memory. 
Loading data from SQL databases is not yet supported. The function returns a list named by the file names passed, 
and containing data frames, along with metadata for that table. By default, the function will look for files in a
sub-directory `sub_dir` of the base path defined by a environment variable "RXD_DATA". You can check if the base path
is set by running `Sys.getenv("RXD_DATA")`. A single file or multiple files can be loaded at once. 
To make the loading process faster for large datasets, it is suggested that '.sas7bdat' files are converted to 
'.RDS' files. The function will prefer '.RDS' files over '.sas7bdat' files by default.

## Installation

```r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("Boehringer-Ingelheim/dv.loader")
```

## Basic usage

```r
# getting data from a network file storage folder
dv.loader::load_data(sub_dir = "subdir1/subdir2", file_names = c("adsl", "adae"))
```

```r
# getting data locally (e.g., if you have file `./data/adsl.RDS`)
dv.loader::load_data(sub_dir = "data", file_names = c("adsl"), use_wd = TRUE)
```
