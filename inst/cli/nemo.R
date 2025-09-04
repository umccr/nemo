#!/usr/bin/env Rscript

{
  suppressPackageStartupMessages(use("nemo", c("nemo_cli")))
}

nemo::nemo_cli(pkg = "nemo", desc = "Tidy Bioinformatic Workflows", wf = NULL)
