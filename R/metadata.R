#' Title
#'
#' @param files (`tibble()`)\cr
#' Written files.
#' @param pkgs (`character(n)`)\cr
#' Packages to include versions of.
#' @param input_id
#' Input ID to use for the dataset (e.g. `run123`).
#' @param output_id (`character(1)`)\cr
#' Output ID to use for the dataset (e.g. `run123`).
#' @param input_dir (`character(n)`)\cr
#' Input directory (can be multiple).
#' @param output_dir (`character(1)`)\cr
#' Output directory.
#'
#' @returns List of metadata.
#'
#' @examples
#' files <- tibble::tibble(
#'   tbl_name = c("purple_qc", "amber_qc"),
#'   prefix = c("S123", "S123"),
#'   outpath = c("S123_purple_qc.tsv", "S123_amber_qc.tsv")
#' )
#' pkgs <- c("nemo", "tidywigits")
#' input_id <- "run123"
#' output_id <- ulid::ulid()
#' input_dir <- "/path/to/wigits/run123"
#' output_dir <- "/path/to/nemo/outputs/run123"
#' nemo_metadata(files, pkgs, input_id, output_id, input_dir, output_dir)
#' @export
nemo_metadata <- function(files, pkgs, input_id, output_id, input_dir, output_dir) {
  stopifnot(all(purrr::map_lgl(pkgs, pkg_found)))
  pkg_versions <- pkgs |>
    purrr::map_chr(\(pkg) as.character(utils::packageVersion(pkg))) |>
    purrr::set_names(pkgs)
  list(
    files = files,
    pkg_versions = pkg_versions,
    input_id = input_id,
    output_id = output_id,
    input_dir = input_dir,
    output_dir = output_dir
  )
}
