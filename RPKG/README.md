# RKPG analysis for Canadian protein catalog

Steps:

1. Generation of the protein catalog of the enrichment metagenome
2. Dereplication of protein catalog
3. Functional identification of proteins
4. Mapping of global reads to protein catalog
5. Calculation RPKG

## Getting a protein catalogue of a metagenome
I used Plass to assemble a catalogue of protein sequences directly from each of the 18 enrichment metagenomic reads plus a co-assembly approach (cat all R1.fastq / R2.fastq), without the nucleic assembly step. It recovers 2 to 10 times more protein sequences from complex metagenomes than other state-of-the-art methods and can assemble huge datasets.

1. For this, I developed a Snakefile for the first step; Generation of protein catalog from enrichment metagenomics sequences. For the plass co-assembly, all the reads from each enrichment experiment were concatenated and used as input for plass assemble. ```run_plass_SNAKEMAKE.sbatch"

2. Next, all the plass assembly files (.faa files) from each enrichment (N = 18) plus the plass co-assembly using a concatenated file from all the enrichments (N = 1) were concateated and then clustered to obtain the dereplicated protein using easy-cluster module from mmseqs2.
```
cat *_plass_assembly.faa > concatenated_all_plass_proteins.faa
mmseqs easy-cluster concatenated_all_plass_proteins.faa clustered_proteins tmp --min-seq-id 0.9 -c 0.95 --cov-mode 1
```
The number of protein sequences in ```concatenated_all_plass_proteins.faa``` = 122,825,777

Those values where selected based on MMSEQS2 [TUTORIAL](https://github.com/soedinglab/MMseqs2/wiki/Tutorials)
- a maximum E-value threshold (option -e, default 10^-3) computed according to the gap-corrected Karlin-Altschul statistics;
- a minimum coverage (option -c, which is defined by the number of aligned residue pairs divided by either the maximum of the length of query/centre and target/non-centre sequences alnRes/max(qLen,tLen) (default mode, --cov-mode 0), by the length of the target/non-centre sequence alnRes/tLen (--cov-mode 1), or by the length of the query/centre alnRes/qLen (--cov-mode 2);

The output of the easy-clustering ```clustered_proteins_rep_seq.fasta``` = 5,679,443

## Annotation of the representative protein catalog
First create a DB of the representative plass protein and then used mmseqs2 search agains the eggNOG DB
```
mmseqs search plass_proteins_rep eggNOG Annotation_results tmp -s 7

# and convert it in human-readable TSV format
mmseqs createtsv plass_proteins_rep_DB mmseqs2_DB/eggNOG_DB  Annotation_results prot_rep_annotations_results_eggNOG.tsv
```

The output tsv file contains the following information:
1. Query sequence ID: The identifier of the sequence from the query database.
2. Target sequence ID: The identifier of the sequence from the target database that aligns with the query.
3. Alignment score: A score indicating the quality of the alignment (Smith-Waterman aligment score).
4. Sequence identity: The percentage of identical residues between the aligned regions.
5. E-value: The expected number of random matches with a score at least as good as the observed score.
6. Query start position: The starting position of the alignment on the query sequence.
7. Query end position: The ending position of the alignment on the query sequence.
8. Query length: The total length of the query sequence.
9. Target start position: The starting position of the alignment on the target sequence.
10. Target end position: The ending position of the alignment on the target sequence.
11. Target length: The total length of the target sequence.

Then,the tsv output file were filtered. 1) Remove sequence ID < 30 in aligment scoring 2) Keeping Sequence ID with the lowest E-value with the top aligment scoring using:
```
cat prot_rep_annotations_results_eggNOG.tsv | awk -F'\t' '$3 >= 30' | sort -t$'\t' -k1,1 -k3,3nr -k5,5g | awk -F'\t' '!seen[$1]++' > top_scoring_prot_rep_annotations_eggNOG.tsv
```

This filtering result in a tsv file with 1,910,319 rows or proteins named '''top_scoring_prot_rep_annotations_eggNOG.tsv'''

