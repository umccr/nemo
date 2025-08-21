tool1 <- list(
  table1 = list(
    list(
      version = "v1.2.3",
      data = tibble::tibble(
        SampleID = "sampleA",
        Chromosome = c("chr1", "chr2", "chr3"),
        Start = c(10, 100, 1000),
        End = c(50, 500, 5000),
        metricX = c(0.1, 0.2, 0.3)
      )
    ),
    list(
      version = "latest",
      data = tibble::tibble(
        SampleID = "sampleA",
        Chromosome = c("chr1", "chr2", "chr3"),
        Start = c(10, 100, 1000),
        End = c(50, 500, 5000),
        metricX = c(0.1, 0.2, 0.3),
        metricY = c(0.4, 0.5, 0.6),
        metricZ = c(0.7, 0.8, 0.9)
      )
    )
  ),
  table2 = list(
    list(
      version = "latest",
      data = tibble::tibble(
        SampleID = "sampleA",
        metricA = c("a", "b", "c"),
        metricB = c(12.3, 4.56, 7.89)
      )
    )
  )
)

purrr::map2(tool1, names(tool1), \(tab, tab_name) {
  stopifnot(length(tab_name) == 1)
  purrr::map(tab, \(entry) {
    odir <- here::here("inst/extdata", "tool1", entry$version) |>
      fs::dir_create()
    fname <- file.path(odir, glue::glue("sampleA.tool1.{tab_name}.tsv"))
    readr::write_tsv(entry$data, fname)
  })
})
