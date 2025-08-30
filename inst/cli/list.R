# fmt: skip
list_add_args <- function(subp) {
  l <- subp$add_parser("list", help = "List Parsable Workflow Outputs")
  l$add_argument("-m", "--module", help = "Module name.", required = TRUE)
  l$add_argument("-d", "--in_dir", help = "Input directory.", required = TRUE)
  l$add_argument("-q", "--quiet", help = "Shush all the logs.", action = "store_true")
}

list_parse_args <- function(args) {
  list_args <- list(
    in_dir = args$in_dir,
    module = args$module
  )
  # list run
  if (args$quiet) {
    res <- suppressMessages(do.call(nemo_list, list_args))
  } else {
    res <- do.call(nemo_list, list_args)
  }
}

nemo_list <- function(in_dir, module, format = NULL) {
  fun <- get_nemo_workflow(module)
  if (is.null(format)) {
    format <- "pretty"
  }
  stopifnot(format %in% c("tsv", "pretty"))
  obj <- fun$new(in_dir)
  d <- obj$list_files()
  res <- d |>
    dplyr::mutate(n = dplyr::row_number()) |>
    dplyr::select("n", "tool_parser", "prefix", "bname", "size", "lastmodified", "path")
  if (format == "tsv") {
    readr::write_tsv(res, stdout())
  } else {
    cat(knitr::kable(res, format = "markdown"), sep = "\n")
  }
}
