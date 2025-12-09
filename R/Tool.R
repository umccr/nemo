#' @title Tool Object
#'
#' @description
#' Base class for all nemo tools.
#' @examples
#' \dontrun{
#' path <- here::here("inst/extdata/tool1")
#' x <- Tool$new("tool1", pkg = "nemo", path = path)
#' # demo filter + tidy
#' x <- Tool1$new(path = path)$
#'   filter_files(exclude = "alignments_dupfreq")$
#'   tidy(keep_raw = TRUE)
#' a$tbls
#' a$files
#' a$list_files()
#' lx <- Linx$new(path)
#' dbconn <- DBI::dbConnect(
#'   drv = RPostgres::Postgres(),
#'   dbname = "nemo",
#'   user = "orcabus"
#' )
#' lx$nemofy(
#'     odir = "nogit/test_data",
#'     format = "db", # "parquet",
#'     id = "run2",
#'     dbconn = dbconn,
#'     include = NULL,
#'     exclude = NULL
#' )
#' DBI::dbDisconnect(dbconn)
#' }
#'
#' @export
Tool <- R6::R6Class(
  "Tool",
  private = list(
    # Do files need to be tidied? Used when no files are detected, so we can
    # use downstream as a bypass.
    needs_tidying = NULL
  ),
  public = list(
    #' @field name (`character(1)`)\cr
    #' Name of tool.
    name = NULL,
    #' @field path  (`character(1)`)\cr
    #' Output directory of tool.
    path = NULL,
    #' @field config (`Config()`)\cr
    #' Config of tool.
    config = NULL,
    #' @field files (`tibble()`)\cr
    #' Tibble of files matching available Tool patterns.
    files = NULL,
    #' @field tbls (`tibble()`)\cr
    #' Tibble of tidy tibbles.
    tbls = NULL,
    #' @field raw_schemas_all (`tibble()`)\cr
    #' All raw schemas for tool.
    raw_schemas_all = NULL,
    #' @field tidy_schemas_all (`tibble()`)\cr
    #' All tidy schemas for tool.
    tidy_schemas_all = NULL,
    #' @field get_tidy_schema (`function()`)\cr
    #' Get specific tidy schema.
    get_tidy_schema = NULL,
    #' @field get_raw_schema (`function()`)\cr
    #' Get specific raw schema.
    get_raw_schema = NULL,
    #' @field files_tbl (`tibble(n)`)\cr
    #' Tibble of files from [list_files_dir()].
    files_tbl = NULL,

    #' @description Create a new Tool object.
    #' @param name (`character(1)`)\cr
    #' Name of tool.
    #' @param pkg (`character(1)`)\cr
    #' Package name tool belong to (for config lookup).
    #' @param path (`character(1)`)\cr
    #' Output directory of tool. If `files_tbl` is supplied, this basically gets
    #' ignored.
    #' @param files_tbl (`tibble(n)`)\cr
    #' Tibble of files from [list_files_dir()].
    initialize = function(name = NULL, pkg = NULL, path = NULL, files_tbl = NULL) {
      stopifnot(
        !is.null(path) || !is.null(files_tbl),
        !is.null(name),
        !is.null(pkg)
      )
      if (!is.null(files_tbl)) {
        stopifnot(is_files_tbl(files_tbl))
        if (!is.null(path)) {
          # gets ignored if files_tbl is specified
          path <- NULL
        }
      }
      self$name <- name
      self$path <- path
      self$config <- Config$new(self$name, pkg = pkg)
      self$raw_schemas_all <- self$config$raw_schemas_all
      self$tidy_schemas_all <- self$config$tidy_schemas_all
      self$get_tidy_schema <- self$config$get_tidy_schema
      self$get_raw_schema <- self$config$get_raw_schema
      self$files_tbl <- files_tbl
      private$needs_tidying <- TRUE
      # upon init, files starts off as the raw list of files
      self$files <- self$list_files(type = "file")
    },
    #' @description Print details about the Tool.
    #' @param ... (ignored).
    #' @return self invisibly.
    print = function(...) {
      res <- tibble::tribble(
        ~var     , ~value                               ,
        "name"   , self$name                            ,
        "path"   , self$path %||% "<ignored>"           ,
        "files"  , as.character(nrow(self$files))       ,
        "tidied" , as.character(!private$needs_tidying)
      ) |>
        tidyr::unnest("value")
      cat(glue("#--- Tool {self$name} ---#"))
      print(knitr::kable(res))
      invisible(self)
    },
    #' @description Filter files in given tool directory.
    #' @param include (`character(n)`)\cr
    #' Files to include.
    #' @param exclude (`character(n)`)\cr
    #' Files to exclude.
    #' @return The tibble of files with potentially removed rows.
    filter_files = function(include = NULL, exclude = NULL) {
      f1 <- function(d, include = NULL, exclude = NULL) {
        assertthat::assert_that(
          is.null(include) || is.null(exclude),
          msg = "You cannot define both include and exclude!"
        )
        if (!is.null(include)) {
          stopifnot(rlang::is_character(include))
          d <- d |>
            dplyr::filter(.data$tool_parser %in% include)
        }
        if (!is.null(exclude)) {
          stopifnot(rlang::is_character(exclude))
          d <- d |>
            dplyr::filter(!.data$tool_parser %in% exclude)
        }
        d
      }
      if (nrow(self$files) == 0) {
        return(invisible(self))
      }
      self$files <- self$files |>
        f1(include = include, exclude = exclude)
      return(invisible(self))
    },
    #' @description List files in given tool directory.
    #' @param type (`character(1)`)\cr
    #' File type(s) to return (e.g. any, file, directory, symlink).
    #' See `fs::dir_info`.
    #' @return A tibble of file paths.
    list_files = function(type = "file") {
      files_tbl <- self$files_tbl
      stopifnot(!is.null(self$path) || !is.null(files_tbl))
      if (!is.null(files_tbl)) {
        stopifnot(is_files_tbl(files_tbl))
      }
      patterns <- self$config$get_raw_patterns() |>
        dplyr::rename(pat_name = "name", pat_value = "value")
      files <- files_tbl %||% list_files_dir(self$path, type = type)
      res <- files |>
        tidyr::crossing(patterns) |>
        dplyr::filter(stringr::str_detect(.data$bname, .data$pat_value)) |>
        dplyr::select(
          parser = "pat_name",
          "bname",
          "size",
          "lastmodified",
          "path",
          pattern = "pat_value"
        )
      if (nrow(res) == 0) {
        return(res)
      }
      res |>
        dplyr::mutate(
          prefix = stringr::str_replace(.data$bname, glue("(.*){.data$pattern}"), "\\1"),
          # handle wigits version files
          prefix = dplyr::if_else(
            .data$parser == "version" & .data$prefix == "",
            "version",
            .data$prefix
          ),
          tool_parser = glue("{self$name}_{.data$parser}")
        ) |>
        dplyr::mutate(group = dplyr::row_number(), .by = "bname") |>
        dplyr::mutate(
          group = dplyr::if_else(.data$group == 1, glue(""), glue("_{.data$group}")),
          prefix = glue("{.data$prefix}{.data$group}")
        ) |>
        dplyr::relocate("tool_parser", .before = 1)
    },
    #' @description Parse file.
    #' @param x (`character(1)`)\cr
    #' File path.
    #' @param name (`character(1)`)\cr
    #' Parser name (e.g. "breakends" - see docs).
    #' @param delim (`character(1)`)\cr
    #' File delimiter.
    #' @param ... Passed on to `readr::read_delim`.
    #' @return A tibble with the parsed data.
    .parse_file = function(x, name, delim = "\t", ...) {
      parse_file(
        fpath = x,
        pname = name,
        schemas_all = self$raw_schemas_all,
        delim = delim,
        ...
      )
    },
    #' @description Tidy file.
    #' @param x (`character(1)` or `tibble()`)\cr
    #' File path or already parsed raw tibble.
    #' @param name (`character(1)`)\cr
    #' Parser name (e.g. "breakends" - see docs).
    #' @param convert_types (`logical(1)`)\cr
    #' Convert field types based on schema.
    #' @return A tibble with the tidy data enframed.
    .tidy_file = function(x, name, convert_types = FALSE) {
      if (!tibble::is_tibble(x)) {
        .parser <- self$.eval_func(glue("parse_{name}"))
        x <- .parser(x)
      }
      version <- get_tbl_version_attr(x)
      stopifnot(!is.null(version))
      schema <- self$get_tidy_schema(name, v = version)
      colnames(x) <- schema[["field"]]
      if (convert_types) {
        ctypes <- schema |>
          dplyr::select("field", "type") |>
          tibble::deframe()
        x <- readr::type_convert(
          x,
          col_types = rlang::exec(readr::cols, !!!ctypes)
        )
      }
      list(x) |>
        setNames(name) |>
        enframe_data()
    },
    #' @description Parse files with no header and two columns representing
    #' key-value pairs.
    #' @param x (`character(1)`)\cr
    #' File path.
    #' @param name (`character(1)`)\cr
    #' Parser name (e.g. "qc" - see docs).
    #' @param delim (`character(1)`)\cr
    #' File delimiter.
    #' @param ... Passed on to `readr::read_delim`.
    #' @return A tibble with the parsed data.
    .parse_file_keyvalue = function(x, name, delim = "\t", ...) {
      parse_file_keyvalue(
        fpath = x,
        pname = name,
        schemas_all = self$raw_schemas_all,
        delim = delim,
        ...
      )
    },
    #' @description Parse headless file.
    #' @param x (`character(1)`)\cr
    #' File path.
    #' @param pname (`character(1)`)\cr
    #' Parser name (e.g. "breakends" - see docs).
    #' @param delim (`character(1)`)\cr
    #' File delimiter.
    #' @param ... Passed on to `readr::read_delim`.
    #' @return A tibble with the parsed data.
    .parse_file_nohead = function(x, pname, delim = "\t", ...) {
      schema <- self$raw_schemas_all |>
        dplyr::filter(.data$name == pname) |>
        dplyr::select("version", "schema")
      parse_file_nohead(
        fpath = x,
        schema = schema,
        delim = delim,
        ...
      )
    },
    #' @description Evaluate function in the context of the Tool's
    #' environment.
    #' @param fun (`character(1)`)\cr
    #' Function from Tool to evaluate.
    #' @param envir (`environment()`)\cr
    #' Environment to evaluate the function within.
    #' @return The evaluated function.
    .eval_func = function(fun, envir = self) {
      stopifnot(rlang::is_scalar_character(fun))
      get(fun, envir)
    },
    #' @description Tidy a list of files.
    #' @param tidy (`logical(1)`)\cr
    #' Should the raw parsed tibbles get tidied?
    #' @param keep_raw (`logical(1)`)\cr
    #' Should the raw parsed tibbles be kept in the final output?
    #' @return self invisibly.
    tidy = function(tidy = TRUE, keep_raw = FALSE) {
      # if no tidying needed, early return
      if (!private$needs_tidying) {
        return(invisible(self))
      }
      # if no files found, early return
      if (nrow(self$files) == 0) {
        self$tbls <- NULL
        private$needs_tidying <- FALSE
        return(invisible(self))
      }
      # if both FALSE, just return the file list
      if (!tidy && !keep_raw) {
        self$tbls <- self$files
        return(invisible(self))
      }
      d <- self$files |>
        dplyr::mutate(
          parse_fun = glue("parse_{parser}"),
          tidy_fun = glue("tidy_{parser}")
        ) |>
        dplyr::rowwise() |>
        dplyr::mutate(
          raw = list(self$.eval_func(.data$parse_fun)(.data$path)),
          tidy = dplyr::if_else(
            tidy,
            list(self$.eval_func(.data$tidy_fun)(.data$raw)),
            list(NULL)
          )
        ) |>
        dplyr::ungroup() |>
        dplyr::select(-c("parse_fun", "tidy_fun"))
      if (!keep_raw) {
        d <- d |>
          dplyr::select(-"raw")
      }
      if (!tidy) {
        d <- d |>
          dplyr::select(-"tidy")
      }
      self$tbls <- d
      private$needs_tidying <- FALSE
      return(invisible(self))
    },
    #' @description Write tidy tibbles.
    #' @param odir (`character(1)`)\cr
    #' Directory path to output tidy files. Ignored if format is db.
    #' @param format (`character(1)`)\cr
    #' Format of output files.
    #' @param id (`character(1)`)\cr
    #' ID to use for the dataset (e.g. `wfrid.123`, `prid.456`).
    #' @param dbconn (`DBIConnection`)\cr
    #' Database connection object (see `DBI::dbConnect`).
    #' @return A tibble with the tidy data and their output location prefix.
    write = function(odir = ".", format = "tsv", id = NULL, dbconn = NULL) {
      if (format != "db") {
        if (is.null(odir)) {
          stop("Output directory must be specified when format is not 'db'.")
        }
        fs::dir_create(odir)
        odir <- normalizePath(odir)
      }
      stopifnot(!is.null(id))
      stopifnot("Did you forget to tidy?" = !private$needs_tidying)
      if (is.null(self$tbls)) {
        # even though tidying is not needed, there must be no files detected
        # for tidying (and therefore writing). So return NULL.
        return(NULL)
      }

      d_write <- self$tbls |>
        dplyr::select(
          "tool_parser",
          "parser",
          "prefix",
          "tidy"
        ) |>
        tidyr::unnest("tidy", names_sep = "_") |>
        dplyr::rowwise() |>
        # handle sub-tbls
        dplyr::mutate(
          tbl_name = dplyr::if_else(
            .data$parser == .data$tidy_name,
            .data$tool_parser,
            paste(.data$tool_parser, .data$tidy_name, sep = "_")
          ),
          fpfix = dplyr::if_else(
            format == "db",
            .data$prefix,
            paste(file.path(odir, .data$prefix), .data$tbl_name, sep = "_")
          ),
          dbtab = ifelse(
            format == "db",
            list(.data$tbl_name),
            list(NULL)
          ),
          out = list(
            nemo_write(
              d = .data$tidy_data,
              fpfix = .data$fpfix,
              format = format,
              id = id,
              dbconn = dbconn,
              dbtab = .data$dbtab
            )
          )
        ) |>
        dplyr::ungroup()
      invisible(d_write)
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
        write(
          odir = odir,
          format = format,
          id = id,
          dbconn = dbconn
      )
    }
  ) # public end
)
