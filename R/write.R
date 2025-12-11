#' Write data
#'
#' Writes tabular data in the given format.
#'
#' @param d (`data.frame()`)\cr
#' A data.frame (or tibble) with tidy data.
#' @param fpfix (`character(1)`)\cr
#' File prefix. The file extension is generated automatically via the `format`
#' argument. For a format of db, this is inserted into the `nemo_pfix` column.
#' @param format (`character(1)`)\cr
#' Output format. One of tsv, csv, parquet, rds, or db.
#' @param dbconn (`DBIConnection(1)`)\cr
#' Database connection object (see `DBI::dbConnect`). Used only when format is db.
#' @param dbtab (`character(1)`)\cr
#' Database table name (see `DBI::dbWriteTable`). Used only when format is db.
#'
#' @examples
#' d <- tibble::tibble(name = "foo", data = 123)
#' fpfix <- file.path(tempdir(), "data_test1")
#' format <- "csv"
#' nemo_write(d = d, fpfix = fpfix, format = format)
#' (res <- readr::read_csv(glue::glue("{fpfix}.csv.gz"), show_col_types = FALSE))
#' @examplesIf RPostgres::postgresHasDefault()
#' # for database writing
#' con <- DBI::dbConnect(RPostgres::Postgres())
#' tbl_nm <- "awesome_tbl"
#' nemo_write(d = d, fpfix = basename(fpfix), format = "db", dbconn = con, dbtab = tbl_nm)
#' DBI::dbListTables(con)
#' DBI::dbReadTable(con, tbl_nm)
#' DBI::dbDisconnect(con)
#' @testexamples
#' expect_equal(nrow(res), 1)
#' @export
nemo_write <- function(d, fpfix = NULL, format = "tsv", dbconn = NULL, dbtab = NULL) {
  stopifnot(is.data.frame(d))
  valid_out_fmt(format)
  if (format == "db") {
    stopifnot("Valid db conn needed" = !is.null(dbconn))
    stopifnot("Valid db tab name needed" = !is.null(dbtab))
    DBI::dbWriteTable(
      conn = dbconn,
      name = dbtab,
      value = d,
      append = TRUE,
      overwrite = FALSE
    )
  } else {
    stopifnot(!is.null(fpfix))
    fpfix <- as.character(fpfix)
    sfx <- c(tsv = "tsv.gz", csv = "csv.gz", parquet = "parquet", rds = "rds")
    osfx <- function(s) glue("{fpfix}.{sfx[s]}")
    fs::dir_create(dirname(fpfix))
    if (format == "tsv") {
      readr::write_tsv(d, osfx("tsv"))
    } else if (format == "csv") {
      readr::write_csv(d, osfx("csv"))
    } else if (format == "parquet") {
      arrow::write_parquet(d, osfx("parquet"))
    } else if (format == "rds") {
      readr::write_rds(d, osfx("rds"))
    } else {
      stop("No where else to go, check your output format!")
    }
  }
  # also gets returned in case of NULL format
  return(invisible(d))
}

#' Output Format is Valid
#'
#' Checks that the specified output format is valid.
#' @param x Output format.
#' @param choices Available choices for valid output formats.
#' @examples
#' valid_out_fmt("tsv")
#' @testexamples
#' expect_true(valid_out_fmt("tsv"))
#' expect_error(valid_out_fmt("foo"))
#' expect_error(valid_out_fmt(c("tsv", "csv")))
#' @export
valid_out_fmt <- function(x, choices = nemo_out_formats()) {
  y <- glue::glue_collapse(choices, sep = ", ", last = " or ")
  assertthat::assert_that(
    rlang::is_scalar_character(x) && x %in% choices,
    msg = glue("Output format should be _one_ of {y}.")
  )
}

#' Output Formats Supported
#'
#' @return Character vector of supported output formats.
#' @export
nemo_out_formats <- function() {
  c("parquet", "db", "tsv", "csv", "rds")
}
