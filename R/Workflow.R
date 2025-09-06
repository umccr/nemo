#' @title Workflow Object
#'
#' @description
#' A Workflow is composed of multiple Tools.
#' @examples
#' path <- system.file("extdata/tool1", package = "nemo")
#' tools <- list(tool1 = Tool1)
#' wf1 <- Workflow$new(name = "foo", path = path, tools = tools)
#' odir <- tempdir()
#' wf1$list_files()
#' wf1$nemofy(odir = odir, format = "parquet", id = "run1")
#' (lf <- list.files(odir, pattern = "tool1.*parquet", full.names = FALSE))
#' #dbconn <- DBI::dbConnect(drv = RPostgres::Postgres(), dbname = "nemo", user = "orcabus")
#' #wf1$nemofy(format = "db", id = "runABC", dbconn = dbconn)
#' @testexamples
#' expect_equal(length(lf), 4)
#'
#' @export
Workflow <- R6::R6Class(
  "Workflow",
  public = list(
    #' @field name (`character(1)`)\cr
    #' Name of workflow.
    name = NULL,
    #' @field path (`character(n)`)\cr
    #' Path(s) to workflow results.
    path = NULL,
    #' @field tools (`list(n)`)\cr
    #' List of Tools that compose a Workflow.
    tools = NULL,
    #' @field files_tbl (`tibble(n)`)\cr
    #' Tibble of files from [list_files_dir()].
    files_tbl = NULL,

    #' @description Create a new Workflow object.
    #' @param name (`character(1)`)\cr
    #' Name of workflow.
    #' @param path (`character(n)`)\cr
    #' Path(s) to workflow results.
    #' @param tools (`list(n)`)\cr
    #' List of Tools that compose a Workflow.
    initialize = function(name = NULL, path = NULL, tools = NULL) {
      self$name <- name
      private$validate_tools(tools)
      self$path <- normalizePath(path)
      self$files_tbl <- list_files_dir(self$path)
      # handle everything in a list of Tools
      self$tools <- tools |>
        purrr::map(\(x) x$new(files_tbl = self$files_tbl))
    },
    #' @description Print details about the File.
    #' @param ... (ignored).
    print = function(...) {
      # fmt: skip
      res <- tibble::tribble(
        ~var, ~value,
        "name", self$name,
        "path", glue::glue_collapse(self$path, sep = ", "),
        "ntools", as.character(length(self$tools))
      )
      cat("#--- Workflow ---#\n")
      print(res)
      invisible(self)
    },
    #' @description Filter files in given workflow directory.
    #' @param include (`character(n)`)\cr
    #' Files to include.
    #' @param exclude (`character(n)`)\cr
    #' Files to exclude.
    filter_files = function(include = NULL, exclude = NULL) {
      self$tools <- self$tools |>
        purrr::map(\(x) x$filter_files(include = include, exclude = exclude))
      invisible(self)
    },
    #' @description List files in given workflow directory.
    #' @param type (`character(1)`)\cr
    #' File types(s) to return (e.g. any, file, directory, symlink).
    #' See `fs::dir_info`.
    #' @return A tibble with all files found for each Tool.
    list_files = function(type = c("file", "symlink")) {
      self$tools |>
        purrr::map(\(x) x$list_files(type = type)) |>
        dplyr::bind_rows()
    },
    #' @description Tidy Workflow files.
    #' @param tidy (`logical(1)`)\cr
    #' Should the raw parsed tibbles get tidied?
    #' @param keep_raw (`logical(1)`)\cr
    #' Should the raw parsed tibbles be kept in the final output?
    #' @return self invisibly.
    tidy = function(tidy = TRUE, keep_raw = FALSE) {
      self$tools <- self$tools |>
        purrr::map(\(x) x$tidy(tidy = tidy, keep_raw = keep_raw))
      invisible(self)
    },
    #' @description Write tidy tibbles.
    #' @param odir (`character(1)`)\cr
    #' Directory path to output tidy files.
    #' @param format (`character(1)`)\cr
    #' Format of output files.
    #' @param id (`character(1)`)\cr
    #' ID to use for the dataset (e.g. `wfrid.123`, `prid.456`).
    #' @param dbconn (`DBIConnection`)\cr
    #' Database connection object (see `DBI::dbConnect`).
    #' @return A tibble with the tidy data and their output location prefix.
    write = function(odir = ".", format = "tsv", id = NULL, dbconn = NULL) {
      self$tools |>
        purrr::map(\(x) x$write(odir = odir, format = format, id = id, dbconn = dbconn)) |>
        dplyr::bind_rows()
    },
    #' @description Parse, filter, tidy and write files.
    #' @param odir (`character(1)`)\cr
    #' Directory path to output tidy files.
    #' @param format (`character(1)`)\cr
    #' Format of output files.
    #' @param id (`character(1)`)\cr
    #' ID to use for the dataset (e.g. `wfrid.123`, `prid.456`).
    #' @param dbconn (`DBIConnection`)\cr
    #' Database connection object (see `DBI::dbConnect`).
    #' @param include (`character(n)`)\cr
    #' Files to include.
    #' @param exclude (`character(n)`)\cr
    #' Files to exclude.
    #' @return A tibble with the tidy data and their output location prefix.
    nemofy = function(
      odir = ".",
      format = "tsv",
      id = NULL,
      dbconn = NULL,
      include = NULL,
      exclude = NULL
    ) {
      # fmt: skip
      self$
        filter_files(include = include, exclude = exclude)$
        tidy()$
        write(odir = odir, format = format, id = id, dbconn = dbconn)
    },
    #' @description Get raw schemas for all Tools.
    #' @return Tibble with names of tool and file, schema and its version.
    get_raw_schemas_all = function() {
      self$tools |>
        purrr::map(\(x) {
          x$raw_schemas_all |>
            dplyr::mutate(tool = x$name) |>
            dplyr::relocate("tool", .before = 1)
        }) |>
        dplyr::bind_rows()
    },
    #' @description Get tidy schemas for all Tools.
    #' @return Tibble with names of tool and tbl, schema and its version.
    get_tidy_schemas_all = function() {
      self$tools |>
        purrr::map(\(x) {
          x$tidy_schemas_all |>
            dplyr::mutate(tool = x$name) |>
            dplyr::relocate("tool", .before = 1)
        }) |>
        dplyr::bind_rows()
    },
    #' @description Get tidy tbls for all Tools.
    #' @return Tibble with tidy tbls of all Tools.
    get_tbls = function() {
      self$tools |>
        purrr::map(\(x) x$tbls) |>
        dplyr::bind_rows()
    }
  ), # public end
  private = list(
    validate_tools = function(x) {
      stopifnot(rlang::is_bare_list(x))
      stopifnot(all(purrr::map_lgl(x, R6::is.R6Class)))
      tool_nms <- purrr::map_chr(x, "classname") |> tolower()
      stopifnot(!is.null(tool_nms))
      stopifnot(all(purrr::map(x, "inherit") == as.symbol("Tool")))
    }
  ) # private end
)
