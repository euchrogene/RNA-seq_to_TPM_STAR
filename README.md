# Update notice
The RNA_seq_to_TPM_STAR is updated to RNA_seq_to_TPM_Bowtie2_v.1.0
It generates a draft Method script for publication and fixed bugs.

# This is for EuchroGene RNA_seq_to_TPM_Bowtie2.py.

This pipeline processes raw RNA-seq data using AdapterRemoval (by default), maps RNA-seq reads to the target gene using STAR, and calculates TPM, FPKM, and counts using RSEM.

To use this pipeline, all RNA-seq data should be stored in a folder, and the folder path must be provided as the input to '-seq_folder'.

** The input ref_seq of STAR version is the genome sequence and the GFF file (important). **

STAR is recommended for analyzing RNA-seq data, but if you don't have a GFF file or it fails, you can use the Bowtie2 version in this repository.

The counts data can be used for PyDESeq2 in this repository.


## To install, copy and paste the following commands in a Jupyter Terminal, and execute:

0. Install EG_tools (*** If this is already installed, skip this step ***)
```
wget https://github.com/euchrogene/EG_tools/raw/refs/heads/main/EG_tools
sudo chmod 777 EG_tools
sudo mv EG_tools /usr/bin
```

1. install the pipeline:
```
sudo EG_tools install -r https://github.com/euchrogene/RNA-seq_to_TPM_STAR.git -d RNA_seq_to_TPM_STAR -e RNA-seq_to_TPM_STAR_v.1.0 -m "A pipeline to process RNA-seqs to get TPM, FPKM, and Count data using AdapterRemoval=>STAR=>RSEM"
```

2. display installed software
```
EG_tools

```
3. show help contents
```
RNA_seq_to_TPM_STAR_v.1.0
```

## Help contents:
```
________________________________________________________________________________________________

Pipeline: AdapterRemoval => STAR => RSEM - Production Level

RSEM is a pipeline to calculate counts, TPM, and FPKM from genes or transcripts.
This pipeline fully automates RSEM from the build index through mapping and parsing RSEM results.
If you find any bugs, please email: bioinformatics@euchrogene.com

________________________________________________________________________________________________

The pipeline consists of building an index, running RSEM, and parsing RSEM results.
You can run this pipeline by following these methods:

1) Simple run for paired-end sequences
   example: RNA_seq_to_TPM_STAR_v.1.0 -seq_folder RNA-seq_data -ref_seq CDS_seq.fa \\
            -gff annotation.gff -build_index 2

2) Skip AdapterRemoval and run all the rest of the steps
   example: RNA_seq_to_TPM_STAR_v.1.0 -skip_filtering 2 -build_index 2 -seq_folder RNA-seq_data \\
            -ref_seq CDS_seq.fa -gff annotation.gff
            
3) Skip build index and run all the rest of the steps
   example: RNA_seq_to_TPM_STAR_v.1.0 -build_index 1 -seq_folder RNA-seq_data \\
            -ref_seq CDS_seq.fa -gff annotation.gff

4) Only parse RSEM results
   example: RNA_seq_to_TPM_STAR_v.1.0 -seq_folder RNA-seq_data -parsing_only 2 

________________________________________________________________________________________________

Usage:

-help                       show options
-skip_filtering (option)    1: no (Default, run AdapterRemoval), 2: yes (skip filtering)
-build_index    (option)    1: no (default), 2: yes
-gff            (required)  GFF/GTF annotation file name
-ref_seq        (required)  reference genome file name
-seq_folder     (required)  folder name that contains RNA-seqs (compressed files supported)
-paired         (option)    1: paired-end (default), 2: single-end 
-parsing_only   (option)    1: run all steps (default), 2: parsing the RSEM results only
-target         (option)    1: transcripts including isotypes (default), 2: representative genes
-cores          (option)    number of cores for RSEM (default: 32)
______________________________________________________________________________________________
```

4. To uninstall the old version
```
sudo EG_tools uninstall -t RNA-seq_to_TPM_STAR -i managene7/rna-seq_to_tpm_deseq2:v.1.0
```

5. To uninstall the v.1.0
```
sudo EG_tools uninstall -t RNA_seq_to_TPM_STAR_v.1.0 -i managene7/rna-seq_to_tpm_deseq2:v.1.1
```

# Citation

## AdapterRemoval
Lindgreen, S. AdapterRemoval: easy cleaning of next-generation sequencing reads. BMC Res Notes 5, 337 (2012). https://doi.org/10.1186/1756-0500-5-337

## STAR
Alexander Dobin, Carrie A. Davis, Felix Schlesinger, Jorg Drenkow, Chris Zaleski, Sonali Jha, Philippe Batut, Mark Chaisson, Thomas R. Gingeras, STAR: ultrafast universal RNA-seq aligner, Bioinformatics, Volume 29, Issue 1, January 2013, Pages 15–21, https://doi.org/10.1093/bioinformatics/bts635

## RSEM
Li, B., Dewey, C.N. RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. BMC Bioinformatics 12, 323 (2011). https://doi.org/10.1186/1471-2105-12-323
