#!/usr/bin/env Rscript

{
  suppressPackageStartupMessages(use("nemo", "get_python"))
  suppressPackageStartupMessages(use("argparse", "ArgumentParser"))
  suppressPackageStartupMessages(use("emojifont", "emoji"))
  suppressPackageStartupMessages(use("fs", "dir_create"))
  suppressPackageStartupMessages(use("glue", c("glue", "glue_collapse")))
}

e <- emoji
pkg <- "nemo"
prog_nm <- paste0(pkg, ".R")
version <- as.character(packageVersion(pkg))
get_nemo_workflow <- function(wf) {
  wfs <- list(
    wigits = list(pkg = "tidywigits", fun = "Wigits"),
    basemean = list(pkg = "base", fun = "mean")
    # dragen = list(pkg = "dracarys", fun = "Dragen"),
    # cttso = list(pkg = "cttsor", fun = "Tso")
  )
  all_wfs <- names(wfs)
  if (!wf %in% all_wfs) {
    msg1 <- glue_collapse(sep = ", ", last = " or ")
    msg2 <- glue("Workflow {wf} not found. Available: {all_wfs}")
    stop(msg2)
  }
  pkgfun <- getExportedValue(wfs[[wf]][["pkg"]], wfs[[wf]][["fun"]])
  return(pkgfun)
}

p <- ArgumentParser(
  description = glue("{e('tropical_fish')} Tidy Bioinformatic Workflows {e('turtle')}"),
  prog = prog_nm,
  python_cmd = get_python()
)
p$add_argument("-v", "--version", action = "version", version = glue("{prog_nm} {version}"))
args <- p$parse_args()
if (length(args$subparser_name) == 0) {
  p$print_help()
}
