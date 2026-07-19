# STAR–RSEM RNA-seq Quantification

*EuchroGene STAR-RSEM v2.0 — for EuchroGene members.*

Genome-based RNA-seq quantification with [STAR](https://doi.org/10.1093/bioinformatics/bts635) and [RSEM](https://doi.org/10.1186/1471-2105-12-323). Reads are aligned in splice-aware mode and abundances estimated by expectation-maximization, so multi-mapping reads are assigned probabilistically. Because alignments carry genome coordinates, the pipeline also emits **JBrowse2-ready coverage tracks** and optional splice-junction tracks.

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
sudo EG_tools install -r https://github.com/euchrogene/RNA-seq_to_TPM_STAR.git -d RNA-seq_to_TPM_STAR -e RNA_seq_to_TPM_STAR_v.2.0 -m "Genome-based RNA-seq quantification with STAR and RSEM"
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
| `-seq_folder` | yes | Folder of FASTQ files; `.gz` read directly. Mates need `_R1`/`_R2` or `_1`/`_2` |
| `-ref_seq` | yes | Genome FASTA. The STAR/RSEM index is written beside it, so the folder must be writable |
| `-gff` | yes | GFF3 (or GTF) matching the genome |

> Choose this pipeline when you need novel splice junctions, genome coordinates, or browser tracks. For quantification alone — or when no genome exists — the Salmon pipeline is faster and far lighter on memory.

---

## Outputs

```
<out>/
├── <name>_gene_Count_all.csv        gene counts → DESeq2 / WGCNA
├── <name>_gene_TPM_all.csv          gene TPM
├── <name>_Count_all.csv / _TPM_all.csv   transcript (isoform) level
├── <name>_STAR_RSEM_Report.html     QC report (alignment rates, methods)
├── <name>_Methods_Section_Draft_STAR.txt
├── read_QC/                         FastQC + MultiQC
├── <sample>.genes.results           per-sample RSEM output
└── JBrowse2_tracks/
    ├── <sample>.genome.sorted.bam (+ .bai)
    ├── <sample>.bw                  CPM-normalized coverage
    └── <sample>.junctions.bb        splice junctions  [-junctions true]
```

All matrices: first column `Gene_ID`, one column per sample, integer counts, 1-decimal TPM.

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
| `-parallel` | `auto` | Samples aligned at once (`1` is the most memory-safe) |
| `-sjdb_overhang` | `100` | STAR `--sjdbOverhang`; ideally read length − 1 |
| `-jbrowse` / `-junctions` | `true` / `false` | BAM + BigWig tracks / bigBed junction tracks |
| `-read_qc` | `true` | FastQC + MultiQC |
| `-gff_fix` | `auto` | Repair a malformed GFF3 with AGAT when needed |

---

## Notes

- **Memory is the main constraint.** Every parallel STAR process holds its own copy of the genome index in RAM — tens of GB for a large genome. The pipeline sizes concurrency from `-max_mem` and caps it at four samples; lower `-parallel` if memory is tight.
- **Plant GFF3 files vary widely.** The annotation is validated before indexing: sequence names are checked against the genome, exons are reconstructed from CDS-only files, and broken `ID`/`Parent` hierarchies are repaired (gffread → AGAT → `rsem-gff3-to-gtf`). The converted file is exported as `<name>_EG_corrected.gtf` — pass it back with `-gff` to skip conversion next time.
- `-junctions true` keeps STAR's intermediate files during alignment (extra disk) and removes them once the junctions are extracted.

---

## Citation

> Dobin A, Davis CA, Schlesinger F, et al. (2013) STAR: ultrafast universal RNA-seq aligner. *Bioinformatics* 29(1): 15–21.

> Li B, Dewey CN (2011) RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. *BMC Bioinformatics* 12: 323.

> Schubert M, Lindgreen S, Orlando L (2016) AdapterRemoval v2. *BMC Research Notes* 9: 88.

> Andrews S (2010) FastQC. / Ewels P, et al. (2016) MultiQC. *Bioinformatics* 32: 3047–3048.

> Ramírez F, Ryan DP, Grüning B, et al. (2016) deepTools2. *Nucleic Acids Research* 44: W160–W165. — *when BigWig tracks are used*

> Pertea G, Pertea M (2020) GFF Utilities: GffRead and GffCompare. *F1000Research* 9: 304. / Dainat J (2024) AGAT. Zenodo. — *when the annotation is converted or repaired*

> EuchroGene STAR-RSEM Pipeline v2.0 (2026). EuchroGene, LLC.

The methods section inside the HTML report is generated from the actual run settings and the tool versions queried at run time — copy it straight into a manuscript.

**Support:** bioinformatics@euchrogene.com
