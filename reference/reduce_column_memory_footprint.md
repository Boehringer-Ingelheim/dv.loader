# Transform data.frame column to use leaner types

Transforms a character column into a factor or a numeric column into
integer, when the transformation does not lead to loss of precision.

## Usage

``` r
reduce_column_memory_footprint(col_data)
```

## Arguments

- col_data:

  Vector to transform

## Value

Transformed vector
