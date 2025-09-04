cli_list_add_args <- function(subp, wf = NULL) {
  # fmt: skip
  fmts <- cli_nemo_list_formats |> glue::glue_collapse(sep = ", ")
  l <- subp$add_parser("list", help = "List Parsable Workflow Outputs")
  if (is.null(wf)) {
    l$add_argument("-w", "--workflow", help = "Workflow name.", required = TRUE)
  }
  l$add_argument("-d", "--in_dir", help = "Input directory.", required = TRUE)
  # fmt: skip
  l$add_argument("-f", "--format", help = paste0("Format of list output [def: %(default)s] (", fmts, ")"), default = cli_nemo_list_formats["pretty"])
  l$add_argument("-q", "--quiet", help = "Shush all the logs.", action = "store_true")
}

cli_list_parse_args <- function(args, wf = NULL) {
  list_args <- list(
    format = args$format,
    in_dir = args$in_dir,
    workflow = args$workflow
  )
  if (!is.null(wf)) {
    list_args$workflow <- wf
  }
  # list run
  if (args$quiet) {
    res <- suppressMessages(do.call(cli_nemo_list, list_args))
  } else {
    res <- do.call(cli_nemo_list, list_args)
  }
}

cli_nemo_list <- function(in_dir, workflow, format = "pretty") {
  fun <- nemoverse_wf_dispatch(workflow)
  valid_out_fmt(format, choices = cli_nemo_list_formats)
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

cli_nemo_list_formats <- c(tsv = "tsv", pretty = "pretty")
