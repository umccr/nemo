require(dplyr)
require(here, include.only = "here")
require(tidyr, include.only = "unnest")
require(dm, include.only = "dm")
d <- "~/projects/dracarys/inst/reports/wgts-qc/nogit/tidy_data_rds/2025-01-14_wgts.rds" |>
  readRDS()

lims <- d |>
  select(
    libraryId, individualId, sampleId, sampleName, subjectId, externalSampleId,
    projectName, projectOwner, phenotype, sampleType, source, assay, quality, workflow
  ) |>
    distinct()

prids <- d |>
  select(
    portalRunId, libraryId
  )

res0 <- d |>
  select(portalRunId, data_tidy) |>
  unnest(data_tidy)

mapmet <- res0 |>
  filter(name == "mapmetrics") |>
  select(portalRunId, data) |>
  unnest(data)

d_no_keys <- dm(lims, prids, mapmet) 
dm::dm_enum_pk_candidates(dm = d_no_keys, table = lims) # libraryId
dm::dm_enum_pk_candidates(dm = d_no_keys, table = prids) # portalRunId
dm::dm_enum_pk_candidates(dm = d_no_keys, table = mapmet) # portalRunId, RG

d_pk <- d_no_keys |>
  dm::dm_add_pk(lims, libraryId) |>
  dm::dm_add_pk(prids, portalRunId) |>
  dm::dm_add_pk(mapmet, c(portalRunId, RG))

dm::dm_enum_fk_candidates(
  dm = d_pk,
  table = prids,
  ref_table = lims
)
dm::dm_enum_fk_candidates(
  dm = d_pk,
  table = prids,
  ref_table = lims
)

d_full <- d_pk |>
  dm::dm_add_fk(table = prids, columns = libraryId, ref_table = lims)

d_full |>
  dm::dm_draw()
