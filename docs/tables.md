# Tables

Initial sketch of tables used in utopia.

## Category A: DRAGEN Metrics

| N   | Table              | Description                           |
| --- | ------------------ | ------------------------------------- |
| 1   | `dr_cvg`           | `wgs_coverage_metrics`                |
| 2   | `dr_cvgcontig`     | `wgs_contig_mean_cov`                 |
| 3   | `dr_fqc_bpcontent` | `fastqc_positional_base_content`      |
| 4   | `dr_fqc_bpavgqual` | `fastqc_positional_base_mean_quality` |
| 5   | `dr_fqc_bpqual`    | `fastqc_positional_quality`           |
| 6   | `dr_fqc_rdgc`      | `fastqc_read_gc_content`              |
| 7   | `dr_fqc_rdgcqual`  | `fastqc_read_gc_content_quality`      |
| 8   | `dr_fqc_rdlen`     | `fastqc_read_lengths`                 |
| 9   | `dr_fqc_rdavgqual` | `fastqc_read_mean_quality`            |
| 10  | `dr_fqc_seqpos`    | `fastqc_sequence_positions`           |
| 11  | `dr_fraglen`       | `fragment_length_hist`                |
| 12  | `dr_map`           | `mapping_metrics`                     |
| 13  | `dr_ploidy`        | `ploidy_estimation_metrics`           |
| 14  | `dr_replay`        | `replay`                              |
| 15  | `dr_sv`            | `sv_metrics`                          |
| 16  | `dr_time`          | `time_metrics`                        |
| 17  | `dr_trim`          | `trimmer_metrics`                     |
| 18  | `dr_wgsfhist`      | `wgs_fine_hist`                       |
| 19  | `dr_wgshist`       | `wgs_hist`                            |
| 20  | `dr_umi`           | `umi_metrics`                         |
| 21  | `dr_umihist`       | `umi_metrics (histogram)`             |

## Category B: cttso

| N   | Table                     | Description                         |
| --- | ------------------------- | ----------------------------------- |
| 1   | `cttso_sar_biom`          | `SampleAnalysisResults_biomarkers`  |
| 2   | `cttso_sar_cnv`           | `SampleAnalysisResults_cnv`         |
| 3   | `cttso_sar_qc`            | `SampleAnalysisResults_qc`          |
| 4   | `cttso_sar_sample`        | `SampleAnalysisResults_sampleinfo`  |
| 5   | `cttso_sar_snv`           | `SampleAnalysisResults_snv`         |
| 6   | `cttso_sar_swconfds`      | `SampleAnalysisResults_swconfds`    |
| 7   | `cttso_sar_swconfother`   | `SampleAnalysisResults_swconfother` |
| 8   | `cttso_cvg_target`        | `TargetRegionCoverage`              |
| 9   | `cttso_fqc_bpcontent`     | `TargetRegionCoverage`              |
| 10  | `cttso_tmb`               | `Tmb`                               |
| 11  | `cttso_tmb_trace`         | `TMB_Trace`                         |
| 12  | `cttso_fusions`           | `fusions`                           |
| 13  | `cttso_msi`               | `msi`                               |
| 14  | `cttso_mergedsmallv_info` | `MergedSmallVariants.vcf.gz`        |
| 14  | `cttso_mergedsmallv_csq`  | `MergedSmallVariants.vcf.gz`        |
| 15  | `cttso_mergedsmallv_gt`   | `MergedSmallVariants.vcf.gz`        |

## Category C: umccrise

| N   | Table             | Description |
| --- | ----------------- | ----------- |
| 1   | `um_qcsum`        |             |
| 2   | `um_hrd_chord`    |             |
| 3   | `um_hrd_hrdetect` |             |
| 4   | `um_hrd_dragen`   |             |
| 5   | `um_sigs2015`     |             |
| 6   | `um_sigs2020`     |             |
| 7   | `um_mosdepth`     |             |
| 8   | `um_samtools`     |             |
| 9   | `um_oviraptor`    |             |
| 10  | `um_ppl_gene`     |             |
| 11  | `um_ppl_segs`     |             |
| 12  | `um_ppl_purity`   |             |
| 13  | `um_ppl_qc`       |             |
| 14  | `um_bcftools`     |             |
| 15  | `um_pcgr_tsv`     |             |
| 16  | `um_pcgr_biom`    |             |
| 17  | `um_conpair`      |             |
