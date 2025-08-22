#' @title Config Object
#'
#' @description
#' Config YAML file parsing.
#' @examples
#' tool <- "tool1"
#' pkg <- "nemo"
#' conf <- Config$new(tool, pkg)
#' conf$get_raw_patterns()
#' (rv1 <- conf$get_raw_versions())
#' conf$get_raw_descriptions()
#' conf$get_raw_schemas_all()
#' conf$get_raw_schema("table1")
#' conf$get_raw_schema("table1", v = "v1.2.3")
#' conf$are_raw_schemas_valid()
#' conf$get_tidy_descriptions()
#' (ts1 <- conf$get_tidy_schemas_all())
#' conf$get_tidy_schema("table1")
#' conf$get_tidy_schema("table1", v = "v1.2.3")
#'
#' @testexamples
#' expect_true(conf$are_raw_schemas_valid())
#' expect_true(ts1 |> dplyr::filter(.data$name == "table1") |> nrow() == 2)
#' expect_true(all(unique(rv1$value) == c("v1.2.3", "latest")))
#' expect_error(Config$new("foo", pkg))
#'
#' @export
Config <- R6::R6Class(
  "Config",
  public = list(
    #' @field tool (`character(1)`)\cr
    #' Tool name.
    tool = NULL,
    #' @field config (`list()`)\cr
    #' Config list.
    config = NULL,
    #' @field raw_schemas_all (`tibble()`)\cr
    #' All raw schemas for tool.
    raw_schemas_all = NULL,
    #' @field tidy_schemas_all (`tibble()`)\cr
    #' All tidy schemas for tool.
    tidy_schemas_all = NULL,

    #' @description Create a new Config object.
    #' @param tool (`character(1)`)\cr
    #' Tool name.
    #' @param pkg (`character(1)`)\cr
    #' Package name for config lookup.
    initialize = function(tool, pkg) {
      tool <- tolower(tool)
      self$tool <- tool
      self$config <- self$read(pkg = pkg)
      self$raw_schemas_all <- self$get_raw_schemas_all()
      self$tidy_schemas_all <- self$get_tidy_schemas_all()
    },
    #' @description Print details about the Tool.
    #' @param ... (ignored).
    print = function(...) {
      # fmt: skip
      res <- tibble::tribble(
        ~var, ~value,
        "tool", self$tool,
        "nraw", as.character(nrow(self$raw_schemas_all)),
        "ntidy", as.character(nrow(self$tidy_schemas_all))
      )
      cat(glue("#--- Config {self$tool} ---#\n"))
      print(knitr::kable(res))
      invisible(self)
    },
    #' @description Read YAML configs.
    #' @param pkg (`character(1)`)\cr
    #' Package name where the config files are located.
    #' @return A `list()` with the parsed data.
    read = function(pkg) {
      pkg_config_path <- system.file("config/tools", package = pkg)
      stopifnot(dir.exists(pkg_config_path))
      tools <- list.files(pkg_config_path, full.names = FALSE)
      msg1 <- glue("'{self$tool}' does not have a config under '{pkg_config_path}/'.")
      msg2 <- glue("There should be a raw.yaml and tidy.yaml file for {self$tool}.")
      assertthat::assert_that(self$tool %in% tools, msg = msg1)
      pkg_config_path <- file.path(pkg_config_path, self$tool)
      assertthat::assert_that(
        all(file.exists(file.path(pkg_config_path, c("raw.yaml", "tidy.yaml")))),
        msg = msg2
      )
      raw <- yaml::read_yaml(file.path(pkg_config_path, "raw.yaml"))
      tidy <- yaml::read_yaml(file.path(pkg_config_path, "tidy.yaml"))
      list(raw = raw, tidy = tidy)
    },
    #' @description Return all output file patterns.
    get_raw_patterns = function() {
      self$config[["raw"]][["raw"]] |>
        purrr::map("pattern") |>
        tibble::enframe() |>
        tidyr::unnest("value")
    },
    #' @description Return all output file schema versions.
    get_raw_versions = function() {
      self$config[["raw"]][["raw"]] |>
        purrr::map(\(file) file[["schema"]] |> names()) |>
        tibble::enframe() |>
        tidyr::unnest("value")
    },
    #' @description Return all output file descriptions.
    get_raw_descriptions = function() {
      self$config[["raw"]][["raw"]] |>
        purrr::map("description") |>
        tibble::enframe() |>
        tidyr::unnest("value")
    },
    #' @description Return all output file schemas.
    get_raw_schemas_all = function() {
      self$config[["raw"]][["raw"]] |>
        purrr::map(\(rawfile) {
          rawfile[["schema"]] |>
            purrr::map(
              \(s) {
                {
                  s |>
                    purrr::map(\(v) {
                      v[["type"]] <- schema_type_remap(v[["type"]])
                      tibble::as_tibble_row(v)
                    })
                } |>
                  dplyr::bind_rows()
              }
            ) |>
            tibble::enframe(name = "version", value = "schema")
        }) |>
        dplyr::bind_rows(.id = "name")
    },
    #' @description Get raw file schema.
    #' @param x (`character(1)`)\cr
    #' Raw file name.
    #' @param v (`character(1)`)\cr
    #' Version (def: latest).
    get_raw_schema = function(x, v = "latest") {
      s <- self$raw_schemas_all
      assertthat::assert_that(
        x %in% s[["name"]],
        msg = glue("{x} not found in schemas for {self$tool}.")
      )
      s |>
        dplyr::filter(.data$name == x, .data$version == v) |>
        dplyr::select("schema") |>
        tidyr::unnest("schema")
    },
    #' @description Validate schema.
    are_raw_schemas_valid = function() {
      valid_types <- c(char = "c", int = "i", float = "d")
      valid_types_print <- glue::glue_collapse(
        valid_types,
        sep = ", ",
        last = " or "
      )
      s <- self$raw_schemas_all
      invalid <- s |>
        tidyr::unnest("schema") |>
        dplyr::mutate(invalid_type = !.data$type %in% valid_types) |>
        dplyr::filter(invalid_type) |>
        dplyr::mutate(
          warn = glue::glue(
            "{.data$name} -> {.data$version} -> {.data$field} -> {.data$type}"
          )
        )
      if (nrow(invalid) > 0) {
        msg1 <- invalid |>
          dplyr::pull("warn") |>
          glue::glue_collapse(sep = "; ")
        msg2 <- glue(
          "Raw field types need to be one of: {valid_types_print}\n",
          "Check the following in the {self$tool} config:\n{msg1}"
        )
        warning(msg2)
        return(FALSE)
      }
      return(TRUE)
    },
    #' @description Return all tidy tibble descriptions.
    get_tidy_descriptions = function() {
      self$config[["tidy"]][["tidy"]] |>
        purrr::map(\(tt) {
          tt[["description"]]
        }) |>
        tibble::enframe() |>
        tidyr::unnest("value")
    },
    #' @description Return all tidy tibble schemas.
    get_tidy_schemas_all = function() {
      l1 <- self$config[["tidy"]][["tidy"]]
      l1 |>
        purrr::map(\(tt) {
          tt[["schema"]] |>
            purrr::map(\(v) {
              v |>
                purrr::map(
                  \(y) {
                    y |>
                      purrr::map(\(z) {
                        z[["type"]] <- schema_type_remap(z[["type"]])
                        tibble::as_tibble_row(z)
                      }) |>
                      dplyr::bind_rows()
                  }
                ) |>
                tibble::enframe(name = "tbl", value = "schema")
            }) |>
            tibble::enframe(name = "version", value = "value2")
        }) |>
        tibble::enframe(name = "name", value = "value1") |>
        tidyr::unnest("value1") |>
        tidyr::unnest("value2")
    },
    #' @description Get tidy tbl schema.
    #' @param x (`character(1)`)\cr
    #' Tidy tbl name.
    #' @param v (`character(1)`)\cr
    #' Version of schema (def: latest).
    #' @param subtbl (`character(1)`)\cr
    #' Subtbl to use (def: tbl1).
    get_tidy_schema = function(x, v = "latest", subtbl = "tbl1") {
      s <- self$tidy_schemas_all
      assertthat::assert_that(
        x %in% s[["name"]],
        msg = glue("{x} not found in schemas for {self$tool}.")
      )
      s |>
        dplyr::filter(
          .data$name == x,
          .data$version == v,
          .data$tbl == subtbl
        ) |>
        dplyr::select("schema") |>
        tidyr::unnest("schema")
    }
  ) # end public
)

#' Prepare config schema from raw file
#'
#' @description
#' Prepares config schema from raw file.
#'
#' @param path (`character(1)`)\cr
#' File path.
#' @param ... Passed on to `readr::read_delim`.
#' @examples
#' \dontrun{
#' path <- here::here("nogit/oa_v2/esvee/prep/COLO829_tumor.esvee.prep.fragment_length.tsv")
#' config_prep_raw_schema(path = path, delim = "\t")
#' }
config_prep_raw_schema <- function(path, ...) {
  path |>
    readr::read_delim(n_max = 100, show_col_types = FALSE, ...) |>
    purrr::map_chr(class) |>
    tibble::enframe(name = "field", value = "type") |>
    dplyr::mutate(
      type = dplyr::case_match(
        .data$type,
        "character" ~ "'char'",
        "integer" ~ "'int'",
        "numeric" ~ "'float'",
        "logical" ~ "'char'"
      ),
      field = paste0("'", .data$field, "'")
    )
}

#' Prepare config from raw file
#'
#' @description
#' Prepares config from raw file.
#'
#' @param path (`character(1)`)\cr
#' File path.
#' @param name (`character(1)`)\cr
#' File nickname.
#' @param descr (`character(1)`)\cr
#' File description.
#' @param pat (`character(1)`)\cr
#' File pattern.
#' @param type (`character(1)`)\cr
#' File type.
#' @param v (`character(1)`)\cr
#' File version.
#' @param ... Passed on to `readr::read_delim`.
#' @examples
#' \dontrun{
#' path <- here::here("nogit/oa_v2/esvee/prep/COLO829_tumor.esvee.prep.fragment_length.tsv")
#' name <- "prepfraglen"
#' descr <- "Fragment length stats."
#' pat <- "\\.esvee\\.prep\\.fragment_length\\.tsv$"
#' type <- "tsv"
#' v <- "latest"
#' l <- config_prep_raw(path = path, name = name, descr = descr, pat = pat, type = type, v = v)
#' }
config_prep_raw <- function(path, name, descr, pat, type = "tsv", v = "latest", ...) {
  schema <- config_prep_raw_schema(path = path, ...)
  attr(pat, "quoted") <- TRUE
  list(
    list(
      description = glue("'{descr}'"),
      pattern = pat,
      ftype = glue("'{type}'"),
      schema = list(schema) |> purrr::set_names(v)
    )
  ) |>
    purrr::set_names(name)
}

config_prep_multi <- function(x, tool_descr = NULL) {
  assertthat::assert_that(
    tibble::is_tibble(x),
    all(c("name", "descr", "pat", "type", "path") %in% colnames(x)),
    !is.null(tool_descr)
  )
  l <- x |>
    dplyr::rowwise() |>
    dplyr::mutate(
      config = config_prep_raw(
        path = .data$path,
        name = .data$name,
        descr = .data$descr,
        pat = .data$pat,
        type = .data$type
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::pull("config")
  list(description = glue::glue("'{tool_descr}'"), raw = l)
}

config_prep_write <- function(x, out) {
  yaml::write_yaml(x, out, column.major = FALSE)
  cmd <- glue("sed -i '' \"s/'''/'/g\" {out}")
  system(cmd)
}
