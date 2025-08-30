get_nemo_workflow <- function(wf = NULL) {
  stopifnot(!is.null(wf))
  wfs <- list(
    wigits = list(pkg = "tidywigits", fun = "Wigits"),
    basemean = list(pkg = "base", fun = "mean")
    # dragen = list(pkg = "dracarys", fun = "Dragen"),
    # cttso = list(pkg = "cttsor", fun = "Tso")
  )
  all_wfs <- names(wfs)
  if (!wf %in% all_wfs) {
    msg1 <- glue::glue_collapse(sep = ", ", last = " or ")
    msg2 <- glue::glue("Workflow {wf} not found. Available: {all_wfs}")
    stop(msg2)
  }
  pkgfun <- getExportedValue(wfs[[wf]][["pkg"]], wfs[[wf]][["fun"]])
  return(pkgfun)
}
