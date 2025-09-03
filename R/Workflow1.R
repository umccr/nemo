#' @title Workflow1 Object
#'
#' @description
#' Workflow1 file parsing and manipulation.
#' @examples
#' path <- system.file("extdata/tool1", package = "nemo")
#' odir <- tempdir()
#' id <- "workflow1_run1"
#' w <- Workflow1$new(path)
#' x <- w$nemofy(odir = odir, format = "parquet", id = id)
#' (lf <- list.files(odir, pattern = "tool1.*parquet", full.names = FALSE))
#' @testexamples
#' expect_equal(length(lf), 4)
#' @export
Workflow1 <- R6::R6Class(
  "Workflow1",
  inherit = Workflow,
  public = list(
    #' @description Create a new Workflow1 object.
    #' @param path (`character(n)`)\cr
    #' Path(s) to Workflow1 results.
    initialize = function(path = NULL) {
      tools <- list(
        tool1 = Tool1
      )
      super$initialize(name = "Workflow1", path = path, tools = tools)
    }
  ) # public end
)
