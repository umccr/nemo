#' @title Tool1 Object
#'
#' @description
#' Parses and tidies output files from Tool1. Table schemas and file patterns
#' are defined in `inst/config/tools/tool1/schema.yaml`. Custom parse and tidy
#' methods are provided for tables that require non-standard handling.
#'
#' @examples
#' indir <- system.file("extdata/tool1", package = "nemo")
#' dir1 <- tempdir()
#' obj1 <- Tool1$new(indir)
#'
#' p3 <- system.file("extdata/tool1/latest/sampleA.tool1.table3.tsv", package = "nemo")
#' (tidy3 <- obj1$tidy_table3(p3))
#'
#' obj1$run(output_dir = dir1, format = "parquet", input_id = "run1")
#' (lf <- list.files(dir1, pattern = "tool1.*parquet", full.names = FALSE))
#'
#' obj2 <- Tool1$new(indir)$tidy()
#' @export
Tool1 <- R6::R6Class(
  "Tool1",
  cloneable = FALSE,
  inherit = Tool,
  public = list(
    #' @description Create a new Tool1 object.
    #' @param path (`character(1)`)\cr
    #' Output directory of tool. If `files_tbl` is supplied, this is ignored.
    #' @param files_tbl (`tibble(n)`)\cr
    #' Tibble of files from [list_files_dir()].
    #' @return (`R6::R6Class()`)\cr
    #' R6 object.
    initialize = function(path = NULL, files_tbl = NULL) {
      super$initialize(name = "tool1", pkg = "nemo", path = path, files_tbl = files_tbl)
    },
    #' @description Tidy `table3.tsv` file with type conversion enabled.
    #' @param x (`character(1)` or `tibble()`)\cr
    #' Path to file or already parsed tibble.
    #' @return (`tibble()`)\cr
    #' Tidy data in enframed tibble.
    tidy_table3 = function(x) {
      private$tidy_file(x, "table3", convert_types = TRUE)
    }
  )
)
