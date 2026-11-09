# Experiment_Cut_Run_103026

CUT&RUN sequencing and downstream peak analysis workspace for *C. elegans* (`ce11`), organized into two Nextflow execution stages:
- **`Pipeline_Run/`**: Upstream alignment, deduplication, filtering, and signal track generation (`01_trim` – `08_bigwig`).
- **`Analysis_Run/`**: Downstream peak calling, replicate/master peak merging, quantification, differential binding, metapeak profiling, motif discovery, and automated QC visualizations (`09_peaks` – `15_summary_plots`).

---

## Results Directory Overview (`Analysis_Run/results/cut_run103026A/`)

The primary analysis outputs are written to `Analysis_Run/results/cut_run103026A/`. Below is the directory-by-directory breakdown, including a one-line summary of what each directory is used for, the files created, what tools calculate them, and where those tools/modules live.

```text
Analysis_Run/results/cut_run103026A/
├── 09_peaks/
│   ├── homer/
│   └── macs2/
├── 10_merged_peaks/
│   ├── replicates/
│   └── master/
├── 11_peak_quantification/
├── 12_differential_peaks/
├── 13_metapeak_plots/
├── 14_motifs/
│   ├── homer/
│   └── meme_streme/
├── 15_summary_plots/
│   ├── 01_peak_counts/
│   ├── 02_genomic_features/
│   ├── 03_correlation_and_pca/
│   ├── 04_signal_distributions/
│   └── 05_differential_plots/
└── pipeline_info/
```

---

### `09_peaks/`
- **One-liner:** Stores sample-level genomic regions of significant protein/histone enrichment (peaks) called independently for each biological sample against its matched IgG control (when available).
- **Subdirectories & Contents:**
  - **`09_peaks/macs2/`**:
    - **One-liner:** Paired-end narrowPeak calls, summit coordinates, and summary tables for each individual BAM sample.
    - **Tools & Where Calculated:**
      - **Tool:** **MACS2** (`macs2 callpeak -f BAMPE -g ce -q 0.01`, v2.2.9.1)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/macs2_callpeak/main.nf`
      - **Runtime Environment:** Docker container `quay.io/biocontainers/macs2:2.2.9.1--py39hff71179_1`
    - **Contents Created:**
      - `*_peaks.narrowPeak`: BED6+4 file containing called peak coordinates, fold-enrichment, $-\log_{10}(p)$, and $-\log_{10}(q)$ values.
      - `*_summits.bed`: 1-bp peak summit coordinates representing the point of highest fragment pileup per peak.
      - `*_peaks.xls`: Tab-delimited MACS2 summary report of peak coordinates, lengths, pileup, and statistical scores.
  - **`09_peaks/homer/`**:
    - **One-liner:** Tag-directory-based peak calls and converted BED coordinates for each sample.
    - **Tools & Where Calculated:**
      - **Tool:** **HOMER** (`findPeaks -style factor` and `pos2bed.pl`, v4.11)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/homer_findpeaks/main.nf`
      - **Helper Script:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/normalize_homer_peaks.py`
    - **Contents Created:**
      - `*_peaks.txt`: Native HOMER peak calls file with tag counts, fold-change over local/control background, and Poisson $p$-values.
      - `*_peaks.bed`: Standard 6-column BED conversion of the HOMER peak file for downstream genome browser and `bedtools` compatibility.

---

### `10_merged_peaks/`
- **One-liner:** Consolidates individual sample peaks into reproducible condition-level peak sets and a unified target-wide master peak set for cross-condition quantification.
- **Subdirectories & Contents:**
  - **`10_merged_peaks/replicates/`**:
    - **One-liner:** Consensus peak intervals per experimental condition (`EV_INT_H3K4me3`, `EV_INT_MC_H3K4me3`, `N2_H3K4me3`, `EV_INT_H3K27me3`, `N2_H3K27me3`) filtered by replicate overlap.
    - **Tools & Where Calculated:**
      - **Tool:** **awk** + **BEDTools** (`bedtools sort` | `bedtools merge -c 4 -o count_distinct`, v2.31.1)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/bedtools_merge_replicates/main.nf`
    - **Contents Created:**
      - `*_replicated_peaks.bed`: 3-column BED files of merged peak intervals retained across replicates for each condition.
  - **`10_merged_peaks/master/`**:
    - **One-liner:** Non-redundant union ("master") peak coordinates across all conditions for a given histone mark (`H3K4me3` or `H3K27me3`).
    - **Tools & Where Calculated:**
      - **Tool:** **awk** + **BEDTools** (`bedtools sort` | `bedtools merge`, v2.31.1)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/bedtools_merge_master/main.nf`
    - **Contents Created:**
      - `H3K4me3_master_peaks.bed`, `H3K27me3_master_peaks.bed`: Unified coordinate sets serving as the common feature space for peak quantification, differential analysis, metapeak heatmaps, and motif discovery.

---

### `11_peak_quantification/`
- **One-liner:** Quantifies normalized read/tag counts across every sample within the master peak set and annotates each peak with its nearest *C. elegans* (`ce11`) gene and genomic feature.
- **Tools & Where Calculated:**
  - **Tool:** **HOMER** (`annotatePeaks.pl <master_peaks.bed> ce11 -size given -d <tag_dirs...>`, v4.11)
  - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/homer_annotatepeaks/main.nf`
  - **Reference Assets:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/assets/homer_ce11/`
- **Contents Created:**
  - `H3K4me3_annotated_peaks.txt`, `H3K27me3_annotated_peaks.txt`: Tab-delimited tables listing each peak's coordinates, genomic annotation (Promoter-TSS, Exon, Intron, Intergenic, TTS), distance to nearest TSS, gene symbol/ID, and normalized tag counts per sample.

---

### `12_differential_peaks/`
- **One-liner:** Identifies statistically significant differentially enriched peaks between treatment and background conditions for each configured contrast.
- **Tools & Where Calculated:**
  - **Tool:** **HOMER** + **edgeR** (`getDifferentialPeaksReplicates.pl -genome ce11 -edgeR -balanced -all`, v4.11)
  - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/homer_getdifferentialpeaks/main.nf`
  - **Reference Assets:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/assets/homer_ce11/`
- **Contents Created:**
  - `EV_INT_vs_N2_H3K4me3_differential_peaks.txt`
  - `EV_INT_MC_vs_N2_H3K4me3_differential_peaks.txt`
  - `EV_INT_vs_N2_H3K27me3_differential_peaks.txt`
  - Each file contains all master peaks annotated with nearest-gene metadata, per-sample tag counts, $\log_2(\text{fold change})$, $p$-value, and Benjamini-Hochberg adjusted FDR.

---

### `13_metapeak_plots/`
- **One-liner:** Generates signal intensity matrices and tornado/metapeak heatmaps centered on master peaks ($\pm 2\text{ kb}$) from normalized BigWig tracks.
- **Tools & Where Calculated:**
  - **Tool:** **deepTools** (`computeMatrix reference-point --referencePoint center -a 2000 -b 2000 --binSize 20` and `plotHeatmap --colorMap inferno`, v3.5.6)
  - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/deeptools_metapeak/main.nf`
  - **Runtime Environment:** Docker container `community.wave.seqera.io/library/deeptools:3.5.6--511a2b05870b9ec3`
- **Contents Created:**
  - `H3K4me3_matrix.mat.gz`, `H3K27me3_matrix.mat.gz`: Compressed signal matrices of BigWig RPKM coverage in 20-bp bins across $\pm 2\text{ kb}$ windows around peak centers.
  - `H3K4me3_metapeak_heatmap.pdf`, `H3K27me3_metapeak_heatmap.pdf`: Publication-ready metapeak profile curves (top) and per-locus tornado heatmaps (bottom) comparing conditions side-by-side.

---

### `14_motifs/`
- **One-liner:** Performs *de novo* and known DNA sequence motif discovery underneath master peaks to identify transcription factor or chromatin-associated sequence motifs.
- **Subdirectories & Contents:**
  - **`14_motifs/homer/`**:
    - **One-liner:** *De novo* and known motif enrichment analysis in 100-bp windows centered on master peaks.
    - **Tools & Where Calculated:**
      - **Tool:** **HOMER** (`findMotifsGenome.pl <master_peaks.bed> ce11 <outdir> -size 100`, v4.9.1)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/homer_findmotifsgenome/main.nf`
      - **Reference Assets:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/assets/homer_ce11/`
    - **Contents Created:**
      - `H3K4me3_homer_motifs/` & `H3K27me3_homer_motifs/`: Directories containing `homerResults.html` (*de novo* motifs), `knownResults.html` / `knownResults.txt` (screened known motifs), position weight matrices (`homerMotifs.all.motifs`), and `seq.autonorm.tsv`.
  - **`14_motifs/meme_streme/`**:
    - **One-liner:** Ungapped *de novo* motif discovery using 100-bp peak-center sequences ($\pm 50\text{ bp}$) extracted from the `ce11` reference genome.
    - **Tools & Where Calculated:**
      - **Tool:** **awk** (peak center $\pm 50\text{ bp}$ windowing) + **MEME Suite** (`fasta-file-indexer`, `bed2fasta`, and `streme --nmotifs 20 --dna`, v5.5.7)
      - **Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/modules/local/meme_streme/main.nf`
      - **Reference Assets:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/assets/homer_ce11/data/genomes/ce11/`
    - **Contents Created:**
      - `*_centers_PlusMinus50bp.bed` & `*_centers_PlusMinus50bp.fa`: 100-bp BED intervals centered on master peaks and their extracted FASTA sequences.
      - `H3K4me3_streme_motifs/` & `H3K27me3_streme_motifs/`: Directories containing interactive `streme.html` reports, machine-readable motif matrices (`streme.txt`, `streme.xml`), and matched sequence/site tables (`sequences.tsv`, `sites.tsv`).

---

### `15_summary_plots/`
- **One-liner:** Automated quality control (QC), exploratory data analysis, and differential binding visualizations accompanied by summary TSV tables.
- **Subdirectories & Contents:**
  - **`15_summary_plots/01_peak_counts/`**:
    - **One-liner:** Compares the total number of called peaks per sample (MACS2 and HOMER), replicated condition peaks, and merged master peaks.
    - **Tools & Where Calculated:**
      - **Tool:** `plot_peak_counts.py` (Python / `matplotlib` v3.11.2)
      - **Script & Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/plot_peak_counts.py` (invoked by `modules/local/plot_peak_counts/main.nf`)
    - **Contents Created:** `peak_counts_summary.tsv`, `peak_counts_summary.png`, `peak_counts_summary.svg`.
  - **`15_summary_plots/02_genomic_features/`**:
    - **One-liner:** Summarizes the distribution of master peaks across genomic annotations (Promoter-TSS, Exon, Intron, Intergenic, TTS) and distance-to-TSS distributions.
    - **Tools & Where Calculated:**
      - **Tool:** `plot_annotated_features_qc.py` (Python / `matplotlib` v3.11.2)
      - **Script & Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/plot_annotated_features_qc.py` (invoked by `modules/local/plot_annotated_summary/main.nf`)
    - **Contents Created:** `*_genomic_features.tsv`, `*_genomic_features.png`, `*_genomic_features.svg` (for `H3K4me3` and `H3K27me3`).
  - **`15_summary_plots/03_correlation_and_pca/`**:
    - **One-liner:** Evaluates sample-to-sample reproducibility and clustering via pairwise correlation heatmaps and Principal Component Analysis (PCA) on master peak tag counts.
    - **Tools & Where Calculated:**
      - **Tool:** `plot_annotated_features_qc.py` (Python / `matplotlib` v3.11.2 / `numpy` / `scipy`)
      - **Script & Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/plot_annotated_features_qc.py` (invoked by `modules/local/plot_annotated_summary/main.nf`)
    - **Contents Created:** `*_correlation_matrix.tsv`, `*_correlation_pca.png`, `*_correlation_pca.svg`.
  - **`15_summary_plots/04_signal_distributions/`**:
    - **One-liner:** Visualizes peak width distributions and normalized tag-count signal distributions across samples for each histone mark.
    - **Tools & Where Calculated:**
      - **Tool:** `plot_annotated_features_qc.py` (Python / `matplotlib` v3.11.2)
      - **Script & Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/plot_annotated_features_qc.py` (invoked by `modules/local/plot_annotated_summary/main.nf`)
    - **Contents Created:** `*_signal_summary_stats.tsv`, `*_signal_and_width_distributions.png`, `*_signal_and_width_distributions.svg`.
  - **`15_summary_plots/05_differential_plots/`**:
    - **One-liner:** Displays Volcano plots ($\log_2\text{FC}$ vs. $-\log_{10}\text{FDR}$) and MA plots (mean expression vs. $\log_2\text{FC}$) highlighting top differentially bound genes (`FDR < 0.05`, $|\log_2\text{FC}| \ge 1.0$).
    - **Tools & Where Calculated:**
      - **Tool:** `plot_differential_volcano_ma.py` (Python / `matplotlib` v3.11.2)
      - **Script & Module Location:** `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/bin/plot_differential_volcano_ma.py` (invoked by `modules/local/plot_differential_volcano_ma/main.nf`)
    - **Contents Created:** `*_volcano_ma.png`, `*_volcano_ma.svg`, and `*_top_differential_genes.tsv` for every contrast.

---

### `pipeline_info/`
- **One-liner:** Records Nextflow execution telemetry, resource utilization, task DAGs, and exact software versions for reproducibility.
- **Tools & Where Calculated:**
  - **Tool:** **Nextflow** built-in reporting and version collection (`software_mqc_versions.yml`) configured in `/Users/dan/Code/NextFlow/Arjamand/Cut_And_Run_Analysis/nextflow.config`.
- **Contents Created:**
  - `execution_report_*.html`: Interactive summary of task completion, CPU, memory, and I/O usage.
  - `execution_timeline_*.html`: Gantt chart of parallel process execution times.
  - `execution_trace_*.txt`: Tab-delimited process execution trace (hash, exit status, runtime, RSS/VMEM).
  - `pipeline_dag_*.html`: Visual directed acyclic graph (DAG) of the workflow channels and processes.
  - `software_mqc_versions.yml`: YAML record of exact tool versions executed in each module.

---

## Upstream Results Directory (`Pipeline_Run/results/cut_run103026/`)

The upstream pipeline runs on HPC from `Pipeline_Run/` (`../nf-cutandrun-base`) and syncs its outputs to Dropbox (`/Users/dan/UMass Medical School Dropbox/Daniel Higgins/Walker_lab_shared/Bioinformatics_parent/cut_run103026A/`), which serve as the inputs (`06_index_bam`, `07_homer`, `08_bigwig`) to `Analysis_Run/`.

| Directory | One-Liner Purpose | Key Contents | Tools & Where Calculated |
| :--- | :--- | :--- | :--- |
| **`01_trim/`** | Adapter and low-quality base trimming on raw paired-end FASTQ reads. | `*_R1_paired.fq.gz`, `*_R2_paired.fq.gz` | **Trimmomatic** (`PE ILLUMINACLIP:TruSeq3-PE-2.fa:2:25:7:1:true SLIDINGWINDOW:4:10 TRAILING:3 MINLEN:10`, v0.39) at `/pi/thomas.fazzio-umw/conda/pkgs/trimmomatic-0.39-hdfd78af_2/share/trimmomatic-0.39-2/trimmomatic.jar` |
| **`02_fastqc/`** | Per-sample read quality control reports before (`original/`) and after (`trimmed/`) adapter trimming. | `*_fastqc.html`, `*_fastqc.zip` | **FastQC** (`nf-cutandrun-base` HPC environment) |
| **`02_multiqc/`** | Aggregated quality control dashboard combining FastQC, trimming, alignment, and duplication metrics. | `multiqc_report.html`, `multiqc_data/` | **MultiQC** (`nf-cutandrun-base` HPC environment) |
| **`03_align/`** | Paired-end read alignment to the *C. elegans* `ce11_ws245` reference genome. | `*_bowtieoutput.sam` | **Bowtie2** (`--very-sensitive -N 0 -X 500`) against index `/share/data/umw_biocore/genome_data/c_elegans/ce11_ws245/ce11_ws245` |
| **`04_dedup/`** | Coordinate sorting and removal of PCR/optical duplicate fragments. | `*_PicardDedup.bam` (work), `*_dup.txt` (metrics) | **Picard** (`SortSam` & `MarkDuplicates REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=LENIENT`, v2.5.0) at `/pi/thomas.fazzio-umw/Sarah/picard-tools-2.5.0/picard.jar` |
| **`05_mapq_filter/`** | Filtering out low-confidence and multi-mapping alignments below `MAPQ 10`. | `*_PicardDedup_mapqfilt.sam` | **SAMtools** (`samtools view -q 10`) |
| **`06_index_bam/`** | Final coordinate-sorted, indexed BAM alignments used for MACS2 peak calling and coverage tracks. | `*.bam`, `*.bam.bai` | **SAMtools** (`samtools view -bS`, `samtools sort`, `samtools index`) |
| **`07_homer/`** | HOMER tag directories (`tag_dir/`) and normalized bedGraph tracks (`UCSC/`) for HOMER peak calling/quantification. | `tag_dir/*/` (`tagInfo.txt`, `.tags.tsv`), `UCSC/*.ucsc.bedGraph.gz` | **HOMER** (`makeTagDirectory` & `makeUCSCfile`) at `$HOME/software/homer/bin` |
| **`08_bigwig/`** | Normalized genome-wide coverage tracks (`deepTools/` RPKM and `UCSC/` bedGraph-derived) for IGV and metapeak plots. | `deepTools/*.bw`, `UCSC/*.bw` | **deepTools** (`bamCoverage --normalizeUsing RPKM`) & **UCSC utilities** (`bedGraphToBigWig` using `/share/data/umw_biocore/genome_data/c_elegans/ce11_ws245/ce11_ws245.chrom.sizes`) |

