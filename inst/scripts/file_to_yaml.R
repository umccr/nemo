# Script to convert output files to yaml configs
{
  use("glue", "glue")
  use("tibble", "tribble")
  use("dplyr")
  use("here", "here")
  use("nemo", c("config_prep_multi", "config_prep_write"))
}

tool <- "tool1"
pref <- "sample1"
descr <- "Tool description."
d1 <- here(glue("inst/extdata/{tool}"))
# fmt: skip
d <- tribble(
    ~name,    ~descr,                  ~pat,               ~path,
    "table1", "Descripton of table1.", "\\.table1\\.tsv$", glue("{pref}.table1.tsv"),
    "table2", "Descripton of table2.", "\\.table2\\.tsv$", glue("{pref}.table2.tsv"),
  ) |>
  mutate(type = "tsv", path = file.path(d1, .data$path))
nemo::config_prep_multi(d, tool_descr = descr) |>
  nemo::config_prep_write(
    here(glue("inst/config/tools/{tool}/raw.yaml"))
  )
