# Data Loading Module

[![Checks 🧩](https://github.com/Boehringer-Ingelheim/dv.loader/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Boehringer-Ingelheim/dv.loader/actions/workflows/ci.yml)

## Installation

```r
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("Boehringer-Ingelheim/dv.loader")
```

## Basic usage

**Note**: `dv.loader` is only designed to be used with `.RDS` and `.sas7bdat` file formats.

```r
# getting data from a network file storage folder
dv.loader::load_data(sub_dir = "subdir1/subdir2", file_names = c("adsl", "adae"))
```

```r
# getting data locally (e.g., if you have file `./data/adsl.RDS`)
dv.loader::load_data(sub_dir = "data", file_names = c("adsl"), use_wd = T)
```

## Contact

If you have edits or suggestions, please open a PR.
