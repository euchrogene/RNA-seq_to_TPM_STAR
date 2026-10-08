# STAR–RSEM v3.0: RNA-seq Quantification from FASTQ or SRA

*EuchroGene STAR-RSEM v3.0 - for EuchroGene members.*

Genome-based RNA-seq quantification with [STAR](https://doi.org/10.1093/bioinformatics/bts635) and [RSEM](https://doi.org/10.1186/1471-2105-12-323). Reads are aligned in splice-aware mode and abundances estimated by expectation-maximization, so multi-mapping reads are assigned probabilistically. Because alignments carry genome coordinates, the pipeline also emits **JBrowse2-ready coverage tracks** and optional splice-junction tracks.

Use **`RNA_seq_to_TPM_STAR_v.3.0`** for FASTQ-only, SRA-only and combined
FASTQ + SRA input.
SRA downloads, FASTQ conversion, trimming, alignment and quantification use the
single Docker image **`managene7/star-rsem:v3.0`**, built from **`Dockerfile`**.

With shared-index loading enabled and supported, concurrent samples within each
STAR–RSEM container invocation share one genome index. SRA batches reuse the
index files on disk; shared memory is released after each invocation. STAR writes
the transcriptome alignments that RSEM quantifies and, when requested, a genome
BAM for coverage tracks.

Output matrices use the same layout as the EuchroGene Salmon pipeline, so the two are interchangeable downstream.

---

## Installation

Requirements: Linux, a running Docker daemon accessible to the user, and enough
CPU, memory and disk space for the reference genome and current batch. SRA mode
also requires network access to NCBI. Python is required to run the source
launcher; the bundled executable runs without a separate Python installation.

Use the updated v3.0 launcher together with `managene7/star-rsem:v3.0`. The local
build instructions below create the image and executable from this source
checkout; they do not publish either artifact to a registry or repository.

### 0. Install EG_tools &nbsp; *(skip if already installed)*

```bash
wget https://github.com/euchrogene/EG_tools/raw/refs/heads/main/EG_tools
chmod 755 EG_tools
sudo mv EG_tools /usr/bin
```

### 1. Install

`EG_tools` installs the version published in the distribution repository. For
unpublished local changes, use the locally built executable shown below.
Publish `RNA_seq_to_TPM_STAR_v.3.0` in that repository before using this installer
command for the renamed executable.

```bash
sudo EG_tools install -r https://github.com/euchrogene/RNA-seq_to_TPM_STAR.git -d RNA_seq_to_TPM_STAR -e RNA_seq_to_TPM_STAR_v.3.0 -m "SRA download and RNA-seq quantification with STAR and RSEM"
```

### 2. Display installed software

```bash
EG_tools
```

### 3. Show help contents

```bash
RNA_seq_to_TPM_STAR_v.3.0 -help
```

### 4. Uninstall

```bash
sudo EG_tools uninstall -t RNA_seq_to_TPM_STAR_v.3.0 -i managene7/star-rsem:v3.0
```

---

## Quick Start

```bash
# Standard run (index is built automatically if missing)
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads -ref_seq genome.fa -gff annotation.gff

# Download SRA runs and quantify them with the same command
RNA_seq_to_TPM_STAR_v.3.0 -sra_list runs.txt -ref_seq genome.fa -gff annotation.gff

# Download FASTQ only, without a reference genome
RNA_seq_to_TPM_STAR_v.3.0 -sra_list runs.txt -download_only true

# Large server, matrices only: no genome BAM, fastest and lightest on disk
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads -ref_seq genome.fa \
    -gff annotation.gff -cores 96 -max_mem 240 -jbrowse false

# Reads already trimmed, custom output folder
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads_filtered -ref_seq genome.fa \
    -gff annotation.gff -filtering false -out project_output

# Add splice-junction bigBed tracks
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads -ref_seq genome.fa \
    -gff annotation.gff -junctions true
```

Run `RNA_seq_to_TPM_STAR_v.3.0 -help` for the full option list.
For a local build, use `./dist/RNA_seq_to_TPM_STAR_v.3.0`; for source execution, use
`python RNA_seq_to_TPM_STAR_v.3.0.py`. All examples use the same entry point.

---

## Inputs

| Input | Required | Notes |
|---|---|---|
| `-seq_folder` | FASTQ mode | Folder of FASTQ files; `.gz` read directly. Mates need `_R1`/`_R2` or `_1`/`_2`. With `-sra_list`, an existing unmanaged FASTQ folder is combined with SRA; otherwise it selects the download workspace |
| `-sra_list` | SRA mode | Text file of SRR/ERR/DRR run accessions and optional sample names |
| `-ref_seq` | quantification | Genome FASTA. The STAR/RSEM index is written beside it, so the folder must be writable |
| `-gff` | quantification | GFF3 (or GTF) matching the genome |

In FASTQ mode, use paths relative to the current working directory, which is
mounted as `/data` in Docker. SRA mode also accepts absolute paths inside that
directory and converts them to container-visible relative paths. FASTQ input
folders are read directly, without recursively scanning subdirectories.

> Choose this pipeline when you need novel splice junctions, genome coordinates, or browser tracks. For quantification alone, or when no genome exists, the Salmon pipeline is faster and lighter on memory.

---

## Combined local FASTQ and SRA input

Pass both `-seq_folder` and `-sra_list` to analyze existing local FASTQ and SRA runs
and merge their gene/transcript Count and TPM matrices. Both entry points support this.

```bash
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads -sra_list runs.txt \
    -ref_seq genome.fa -gff annotation.gff -out combined_results

# Optional dedicated SRA download workspace
RNA_seq_to_TPM_STAR_v.3.0 -seq_folder reads -sra_list runs.txt \
    -sra_folder sra_downloads -ref_seq genome.fa -gff annotation.gff \
    -out combined_results
```

- `reads` must contain FASTQ files directly (`.fastq`, `.fq`, optionally `.gz`).
  Subdirectories are not scanned. A new/empty `-seq_folder` or a managed SRA
  workspace keeps the existing SRA-only behavior.
- Mixed input downloads into `<list name>_sra_workspace` by default. `-sra_folder`
  overrides this location and is only available for mixed input. The original
  FASTQ folder, download workspace and output must be separate, non-nested folders
  inside the current working directory.
- Local samples are analyzed first in batches, followed by downloaded SRA samples;
  they use the same reference, annotation and analysis settings. Final matrix columns
  contain local samples first, followed by the SRA list order. Samples are separate
  columns; reads from the two sources are not pooled into one biological sample.
- Local and SRA sample names must be unique across both sources. A collision is an
  error before analysis or downloading; rename local files or use SRA list aliases.
- `-paired auto` detects local mates by the existing filename tokens (`_R1/_R2`,
  `_1/_2`, etc.). Files with mate tokens but no mate are rejected; use `-paired 2`
  for intentional single-end input. `-paired 1` requires pairs in both sources.
  Local filenames must use letters, digits, dots, underscores or dashes.
- Original local FASTQ are preserved under every cleanup setting. Temporary relative
  symlinks are created inside the dedicated workspace, avoiding copies of local reads.
  Mixed input uses the common resource defaults (`-cores 30`, `-max_mem 216`).
- SHA256 checksums of local files and their sample identities are recorded in
  `SRA_INPUTS.json` and `RUN_SPEC.json`. Checksumming reads the full input files on
  each invocation. Changed local input for an existing sample requires a new output
  directory. Repeat the same command to reuse completed results; failed local samples
  are attempted again on the next invocation. SRA retry rounds apply to SRA runs.
- `local_fastq_status.csv` records local sample outcomes; `sra_status.csv` records
  SRA outcomes. Incomplete local or SRA quantification returns nonzero by default;
  `-on_error continue` permits partial results. Mixed input cannot use
  `-download_only true`.

## SRA input

`RNA_seq_to_TPM_STAR_v.3.0` accepts an SRA accession list through `-sra_list`.
For SRA input it runs `prefetch → fasterq-dump → pigz` in the STAR–RSEM image,
then invokes its own FASTQ mode for AdapterRemoval, STAR and RSEM. The compiled
launcher includes both acquisition and quantification orchestration. Both stages
use `managene7/star-rsem:v3.0`, built from the single `Dockerfile`. The launcher
starts separate container invocations for each stage using this same image.

Example `runs.txt` format (replace the placeholders with real SRR/ERR/DRR run
accessions before running):

```text
# accession    sample name (optional; defaults to the accession)
<RUN_ACCESSION_1>    control_1
<RUN_ACCESSION_2>    treated_1
```

Project/experiment identifiers such as PRJNA, SRP and SRX must be expanded to run
accessions before use. Each run has a unique sample name; multiple runs belonging
to one biological sample are not automatically combined. Names that STAR would
change while parsing FASTQ filenames are rejected before downloading. Supported
mate suffix pairs are `_1,_2`, `_R1,_R2` and `.1,.2`.

```bash
# Quantify in batches; default batch size follows the planned parallelism
RNA_seq_to_TPM_STAR_v.3.0 -sra_list runs.txt -ref_seq genome.fa \
    -gff annotation.gff -out experiment_results -batch_size 4

# Download only; no reference genome or annotation required
RNA_seq_to_TPM_STAR_v.3.0 -sra_list runs.txt -download_only true

# Preserve FASTQ, SRA archives and genome BAM files
RNA_seq_to_TPM_STAR_v.3.0 -sra_list runs.txt -ref_seq genome.fa \
    -gff annotation.gff -cleanup none -keep_sra true -keep_bam true
```

SRA mode defaults to `-paired auto`, `-cores 30`, `-max_mem 216` and
`-parallel auto`. Paired and single libraries are processed in separate groups,
then combined into gene and transcript count/TPM matrices in accession-list order.
Technical reads are excluded; unpaired reads from otherwise paired runs are
discarded. A run with only one biological mate is treated as single-end.
Use `-paired 1` or `-paired 2` to require that layout for all downloaded runs.

The default `-cleanup slim` removes completed batches' downloaded FASTQ and
per-sample QC intermediates after all four matrix types are saved; extracted QC
statistics remain in `alignment_stats.csv`. Genome BAM retention is controlled
separately by `-keep_bam` (default `false`). After successful quantification,
retained SRA archives are moved to `<seq_folder>/sra_files/`. Download-only mode
keeps FASTQ and any retained archives inside their batch directories. The download workspace
must be new, empty, or created by this integrated launcher. It must be separate
from the results folder. Reference, annotation, workspace and output paths must
be inside the current working directory mounted into Docker.

Repeat the command with the same inputs to resume. Samples present in all four
saved matrix types are skipped. Reference and annotation checksums, analysis
settings, and sample-to-accession mappings are checked before reusing results;
changed inputs require a new results directory. Existing results from older
launchers without `SRA_INPUTS.json` also require a new results directory.

Downloads and quantification failures are retried up to `-retry_rounds 2` times
after the first pass. `-retries 3` controls prefetch attempts within each pass.
The command exits with a nonzero status if requested runs remain incomplete,
including in download-only mode. `-on_error continue` (or
`-continue_on_fail true`) permits partial output with exit status zero.

SRA mode adds these outputs:

| File/directory | Contents |
|---|---|
| `<list>_gene_Count_all.csv`, `<list>_gene_TPM_all.csv` | Combined gene matrices |
| `<list>_Count_all.csv`, `<list>_TPM_all.csv` | Combined transcript matrices |
| `sra_download_manifest.csv` | Latest acquisition result per requested accession |
| `sra_download_attempts.csv` | Acquisition history across processing attempts |
| `sra_status.csv`, `failed_accessions.txt` | Final status and a reusable retry list |
| `SRA_INPUTS.json`, `RUN_SPEC.json` | Input identity, parameters and observed tool versions |
| `parts/`, `batch_state.json` | Saved matrices and restart state |
| `batch_reports/` | STAR–RSEM reports for each batch and layout |
| `<list>_SRA_Download_Report.html` | Acquisition report |

In download-only mode the acquisition report, manifest, status, retry list and
`RUN_SPEC.json` are written in the download workspace; the output folder stores
the attempt history and restart state. FASTQ is stored in batch subdirectories
under `paired/` and `single/`.

## Outputs

The following layout describes local FASTQ mode. SRA mode writes the merged
matrices using the accession-list filename stem, stores quantification reports
under `batch_reports/`, and applies the retention options described above.

```
<out>/
├── <name>_gene_Count_all.csv        gene counts -> DESeq2 / WGCNA
├── <name>_gene_TPM_all.csv          gene TPM
├── <name>_Count_all.csv / _TPM_all.csv   transcript (isoform) level
├── <name>_STAR_RSEM_Report.html     QC report (alignment rates, methods)
├── <name>_Methods_Section_Draft_STAR.txt
├── <name>_tool_versions.csv         versions queried at run time
├── read_QC/                         FastQC + MultiQC
├── <sample>.genes.results / .isoforms.results / .stat/   per-sample RSEM output
├── <sample>.Log.final.out           STAR alignment summary
├── <sample>.SJ.out.tab              STAR splice junctions
├── <sample>.log                     full STAR / RSEM / samtools output for the sample
└── JBrowse2_tracks/
    ├── <sample>.genome.sorted.bam (+ .bai)
    ├── <sample>.bw                  CPM-normalized coverage
    └── <sample>.junctions.bb        splice junctions  [-junctions true]
```

All matrices: first column `Gene_ID`, one column per sample, integer counts, 1-decimal TPM. Trimmed reads and per-sample STAR working folders are removed once a sample is quantified.

---

## Key Options

| Option | Default | Purpose |
|---|---|---|
| `-out` | `<seq_folder>_RSEM_results_STAR` | Output folder name |
| `-filtering` | `true` | Adapter + quality trimming (Q20, min 25 bp) |
| `-build_index` | `auto` | Build only if missing (`true` forces a rebuild) |
| `-paired` | FASTQ: `1`; SRA: `auto` | `1` paired-end, `2` single-end; SRA `auto` detects layout |
| `-parsing_only` | `1` | `2` rebuilds matrices from existing RSEM results in FASTQ mode; cannot be combined with `-sra_list` |
| `-cores` / `-max_mem` | Both: `30` / `216` | CPU threads / RAM budget in GiB; reduced to fit the visible allocation |
| `-parallel` | `auto` | Samples aligned at once. FASTQ mode plans using the shared-index setting; SRA mode estimates a conservative limit before invoking STAR |
| `-shared_index` | `auto` | One STAR index in shared memory for all samples; `auto` falls back to per-process loading if the environment refuses it, `true` requires it, `false` disables it |
| `-on_error` | `stop` | `stop` exits with an error after the run if any sample failed; `continue` exits normally and leaves the failed samples out of the matrices |
| `-sjdb_overhang` | `100` | STAR `--sjdbOverhang`; ideally read length - 1 |
| `-jbrowse` / `-junctions` | `true` / `false` | BAM + BigWig tracks / bigBed junction tracks. `-jbrowse false` also skips writing the genome BAM |
| `-read_qc` | `true` | FastQC + MultiQC |
| `-gff_fix` | `auto` | Repair a malformed GFF3 with AGAT when needed |

SRA-specific options:

| Option | Default | Purpose |
|---|---|---|
| `-download_only` | `false` | Download and convert FASTQ without alignment |
| `-download_parallel` / `-dump_threads` | `6` / `8` | Requested concurrent runs / threads per conversion or compression process; automatically reduced to fit the common CPU/RAM budget |
| `-batch_size` | `auto` | Runs per download/quantification batch; `auto` follows `-parallel`, `0` processes all runs in one batch |
| `-retries` / `-retry_rounds` | `3` / `2` | Prefetch attempts per pass / additional processing passes for incomplete runs |
| `-skip_existing` | `true` | Reuse completed FASTQ in the current batch workspace |
| `-validate` | `false` | Validate each downloaded archive with `vdb-validate` |
| `-cleanup` | `slim` | `none`, `fastq`, `slim` or `all`; controls batch data and intermediate retention |
| `-keep_sra` / `-keep_bam` | `false` / `false` | Retain SRA archives / genome BAM files |
| `-continue_on_fail` | `false` | Allow partial results with exit status zero; equivalent to `-on_error continue` in SRA mode |

---

## Notes

- **Concurrency.** In FASTQ mode, automatic parallelism accounts for index sharing, available memory and threads. Without shared memory, automatic parallelism is capped at four samples. SRA mode sets an initial concurrency estimate; the worker recalculates it using actual index/input sizes. Explicit parallel settings are also constrained by CPU and estimated RAM. Shared memory is released after each STAR–RSEM invocation, including on failure.
- **Per-sample failures do not stop the run.** Every sample writes `<sample>.log`; a failed sample's stage and the end of its log are printed, its partial files are removed, and the remaining samples continue. The run then reports the failed samples, the HTML report lists them, and the exit code follows `-on_error`. Matrices always contain the successful samples.
- **Plant GFF3 files vary widely.** The annotation is validated before indexing: sequence names are checked against the genome, exons are reconstructed from CDS-only files, and broken `ID`/`Parent` hierarchies are repaired (gffread, then AGAT, then `rsem-gff3-to-gtf`). The converted file is exported as `<name>_EG_corrected.gtf`; pass it back with `-gff` to skip conversion next time.
- `-junctions true` builds bigBed tracks from `<sample>.SJ.out.tab`. Request these tracks during the SRA run: default `-cleanup slim` removes junction tables after saving statistics. Use `-cleanup fastq` or `none` to retain the tables, and `-keep_bam true` to retain genome BAM files.

---


These tests cover input modes, paired/single routing, retries, resume, matrix
preservation and input protection. They do not validate NCBI connectivity or the
scientific accuracy of STAR/RSEM; a real small-data run is still needed before
large-scale execution.

---

## Citation

> Dobin A, Davis CA, Schlesinger F, et al. (2013) STAR: ultrafast universal RNA-seq aligner. *Bioinformatics* 29(1): 15-21.

> Li B, Dewey CN (2011) RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. *BMC Bioinformatics* 12: 323.

> Schubert M, Lindgreen S, Orlando L (2016) AdapterRemoval v2. *BMC Research Notes* 9: 88.

> Andrews S (2010) FastQC. / Ewels P, et al. (2016) MultiQC. *Bioinformatics* 32: 3047-3048.

> Ramirez F, Ryan DP, Gruning B, et al. (2016) deepTools2. *Nucleic Acids Research* 44: W160-W165. - *when BigWig tracks are used*

> Pertea G, Pertea M (2020) GFF Utilities: GffRead and GffCompare. *F1000Research* 9: 304. / Dainat J (2024) AGAT. Zenodo. - *when the annotation is converted or repaired*

> EuchroGene STAR-RSEM Pipeline v3.0 (2026). EuchroGene, LLC.

The HTML report includes a methods draft based on run settings and available
tool-version records. Review it against the logs and experimental design before
including it in a manuscript.

**Support:** bioinformatics@euchrogene.com


