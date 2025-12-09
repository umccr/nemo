# Construct UML diagram from all available classes

# classes start with a cap, copy into vector and get their value
# dput(ls("package:nemo", pattern = "[A-Z].*")) # note: load pkg prior
fun_char <- c("Config", "Tool", "Tool1", "Workflow", "Workflow1")
# remotes::install_gitlab("b-rowlingson/R6toPlant")
use("R6toPlant", "make_plant")
use("nemo", fun_char)
use("purrr", "map")
use("here", "here")
use("glue", "glue")
use("fs", "dir_create")

# get returns value of function
x_as_fun <- purrr::map(fun_char, get)
out_pref <- here::here("vignettes", "fig", "uml", "nemo")
out_uml <- glue::glue("{out_pref}.uml")
fs::dir_create(dirname(out_uml))
R6toPlant::make_plant(
  classes = x_as_fun,
  output = out_uml
)
system(glue::glue("plantuml -tsvg {out_uml}"))
