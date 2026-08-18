#' AWS S3 Sync Helper
#'
#' @param src (`character(1)`)\cr
#' S3 source path.
#' @param dest (`character(1)`)\cr
#' Local destination path.
#' @param pats (`tibble()`)\cr
#' Patterns tibble with `inex` ("in" or "ex") and `pat` (pattern) columns.
#'
#' @examples
#' \dontrun{
#' src <- "s3://my-awesome-bucket/path/to/run1"
#' dest <- sub("s3:/", "~/s3", src)
#' pats <- tibble::tribble(
#'   ~inex, ~pat,
#'   "ex", "*",
#'   "in", "*foo.csv"
#' )
#' s3sync(src, dest, pats)
#' }
#' @export
s3sync <- function(src, dest, pats = NULL) {
  pats_default <- tibble::tribble(
    ~inex , ~pat ,
    "ex"  , "*"
  )
  pats <- pats %||% pats_default
  pat_args <- pats |>
    dplyr::mutate(flag = as.character(glue::glue("--{.data$inex}clude"))) |>
    tidyr::pivot_longer(c("flag", "pat"), values_to = "value") |>
    dplyr::pull("value")
  args <- c("s3", "sync", src, dest, pat_args)
  system2("aws", args)
}
