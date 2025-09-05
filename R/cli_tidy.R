cli_tidy_add_args <- function(subp, wf = NULL) {
  fmts <- nemo_out_formats() |> glue::glue_collapse(sep = ", ")
  tidy <- subp$add_parser("tidy", help = "Tidy Workflow Outputs")
  if (is.null(wf)) {
    tidy$add_argument("-w", "--workflow", help = "Workflow name.", required = TRUE)
  }
  tidy$add_argument("-d", "--in_dir", help = "Input directory.", required = TRUE)
  tidy$add_argument("-o", "--out_dir", help = "Output directory.")
  # fmt: skip
  tidy$add_argument("-f", "--format", help = paste0("Format of output [def: %(default)s] (", fmts, ")"), default = "parquet")
  tidy$add_argument("-i", "--id", help = "ID to use for this run.", required = TRUE)
  tidy$add_argument("--dbname", help = "Database name.")
  tidy$add_argument("--dbuser", help = "Database user.")
  tidy$add_argument("--include", help = "Include only these files (comma,sep).")
  tidy$add_argument("--exclude", help = "Exclude these files (comma,sep).")
  tidy$add_argument("-q", "--quiet", help = "Shush all the logs.", action = "store_true")
}

cli_tidy_parse_args <- function(args, wf = NULL) {
  out_dir <- args$out_dir
  if (args$format != "db") {
    if (is.null(out_dir)) {
      stop("Output directory must be specified when format is not 'db'.")
    }
    fs::dir_create(out_dir)
    out_dir <- normalizePath(out_dir)
  }
  include <- args$include
  exclude <- args$exclude
  if (!is.null(include)) {
    include <- strsplit(include, ",")[[1]]
  }
  if (!is.null(exclude)) {
    exclude <- strsplit(exclude, ",")[[1]]
  }
  tidy_args <- list(
    workflow = args$workflow,
    in_dir = args$in_dir,
    out_dir = out_dir,
    out_format = args$format,
    id = args$id,
    dbname = args$dbname,
    dbuser = args$dbuser,
    include = include,
    exclude = exclude
  )
  if (!is.null(wf)) {
    tidy_args$workflow <- wf
  }

  # tidy run
  if (args$quiet) {
    res <- suppressMessages(do.call(cli_nemo_tidy, tidy_args))
  } else {
    res <- do.call(cli_nemo_tidy, tidy_args)
  }
}

cli_nemo_tidy <- function(
  workflow,
  in_dir,
  out_dir,
  out_format,
  id,
  dbname,
  dbuser,
  include,
  exclude
) {
  valid_out_fmt(out_format)
  fun <- nemoverse_wf_dispatch(workflow)
  dbconn <- NULL
  if (out_format == "db") {
    stopifnot(!is.null(dbname), !is.null(dbuser))
    dbconn <- DBI::dbConnect(
      drv = RPostgres::Postgres(),
      dbname = dbname,
      user = dbuser
    )
  }
  nemo_log("INFO", paste("Tidying dir:", in_dir))
  obj <- fun$new(in_dir)
  res <- obj$nemofy(
    odir = out_dir,
    format = out_format,
    id = id,
    dbconn = dbconn,
    include = include,
    exclude = exclude
  )
  if (out_format == "db") {
    nemo_log("INFO", paste("Tidy results written to db:", dbname))
  } else {
    nemo_log("INFO", paste("Tidy results written to dir:", out_dir))
  }
  return(invisible(res))
}
