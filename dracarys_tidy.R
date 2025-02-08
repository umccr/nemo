require(dplyr)
require(here, include.only = "here")
require(tidyr, include.only = "unnest")
require(dm)
require(rportal)

c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_REGION") |>
  rportal::envvar_defined() |>
  stopifnot()
token <- rportal::orca_jwt() |> rportal::jwt_validate()
workflowruns <- rportal::orca_workflow_list(wf_name = "wgts-qc", token = token, page_size = 5)
workflowruns_tidy <- workflowruns |>
  rowwise() |>
  mutate(
    pld = list(rportal::orca_wfrid2payload(wfrid = .data$orcabusId, token = token)),
    pld_tidy = list(rportal::pld_wgtsqc(.data$pld))
  ) |>
  ungroup()

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
  table = mapmet,
  ref_table = prids
)

d_full <- d_pk |>
  dm::dm_add_fk(table = prids, columns = libraryId, ref_table = lims) |>
  dm::dm_add_fk(table = mapmet, columns = portalRunId, ref_table = prids)


d_full |>
  dm::dm_draw(rankdir = "RL")

d_full |>
  dm::dm_examine_constraints()




#####################
dm_for_autoinc_1 <- dm(
  t1 = tibble(a = 5:7, o = letters[1:3]),
  t2 = tibble(c = 10:8, d = 7:5, o = letters[3:1]),
  t3 = tibble(e = c(6L, 5L, 7L), o = letters[c(2, 1, 3)]),
  t4 = tibble(g = 1:3, h = 8:10, o = letters[1:3])
)

dm_ai_w_keys <-
    dm_for_autoinc_1 %>%
    dm_add_pk(t1, a, autoincrement = TRUE) %>%
    dm_add_pk(t2, c, autoincrement = TRUE) %>%
    dm_add_pk(t4, g, autoincrement = TRUE) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t3, e, t1) %>%
    dm_add_fk(t4, h, t2)

local_dm <-
    dm_ai_w_keys %>%
    collect()

dm_ai_insert <-
  dm_for_autoinc_1 %>%
    # Remove one PK column, only provided by database
    dm_select(t4, -g) %>%
    dm_zoom_to(t3) %>%
    filter(0L == 1L) %>%
    dm_update_zoomed()
