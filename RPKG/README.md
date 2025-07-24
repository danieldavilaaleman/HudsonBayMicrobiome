# RKPG analysis for Canadian protein catalog

Steps:

1. Generation of the protein catalog of the enrichment metagenome
2. Dereplication of protein catalog
3. Functional identification of proteins
4. Mapping of global reads to protein catalog
5. Calculation RPKG

## Getting a protein catalogue of a metagenome
I used Plass to assemble a catalogue of protein sequences directly from each of the 18 enrichment metagenomic reads plus a co-assembly approach (cat all R1.fastq / R2.fastq), without the nucleic assembly step. It recovers 2 to 10 times more protein sequences from complex metagenomes than other state-of-the-art methods and can assemble huge datasets.

1. For this, I developed a Snakefile for the first step; Generation of protein catalog from enrichment metagenomics sequences. For the plass co-assembly, all the reads from each enrichment experiment were concatenated and used as input for plass assemble. ```run_

2. Next, all the plass assembly files (.faa files) from each enrichment (N = 18) plus the plass co-assembly using a concatenated file from all the enrichments (N = 1) were concateated and then clustered to obtain the dereplicated protein using easy-cluster module from mmseqs2.

