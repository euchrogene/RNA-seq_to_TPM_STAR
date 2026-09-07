# STAR-RSEM RNA-seq Quantification

*EuchroGene STAR-RSEM v2.0 - for EuchroGene members.*

Genome-based RNA-seq quantification with [STAR](https://doi.org/10.1093/bioinformatics/bts635) and [RSEM](https://doi.org/10.1186/1471-2105-12-323). Reads are aligned in splice-aware mode and abundances estimated by expectation-maximization, so multi-mapping reads are assigned probabilistically. Because alignments carry genome coordinates, the pipeline also emits **JBrowse2-ready coverage tracks** and optional splice-junction tracks.

One genome index is held in shared memory for the whole run, so the number of samples aligned at once is limited by threads, not by index copies in RAM. STAR writes the transcriptome alignments that RSEM quantifies and, when tracks are requested, the genome BAM; no BAM is converted back from transcript to genome coordinates.

Output matrices use the same layout as the EuchroGene Salmon pipeline, so the two are interchangeable downstream.

---

## Installation

### 0. Install EG_tools &nbsp; *(skip if already installed)*
```
wget https://github.com/euchrogene/EG_tools/raw/refs/heads/main/EG_tools
sudo chmod 777 EG_tools
sudo mv EG_tools /usr/bin
```

### 1. Install
```
sudo EG_tools install -r https://github.com/euchrogene/RNA_seq_to_TPM_STAR.git -d RNA_seq_to_TPM_STAR -e RNA_seq_to_TPM_STAR_v.2.0 -m "Genome-based RNA-seq quantification with STAR and RSEM"
```

### 2. Display installed software
```
EG_tools
```

### 3. Show help contents
```
RNA_seq_to_TPM_STAR_v.2.0
```

### 4. Uninstall
```
sudo EG_tools uninstall -t RNA_seq_to_TPM_STAR_v.2.0 -i managene7/star-rsem:v1.0
```

Docker image: `managene7/star-rsem:v1.0`

---

## Quick Start

```bash
# Standard run (index is built automatically if missing)
RNA_seq_to_TPM_STAR_v.2.0 -seq_folder reads -ref_seq genome.fa -gff annotation.gff

# Large server, matrices only: no genome BAM, fastest and lightest on disk
RNA_seq_to_TPM_STAR_v.2.0 -seq_folder reads -ref_seq genome.fa \
    -gff annotation.gff -cores 96 -max_mem 450 -jbrowse false

# Reads already trimmed, custom output folder
RNA_seq_to_TPM_STAR_v.2.0 -seq_folder reads_filtered -ref_seq genome.fa \
    -gff annotation.gff -filtering false -out 20260717_project

# Add splice-junction bigBed tracks
RNA_seq_to_TPM_STAR_v.2.0 -seq_folder reads -ref_seq genome.fa \
    -gff annotation.gff -junctions true
```

Run `RNA_seq_to_TPM_STAR_v.2.0 -help` for the full option list.

---

## Inputs

| Input | Required | Notes |
|---|---|---|
| `-seq_folder` | yes | Folder of FASTQ files; `.gz` read directly. Mates need `_R1`/`_R2` or `_1`/`_2`. In single-end mode a trailing `_1` is part of the sample name |
| `-ref_seq` | yes | Genome FASTA. The STAR/RSEM index is written beside it, so the folder must be writable |
| `-gff` | yes | GFF3 (or GTF) matching the genome |

> Choose this pipeline when you need novel splice junctions, genome coordinates, or browser tracks. For quantification alone, or when no genome exists, the Salmon pipeline is faster and lighter on memory.

---

## Outputs

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
| `-paired` | `1` | `2` for single-end |
| `-parsing_only` | `1` | `2` rebuilds matrices from existing RSEM results |
| `-cores` / `-max_mem` | `30` / `150` | CPU threads / memory budget in GB |
| `-parallel` | `auto` | Samples aligned at once. Shared index: as many as `-cores`/4 and `-max_mem` allow. Per-process fallback: limited by RAM, max 4 |
| `-shared_index` | `auto` | One STAR index in shared memory for all samples; `auto` falls back to per-process loading if the environment refuses it, `true` requires it, `false` disables it |
| `-on_error` | `stop` | `stop` exits with an error after the run if any sample failed; `continue` exits normally and leaves the failed samples out of the matrices |
| `-sjdb_overhang` | `100` | STAR `--sjdbOverhang`; ideally read length - 1 |
| `-jbrowse` / `-junctions` | `true` / `false` | BAM + BigWig tracks / bigBed junction tracks. `-jbrowse false` also skips writing the genome BAM |
| `-read_qc` | `true` | FastQC + MultiQC |
| `-gff_fix` | `auto` | Repair a malformed GFF3 with AGAT when needed |

---

## Notes

- **Concurrency.** With the shared index each STAR process needs only a few GB of buffers, so on a 100-thread server `-parallel auto` aligns up to 24 samples at once (4 threads each) within `-max_mem`. If the index cannot be shared (kernel shared-memory limits, some nested container runtimes) the pipeline says so and falls back to one index copy per process, capped at four samples; lower `-parallel` there if memory is tight. The index is released from shared memory when the run ends, including on failure.
- **Per-sample failures do not stop the run.** Every sample writes `<sample>.log`; a failed sample's stage and the end of its log are printed, its partial files are removed, and the remaining samples continue. The run then reports the failed samples, the HTML report lists them, and the exit code follows `-on_error`. Matrices always contain the successful samples.
- **Plant GFF3 files vary widely.** The annotation is validated before indexing: sequence names are checked against the genome, exons are reconstructed from CDS-only files, and broken `ID`/`Parent` hierarchies are repaired (gffread, then AGAT, then `rsem-gff3-to-gtf`). The converted file is exported as `<name>_EG_corrected.gtf`; pass it back with `-gff` to skip conversion next time.
- `-junctions true` builds bigBed tracks from the `<sample>.SJ.out.tab` files, which are kept for every run, so it can also be added to a finished results folder without re-aligning.

---

## Citation

> Dobin A, Davis CA, Schlesinger F, et al. (2013) STAR: ultrafast universal RNA-seq aligner. *Bioinformatics* 29(1): 15-21.

> Li B, Dewey CN (2011) RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. *BMC Bioinformatics* 12: 323.

> Schubert M, Lindgreen S, Orlando L (2016) AdapterRemoval v2. *BMC Research Notes* 9: 88.

> Andrews S (2010) FastQC. / Ewels P, et al. (2016) MultiQC. *Bioinformatics* 32: 3047-3048.

> Ramirez F, Ryan DP, Gruning B, et al. (2016) deepTools2. *Nucleic Acids Research* 44: W160-W165. - *when BigWig tracks are used*

> Pertea G, Pertea M (2020) GFF Utilities: GffRead and GffCompare. *F1000Research* 9: 304. / Dainat J (2024) AGAT. Zenodo. - *when the annotation is converted or repaired*

> EuchroGene STAR-RSEM Pipeline v2.0 (2026). EuchroGene, LLC.

The methods section inside the HTML report is generated from the actual run settings and the tool versions queried at run time; copy it straight into a manuscript.

**Support:** bioinformatics@euchrogene.com
