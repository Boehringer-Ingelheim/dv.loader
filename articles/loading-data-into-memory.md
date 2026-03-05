# Loading Data into Memory

The `dv.loader` package simplifies the process of loading data files
into R memory. It provides two main functions -
[`load_data()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_data.md)
and
[`load_files()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_files.md) -
that can handle two widely used data formats:

- `.rds` files: R’s native data storage format, which efficiently stores
  R objects in a compressed binary format
- `.sas7bdat` files: SAS dataset files commonly used in clinical
  research and other industries

The package is designed to be flexible, allowing you to load data either
from a centralized location using environment variables, or by
specifying explicit file paths. Each loaded dataset includes metadata
about the source file, such as its size, modification time, and location
on disk.

To demonstrate the package’s capabilities, we’ll first create some
example `.rds` files in a temporary directory that we can work with.

``` r

# Create a temporary directory for the example data
temp_dir <- tempdir()

# Save the cars and mtcars datasets to the temporary directory
saveRDS(cars, file = file.path(temp_dir, "cars.rds"))
saveRDS(mtcars, file = file.path(temp_dir, "mtcars.rds"))
```

To begin, we’ll need to load the dv.loader package.

``` r

library(dv.loader)
```

## Using `load_data()`

The
[`load_data()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_data.md)
function requires the `RXD_DATA` environment variable to be set to the
base directory containing your data files. This variable defines the
root path from which subdirectories will be searched.

When you call
[`load_data()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_data.md),
it searches the specified subdirectory for data files and returns them
as a named list of data frames. Each data frame in the list is named
after its source file.

For files that exist in both `.rds` and `.sas7bdat` formats,
[`load_data()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_data.md)
will load the `.rds` version by default since these are more compact and
faster to read. You can override this behavior by setting
`prefer_sas = TRUE` to prioritize loading `.sas7bdat` files instead.

``` r

# Set the RXD_DATA environment variable to the temporary directory
Sys.setenv(RXD_DATA = temp_dir)

# Load the data files into a named list of data frames
data_list1 <- load_data(
  sub_dir = ".",
  file_names = c("cars", "mtcars")
)

# Display the structure of the resulting list
str(data_list1)
#> List of 2
#>  $ cars  :'data.frame':  50 obs. of  2 variables:
#>   ..$ speed: int [1:50] 4 4 7 7 8 9 10 10 10 11 ...
#>   ..$ dist : int [1:50] 2 10 4 22 16 10 18 26 34 17 ...
#>   ..- attr(*, "meta")='data.frame':  1 obs. of  11 variables:
#>   .. ..$ size                              : num 289
#>   .. ..$ isdir                             : logi FALSE
#>   .. ..$ mode                              : 'octmode' int 644
#>   .. ..$ mtime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ ctime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ atime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ path                              : chr "/tmp/RtmpF6A3bo/./cars.rds"
#>   .. ..$ file_name                         : chr "cars.rds"
#>   .. ..$ original_memory_footprint_in_bytes: num 1648
#>   .. ..$ remapped_column_indices           :List of 1
#>   .. .. ..$ : int [1:2] 1 2
#>   .. ..$ remapping_time                    : 'difftime' num 0.000194311141967773
#>   .. .. ..- attr(*, "units")= chr "secs"
#>  $ mtcars:'data.frame':  32 obs. of  11 variables:
#>   ..$ mpg : num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
#>   ..$ cyl : int [1:32] 6 6 4 6 8 6 8 4 4 6 ...
#>   ..$ disp: num [1:32] 160 160 108 258 360 ...
#>   ..$ hp  : int [1:32] 110 110 93 110 175 105 245 62 95 123 ...
#>   ..$ drat: num [1:32] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
#>   ..$ wt  : num [1:32] 2.62 2.88 2.32 3.21 3.44 ...
#>   ..$ qsec: num [1:32] 16.5 17 18.6 19.4 17 ...
#>   ..$ vs  : int [1:32] 0 0 1 1 0 1 0 1 1 1 ...
#>   ..$ am  : int [1:32] 1 1 1 0 0 0 0 0 0 0 ...
#>   ..$ gear: int [1:32] 4 4 4 3 3 3 3 4 4 4 ...
#>   ..$ carb: int [1:32] 4 4 1 1 2 1 4 2 2 4 ...
#>   ..- attr(*, "meta")='data.frame':  1 obs. of  11 variables:
#>   .. ..$ size                              : num 1225
#>   .. ..$ isdir                             : logi FALSE
#>   .. ..$ mode                              : 'octmode' int 644
#>   .. ..$ mtime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ ctime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ atime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ path                              : chr "/tmp/RtmpF6A3bo/./mtcars.rds"
#>   .. ..$ file_name                         : chr "mtcars.rds"
#>   .. ..$ original_memory_footprint_in_bytes: num 7208
#>   .. ..$ remapped_column_indices           :List of 1
#>   .. .. ..$ : int [1:6] 2 4 8 9 10 11
#>   .. ..$ remapping_time                    : 'difftime' num 0.000293731689453125
#>   .. .. ..- attr(*, "units")= chr "secs"
```

## Using `load_files()`

The
[`load_files()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_files.md)
function accepts explicit file paths and loads them into a named list of
data frames. Each data frame includes metadata as an attribute. If no
custom names are provided, the function will use the file names (without
paths or extensions) as the list names.

``` r

# Load the data files into a named list of data frames
data_list2 <- load_files(
  file_paths = c(
    file.path(temp_dir, "cars.rds"),
    file.path(temp_dir, "mtcars.rds")
  )
)

# Display the structure of the resulting list
str(data_list2)
#> List of 2
#>  $ cars  :'data.frame':  50 obs. of  2 variables:
#>   ..$ speed: int [1:50] 4 4 7 7 8 9 10 10 10 11 ...
#>   ..$ dist : int [1:50] 2 10 4 22 16 10 18 26 34 17 ...
#>   ..- attr(*, "meta")='data.frame':  1 obs. of  11 variables:
#>   .. ..$ size                              : num 289
#>   .. ..$ isdir                             : logi FALSE
#>   .. ..$ mode                              : 'octmode' int 644
#>   .. ..$ mtime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ ctime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ atime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ path                              : chr "/tmp/RtmpF6A3bo/cars.rds"
#>   .. ..$ file_name                         : chr "cars.rds"
#>   .. ..$ original_memory_footprint_in_bytes: num 1648
#>   .. ..$ remapped_column_indices           :List of 1
#>   .. .. ..$ : int [1:2] 1 2
#>   .. ..$ remapping_time                    : 'difftime' num 0.000106573104858398
#>   .. .. ..- attr(*, "units")= chr "secs"
#>  $ mtcars:'data.frame':  32 obs. of  11 variables:
#>   ..$ mpg : num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
#>   ..$ cyl : int [1:32] 6 6 4 6 8 6 8 4 4 6 ...
#>   ..$ disp: num [1:32] 160 160 108 258 360 ...
#>   ..$ hp  : int [1:32] 110 110 93 110 175 105 245 62 95 123 ...
#>   ..$ drat: num [1:32] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
#>   ..$ wt  : num [1:32] 2.62 2.88 2.32 3.21 3.44 ...
#>   ..$ qsec: num [1:32] 16.5 17 18.6 19.4 17 ...
#>   ..$ vs  : int [1:32] 0 0 1 1 0 1 0 1 1 1 ...
#>   ..$ am  : int [1:32] 1 1 1 0 0 0 0 0 0 0 ...
#>   ..$ gear: int [1:32] 4 4 4 3 3 3 3 4 4 4 ...
#>   ..$ carb: int [1:32] 4 4 1 1 2 1 4 2 2 4 ...
#>   ..- attr(*, "meta")='data.frame':  1 obs. of  11 variables:
#>   .. ..$ size                              : num 1225
#>   .. ..$ isdir                             : logi FALSE
#>   .. ..$ mode                              : 'octmode' int 644
#>   .. ..$ mtime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ ctime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ atime                             : POSIXct[1:1], format: "2026-03-05 15:10:23"
#>   .. ..$ path                              : chr "/tmp/RtmpF6A3bo/mtcars.rds"
#>   .. ..$ file_name                         : chr "mtcars.rds"
#>   .. ..$ original_memory_footprint_in_bytes: num 7208
#>   .. ..$ remapped_column_indices           :List of 1
#>   .. .. ..$ : int [1:6] 2 4 8 9 10 11
#>   .. ..$ remapping_time                    : 'difftime' num 0.000264883041381836
#>   .. .. ..- attr(*, "units")= chr "secs"
```

When using
[`load_files()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_files.md),
you can specify files from multiple directories and customize the output
list names by providing named arguments in the `file_paths` parameter.

``` r

dv.loader::load_files(
  file_paths = c(
    "cars (rds)" = file.path(temp_dir, "cars.rds"),
    "iris (sas)" = system.file("examples", "iris.sas7bdat", package = "haven")
  )
) |> names()
#> [1] "cars (rds)" "iris (sas)"
```
