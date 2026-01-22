# This is for EuchroGene customers.

This is a pipeline to process RNA-seq raw data using AdapterRemoval (by default), map RNA-seq reads to the target gene using STAR, and calculate TPM, FPKM, and counts using RSEM.

To use this pipeline, all RNA-seq data should be stored in a folder, and the folder path must be provided as the input to '-seq_path'.

** The input ref_seq of STAR version is the genome sequence and the GFF file (important). **

STAR is recommended to analyze RNA-seq data, but if you don't have a GFF file or it raises an error, you can use the Bowtie2 version in this repository.

The counts data can be used for PyDESeq2 in this repository.


## To install, copy and paste the following commands in a Jupyter Terminal, and execute:

1. get the installation file:
```
wget https://github.com/euchrogene/RNA-seq_to_TPM_STAR/raw/refs/heads/main/Install_RNA_seq_to_TPM_STAR.sh
```

2. install the pipeline:
```
sudo bash Install_RNA_seq_to_TPM_STAR.sh
```

3. check installation
```
pipelines # This shows installed pipelines

```
4. show help content
```
RNA_seq_to_TPM_STAR # this will show the following help contents
```

## Help contents:
```
________________________________________________________________________________________________

Pipeline: AdapterRemoval => STAR => RSEM

RSEM is a pipeline to calculate counts, TPM, and FPKM from genes or transcripts.
This pipeline fully automates RSEM from the build index through mapping and parsing RSEM results.
If you find any bugs, please email: bioinformatics@euchrogene.com

________________________________________________________________________________________________

The pipeline consists of building an index, running RSEM, and parsing RSEM results.
You can run this pipeline by following these methods:

1) simple run for paired-end sequences
   example: RNA_seq_to_TPM_STAR -seq_path RNA-seq_data -ref_seq CDS_seq.fa -build_index 2

2) skip AdapterRemoval and run all the rest of the steps: use all options
   example: RNA_seq_to_TPM_STAR -skip_filtering 2 -build_index 2 -seq_path RNA-seq_data -ref_seq CDS_seq.fa
            
3) skip build index: set '-build_index' option as '1' and use all options
   example: RNA_seq_to_TPM_STAR -build_index 1 -seq_path RNA-seq_data -ref_seq CDS_seq.fa

4) only parse RSEM results: set '-parsing_only' option as '2'
   example: RNA_seq_to_TPM_STAR -seq_path RNA-seq_data -parsing_only 2 

________________________________________________________________________________________________

Usage;

-help                       show options
-skip_filtering (option)    1: no (Default, run AdapterRemoval), 2: yes (skip filtering)
-gff            (required)  gff file name
-ref_seq        (required)  ref seq file name (index file name must be the same as ref seq name)
-seq_path       (required)  folder path that contains RNA-seqs (compressed file can be used)
-build_index    (option)    1: no (default), 2: yes
-paired         (option)    1: paired-end (default), 2: single-end 
-parsing_only   (option)    1: run all steps (default), 2: parsing the RSEM results only
-target         (option)    1: transcripts including isotypes, 2: representative genes (default is 1)
-cores          (option)    number of cores for RSEM (default is 32)
______________________________________________________________________________________________
```


# Citation

## AdapterRemoval
Lindgreen, S. AdapterRemoval: easy cleaning of next-generation sequencing reads. BMC Res Notes 5, 337 (2012). https://doi.org/10.1186/1756-0500-5-337

## STAR
Alexander Dobin, Carrie A. Davis, Felix Schlesinger, Jorg Drenkow, Chris Zaleski, Sonali Jha, Philippe Batut, Mark Chaisson, Thomas R. Gingeras, STAR: ultrafast universal RNA-seq aligner, Bioinformatics, Volume 29, Issue 1, January 2013, Pages 15–21, https://doi.org/10.1093/bioinformatics/bts635

## RSEM
Li, B., Dewey, C.N. RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. BMC Bioinformatics 12, 323 (2011). https://doi.org/10.1186/1471-2105-12-323
