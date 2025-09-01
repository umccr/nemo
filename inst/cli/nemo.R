#!/usr/bin/env Rscript

{
  suppressPackageStartupMessages(use("nemo", c("nemo_log")))
  suppressPackageStartupMessages(use("argparse", "ArgumentParser"))
  suppressPackageStartupMessages(use("fs", "dir_create"))
  suppressPackageStartupMessages(use("glue", c("glue", "glue_collapse")))
}

pkg_name <- "nemo"
prog_nm <- paste0(pkg_name, ".R")
version <- as.character(packageVersion(pkg_name))
p <- argparse::ArgumentParser(
  description = "🐠 Tidy Bioinformatic Workflows 🐢",
  prog = prog_nm,
  python_cmd = nemo::get_python()
)
p$add_argument("-v", "--version", action = "version", version = paste(prog_nm, version))
subparser_name <- "subparser_name"
subp <- p$add_subparsers(help = "sub-command help", dest = subparser_name)
source(system.file("cli/tidy.R", package = pkg_name))
source(system.file("cli/list.R", package = pkg_name))
tidy_add_args(subp)
list_add_args(subp)
args <- p$parse_args()

if (length(args$subparser_name) == 0) {
  p$print_help()
} else if (args$subparser_name == "tidy") {
  tidy_parse_args(args)
} else if (args$subparser_name == "list") {
  list_parse_args(args)
} else {
  all_subp <- c("'tidy'", "'list'") |>
    glue_collapse(sep = ", ", last = " or ")
  stop("Need to specify one of the following: ", all_subp)
}
