#' @title Tool1 Object
#'
#' @description
#' Tool1 file parsing and manipulation.
#' @examples
#' cls <- Tool1
#' indir <- system.file("extdata/tool1", package = "nemo")
#' odir <- tempdir()
#' id <- "tool1_run1"
#' obj <- cls$new(indir)
#' obj$nemofy(odir = odir, format = "parquet", id = id)
#' list.files(odir, pattern = "parquet", full.names = FALSE)
#' @export
Tool1 <- R6::R6Class(
  "Tool1",
  inherit = Tool,
  public = list(
    #' @description Create a new Tool1 object.
    #' @param path (`character(1)`)\cr
    #' Output directory of tool. If `files_tbl` is supplied, this basically gets
    #' ignored.
    #' @param files_tbl (`tibble(n)`)\cr
    #' Tibble of files from [list_files_dir()].
    initialize = function(path = NULL, files_tbl = NULL) {
      super$initialize(name = "tool1", pkg = "nemo", path = path, files_tbl = files_tbl)
    },
    #' @description Read `table1.tsv` file.
    #' @param x (`character(1)`)\cr
    #' Path to file.
    parse_table1 = function(x) {
      self$.parse_file(x, "table1")
    },
    #' @description Tidy `table1.tsv` file.
    #' @param x (`character(1)`)\cr
    #' Path to file.
    tidy_table1 = function(x) {
      self$.tidy_file(x, "table1")
    },
    #' @description Read `table2.tsv` file.
    #' @param x (`character(1)`)\cr
    #' Path to file.
    parse_table2 = function(x) {
      self$.parse_file(x, "table2")
    },
    #' @description Tidy `table2.tsv` file.
    #' @param x (`character(1)`)\cr
    #' Path to file.
    tidy_table2 = function(x) {
      self$.tidy_file(x, "table2")
    }
  )
)
