# dv.loader 2.1.0-9000

- Faster loading of large SAS files from high latency media (e.g. network shares).

# dv.loader 2.1.0

- Added `load_files()` to load data using explicit file paths.

# dv.loader 2.0.0

- GitHub release with QC report
- Update package documentation

# dv.loader 1.1.1

- General package maintenance.

# dv.loader 1.1.0

- Bugfix release that disables problematic dv.loader::load_data file name partial matching.

# dv.loader 1.0.0

First release

# dv.loader 0.5.1 (with breaking changes)

- Major changes before first release
- Changed name of package from "dataloader" to "dv.loader" to avoid CRAN collision
- Changed the `domains` paramater name throughout to `file_names`
- Changed the `study_dir` paramater name throughout to `sub_dir`, because it is used to reference a sub directory of `get_cre_path`.
- Improved tests and test coverage
  - code coverage > 93% and refactored tests to use [BDD](https://testthat.r-lib.org/reference/describe.html)

# dv.loader 0.5.0

- Refactored to take out the OOP design. Now you just use the functions directly without having to create a "dataloader" object.
- Took out "meta" object from the return of `load_data()`. Now, metadata is appended directly to each dataframe as an attribute.
  - E.g., `attr(df, "meta")` to view.

# dv.loader 0.4.1

- package style changed from camelCase to snake_case
- better documentation added with more examples

# dv.loader 0.4.0

- **The API for `dataloader` has changed considerably.** Now there are three public functions:

  - loadData() for bringing data into memory
  - createDB() for creating an SQLite database
    - now creates a new "attr" attributes table containing the column-level attributes
      of the files read keyed on table (domain) name.
  - getTableRefs() for retrieving a list of table references from a DB connection

- **Support for indexing the SQLite DB added.**
  - Pass a list to the "file_names" arg in `createDB()` such that:
    - the elements of the list are domain names
    - the values of the elements are character vectors representing columns that you want indexed
    - check the result in the "sqlite_stat1" metatable retrieved from `getTableRefs()`

# dv.loader 0.3.1

- If you specify `useDB = T` and there's an existing database file,
  then `load_data()` will connect to it, and return its tables.

- `load_data()` will check for an existing DB based on the users
  input for `dbFileName`. If that is left `NULL`, then it will use the
  default name based on `studyDir`, and if that is `NULL`, then it will
  use `db`. Otherwise, it will just create a new database (if `useDB = T`).

- The API to `read_file()` has changed. No longer need to specify `isRDS`.
  The function will figure that out based on the `file_name` passed in.

# dv.loader 0.3.0

- `data.loader` is now called `dataloader`

- `dataloader`’s local DB functionality is now passing unit tests,
  meaning that the integrity of data flow from the producing system
  (CARE) is ensured.

- The output of `load_data()` for databases includes attributes from the
  original file. So, even if those attributes are lost when the data is
  loaded into the database, you can recover them. Here is how to recover
  for a given column and dataframe:

<!-- -->

    attr <- dataList[["attr"]]
    attr_adsl <- attr["adlb"]
    attr_adsl_studyid <- attr[["adlb"]][["STUDYID"]]
    attr_adsl_studyid
    # $label
    # [1] "Study Identifier"
    #
    # $format.sas
    # [1] "$"

- `load_data()` by default returns a list named by the file_names passed,
  and containing a dataframes, along with metadata for that
  table.

- Create a DB table connection (created with dplyr::tbl(dl$dbConn, “myDomain”))
  by using `useDB = T` in `load_data()`.

- `set_base_path()` has been removed, and the `base_path` attribute is
  now private so as to restrict where on CARE this module can access.

- the only arg that is mandatory is `file_names`. If `studyDir` is left
  as null, then it just uses working directory as default.

# dv.loader 0.2.1

- `data.loader` now supports the creation of local SQL databases for
  managing very large files. Users should interact with the `db_conn`
  connection using the DBI package, found on CRAN. Usage is detailed
  below in the benchmarking section. Also, internally, the
  `load_data()` function has been refactored to separate out the
  importing of data from the creation of the local database.

- This dv.loader also fixes a bug where if a user did not provide a “/”
  in front of the `studyDir` arg, then it wouldn’t be able to find
  the right path.

- `isLocal` in the `load_data()` API has been replaced with `useWD`
  (for “use working directory”) to make more sense.

- A flag for prefering SAS files over RDS files has been added to
  `load_data()`

# dv.loader 0.2.0

- `data.loader` is now an R6 class for internal scoping of
  `base_path`. This way, users can change the “working directory” of
  the data loader module without affecting the working directory of
  their global environment. A new function is available called
  `set_base_path()` for this purpose. See usage below for how to
  create a “dataloader” object. Otherwise, usage is the same as in
  V0.1.0.

# dv.loader 0.1.0

- Initial commit. `data.loader` has the functions
  `load_data(studyDir, file_names)` and `set_base_path()`.
