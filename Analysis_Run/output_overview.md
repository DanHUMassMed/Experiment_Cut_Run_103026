# Output Results Directory Overview (`Analysis_Run/results/cut_run103026A/`)

All downstream CUT&RUN analysis outputs are published to `Analysis_Run/results/cut_run103026A/` in numbered folders matching the pipeline execution steps (`Step c` through `Step i`).

---

## 1. Master Directory Summary Table

| Output Directory | Config Toggle (`experiment.config`) | What's Inside & What It Is Used For |
| :--- | :--- | :--- |
| `09_peaks/macs2/` | `run_macs2_callpeak` (`true`) | **Step c:** Sample-level peak calls (`*.narrowPeak`), 1-bp peak summits (`*_summits.bed`), and summary tables (`*_peaks.xls`) using the MACS2 algorithm (best general-purpose caller). |
| `09_peaks/homer/` | `run_homer_findpeaks` (`true`) | **Step c:** Sample-level peak tables (`*_peaks.txt`) and 6-column BED files (`*_peaks.bed`) called from HOMER tag directories (alternative peak caller). |
| `10_merged_peaks/replicates/` | `run_merge_replicate_peaks` (`true`) | **Step d1:** Consensus condition-level BED files (`*_replicated_peaks.bed`) keeping peaks reproducible across replicates within the same condition. |
| `10_merged_peaks/master/` | `run_merge_master_peaks` (`true`) | **Step d2:** Unified master peak lists per histone mark (`H3K4me3_master_peaks.bed`, `H3K27me3_master_peaks.bed`) combining peaks across all conditions of the same target. |
| `11_peak_quantification/` | `run_homer_annotatepeaks` (`true`) | **Step e:** Master tab-delimited spreadsheets (`*_annotated_peaks.txt`) matching every master peak to its nearest `ce11` gene, genomic feature (`Promoter-TSS`, `Exon`, etc.), and normalized tag counts per sample. |
| `12_differential_peaks/` | `run_homer_diffpeaks` (`true`) | **Step f:** Statistical pairwise comparisons (`*_differential_peaks.txt`) identifying significantly gained or lost peaks (`log2FC`, `p-value`, `FDR`) between treatment and background conditions. |
| `13_metapeak_plots/` | `run_deeptools_metapeak` (`true`) | **Step g:** Compressed signal matrices (`*_matrix.mat.gz`) and Tornado Plot PDFs (`*_metapeak_heatmap.pdf`) showing average profile curves + per-peak heatmaps ($\pm 2\text{ kb}$ around master peak centers). |
| `14_motifs/homer/` | `run_homer_findmotifs` (`true`) | **Step h1:** Interactive HTML reports (`homerResults.html`, `knownResults.html`) and motif matrices for *de novo* and known DNA sequence motifs enriched in 100-bp windows at peak centers. |
| `14_motifs/meme_streme/` | `run_meme_streme` (`true`) | **Step h2:** Extracted $\pm 50\text{ bp}$ peak-center sequences (`*.bed`, `*.fa`) and STREME HTML/XML/TSV motif discovery reports (`streme.html`, `streme.txt`, `sites.tsv`). |
| `15_summary_plots/01_peak_counts/` | `run_summary_plots` (`true`) | **Step i (QC 1):** Bar charts (`.svg`, `.png`) and summary table (`peak_counts_summary.tsv`) comparing sample peak counts (MACS2 vs. HOMER), replicated condition peaks, and master union peaks. |
| `15_summary_plots/02_genomic_features/` | `run_summary_plots` (`true`) | **Step i (QC 2):** Feature distribution bar/donut charts, TSS distance histograms (`.svg`, `.png`), and summary tables (`*_genomic_features.tsv`) per target (`H3K4me3`, `H3K27me3`). |
| `15_summary_plots/03_correlation_and_pca/` | `run_summary_plots` (`true`) | **Step i (QC 3):** Pairwise Pearson correlation heatmaps, PCA scatter plots (`.svg`, `.png`), and correlation matrices (`*_correlation_matrix.tsv`) on $\log_2(\text{Tag Count} + 1)$. |
| `15_summary_plots/04_signal_distributions/` | `run_summary_plots` (`true`) | **Step i (QC 4):** Violin/box plots of raw and length-normalized signal density, peak width histograms (`.svg`, `.png`), and summary stats (`*_signal_summary_stats.tsv`). |
| `15_summary_plots/05_differential_plots/` | `run_summary_plots` (`true`) | **Step i (QC 5):** Volcano & MA plots (`.svg`, `.png`) with top gene labels (`FDR < 0.05`, $|\log_2\text{FC}| \ge 1.0$) and ranked differential gene tables (`*_top_differential_genes.tsv`). |
| `pipeline_info/` | *(Always enabled)* | **Run Telemetry:** Nextflow execution report (`execution_report_*.html`), timeline (`execution_timeline_*.html`), trace (`execution_trace_*.txt`), workflow DAG (`pipeline_dag_*.html`), and tool versions (`software_mqc_versions.yml`). |

---

## 2. File-by-File Inventory inside `results/cut_run103026A/`

| Folder | Files Created in `cut_run103026A` | Format & How to Open / Use |
| :--- | :--- | :--- |
| **`09_peaks/macs2/`** | `L9254-0001-0001_S141_L004_peaks.{narrowPeak,xls}`, `*_summits.bed`<br>`L9254-0001-0002_S142_L004_peaks.{narrowPeak,xls}`, `*_summits.bed`<br>`L9254-0001-0004_S66_L008_peaks.{narrowPeak,xls}`, `*_summits.bed`<br>`L9254-0001-0005_S67_L008_peaks.{narrowPeak,xls}`, `*_summits.bed`<br>`L9254-0001-0006_S68_L008_peaks.{narrowPeak,xls}`, `*_summits.bed` | Load `.narrowPeak` and `_summits.bed` into IGV along with `.bw` tracks; open `.xls` in Excel or text editor. |
| **`09_peaks/homer/`** | `L9254-0001-0001_S141_L004_peaks.{txt,bed}`<br>`L9254-0001-0002_S142_L004_peaks.{txt,bed}`<br>`L9254-0001-0004_S66_L008_peaks.{txt,bed}`<br>`L9254-0001-0005_S67_L008_peaks.{txt,bed}`<br>`L9254-0001-0006_S68_L008_peaks.{txt,bed}` | Load `_peaks.bed` into IGV to compare HOMER calls against MACS2 calls. |
| **`10_merged_peaks/replicates/`** | `EV_INT_H3K4me3_replicated_peaks.bed`<br>`EV_INT_MC_H3K4me3_replicated_peaks.bed`<br>`N2_H3K4me3_replicated_peaks.bed`<br>`EV_INT_H3K27me3_replicated_peaks.bed`<br>`N2_H3K27me3_replicated_peaks.bed` | 3-column BED files of reproducible condition peaks; load into IGV or use for condition-specific intersections. |
| **`10_merged_peaks/master/`** | `H3K4me3_master_peaks.bed`<br>`H3K27me3_master_peaks.bed` | 3-column BED files representing the union feature space per histone mark used by Steps `e`, `f`, `g`, and `h`. |
| **`11_peak_quantification/`** | `H3K4me3_annotated_peaks.txt`<br>`H3K27me3_annotated_peaks.txt` | Tab-delimited master spreadsheets; open in Excel, R, or Python for gene-level filtering and normalized tag count comparisons. |
| **`12_differential_peaks/`** | `EV_INT_vs_N2_H3K4me3_differential_peaks.txt`<br>`EV_INT_MC_vs_N2_H3K4me3_differential_peaks.txt`<br>`EV_INT_vs_N2_H3K27me3_differential_peaks.txt` | Tab-delimited edgeR differential binding results; filter by the `FDR` and `Fold Change` columns at the far right. |
| **`13_metapeak_plots/`** | `H3K4me3_matrix.mat.gz`, `H3K4me3_metapeak_heatmap.pdf`<br>`H3K27me3_matrix.mat.gz`, `H3K27me3_metapeak_heatmap.pdf` | Open `*_metapeak_heatmap.pdf` in Preview/Acrobat; `.mat.gz` can be passed directly to `plotHeatmap` or `plotProfile` for custom re-plotting. |
| **`14_motifs/homer/`** | `H3K4me3_homer_motifs/` (`homerResults.html`, `knownResults.html`, `knownResults.txt`, `homerMotifs.all.motifs`)<br>`H3K27me3_homer_motifs/` (`homerResults.html`, `knownResults.html`, `knownResults.txt`, `homerMotifs.all.motifs`) | Open `homerResults.html` (*de novo* motifs) and `knownResults.html` (known TF motif screen) in a web browser. |
| **`14_motifs/meme_streme/`** | `H3K4me3_centers_PlusMinus50bp.{bed,fa}`, `H3K4me3_streme_motifs/` (`streme.html`, `streme.txt`, `sites.tsv`, `sequences.tsv`)<br>`H3K27me3_centers_PlusMinus50bp.{bed,fa}`, `H3K27me3_streme_motifs/` (`streme.html`, `streme.txt`, `sites.tsv`, `sequences.tsv`) | Open `streme.html` in a web browser to inspect ungapped *de novo* motifs; `sites.tsv` lists exact motif occurrences per peak. |
| **`15_summary_plots/`** | `01_peak_counts/peak_counts_summary.{tsv,png,svg}`<br>`02_genomic_features/{H3K4me3,H3K27me3}_genomic_features.{tsv,png,svg}`<br>`03_correlation_and_pca/{H3K4me3,H3K27me3}_correlation_pca.{png,svg}`, `*_correlation_matrix.tsv`<br>`04_signal_distributions/{H3K4me3,H3K27me3}_signal_and_width_distributions.{png,svg}`, `*_signal_summary_stats.tsv`<br>`05_differential_plots/*_volcano_ma.{png,svg}`, `*_top_differential_genes.tsv` | High-resolution `.png` for quick viewing, editable vector `.svg` for Illustrator/Inkscape figures, and `.tsv` tables for Excel. |
| **`pipeline_info/`** | `execution_report_*.html`, `execution_timeline_*.html`, `execution_trace_*.txt`, `pipeline_dag_*.html`, `software_mqc_versions.yml` | Open `.html` reports in a web browser to inspect run duration, CPU/RAM usage, and task execution timeline. |

---

## 3. Sample Mapping & Peak Counts Summary (`cut_run103026A`)

| Sample ID | Sample / Condition Name | Target | Control ID (IgG) | MACS2 Peaks (`09_peaks/macs2/`) | HOMER Peaks (`09_peaks/homer/`) | Replicate-Merged (`10_merged_peaks/replicates/`) | Master Union (`10_merged_peaks/master/`) |
| :--- | :--- | :--- | :--- | ---: | ---: | ---: | ---: |
| `L9254-0001-0001_S141_L004` | `EV_INT_H3K4me3` | `H3K4me3` | `L9254-0001-0003_S143_L004` | 8,503 | 4,169 | 8,503 | **11,709** (`H3K4me3_master_peaks.bed`) |
| `L9254-0001-0006_S68_L008` | `EV_INT_MC_H3K4me3` | `H3K4me3` | `L9254-0001-0003_S143_L004` | 7,136 | 472 | 7,136 | **11,709** (`H3K4me3_master_peaks.bed`) |
| `L9254-0001-0004_S66_L008` | `N2_H3K4me3` | `H3K4me3` | *(None)* | 5,953 | 3,173 | 5,953 | **11,709** (`H3K4me3_master_peaks.bed`) |
| `L9254-0001-0002_S142_L004` | `EV_INT_H3K27me3` | `H3K27me3` | `L9254-0001-0003_S143_L004` | 4,008 | 291 | 4,008 | **4,174** (`H3K27me3_master_peaks.bed`) |
| `L9254-0001-0005_S67_L008` | `N2_H3K27me3` | `H3K27me3` | *(None)* | 622 | 197 | 622 | **4,174** (`H3K27me3_master_peaks.bed`) |
| `L9254-0001-0003_S143_L004` | `EV_INT_IgG` | `IgG` | *(Control)* | *(Control)* | *(Control)* | *(Excluded)* | *(Excluded)* |


