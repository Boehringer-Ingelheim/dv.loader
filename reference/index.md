# Package index

## Main functions

- [`load_data()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_data.md)
  : Loads data into memory based on study directory and one or more file
  names
- [`load_files()`](https://boehringer-ingelheim.github.io/dv.loader/reference/load_files.md)
  : Load data files from explicit paths

## Helper functions

- [`collect_data_list_paths()`](https://boehringer-ingelheim.github.io/dv.loader/reference/collect_data_list_paths.md)
  : Collect file paths based on file names without extensions

- [`get_nfs_path()`](https://boehringer-ingelheim.github.io/dv.loader/reference/get_nfs_path.md)
  : gets the NFS base path from an env var It assumes there is an env
  var called RXD_DATA which holds the path suffix.

- [`get_cre_path()`](https://boehringer-ingelheim.github.io/dv.loader/reference/get_cre_path.md)
  : gets the NFS base path from an env var alias for get_nfs_path to
  maintain backwards compatibility

- [`reduce_column_memory_footprint()`](https://boehringer-ingelheim.github.io/dv.loader/reference/reduce_column_memory_footprint.md)
  : Transform data.frame column to use leaner types

- [`memory_use_report()`](https://boehringer-ingelheim.github.io/dv.loader/reference/memory_use_report.md)
  :

  Print data remapping report of the transformations performed by
  `reduce_data_frame_memory_footprint`
