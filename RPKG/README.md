# RKPG analysis for Canadian protein catalog

Steps:

1. Generation of the protein catalog of the enrichment metagenome
2. Dereplication of protein catalog
3. Functional identification of proteins
4. Mapping of global reads to protein catalog
5. Calculation RPKG

## Getting a protein catalogue of a metagenome
I used Plass to assemble a catalogue of protein sequences directly from each of the 18 enrichment metagenomic reads plus a co-assembly approach (cat all R1.fastq / R2.fastq), without the nucleic assembly step. It recovers 2 to 10 times more protein sequences from complex metagenomes than other state-of-the-art methods and can assemble huge datasets.

1. For this, I developed a Snakefile (**Snakefile_PLASS**) for the first step; Generation of protein catalog from enrichment metagenomics sequences. For the plass co-assembly, all the reads from each enrichment experiment were concatenated and used as input for plass assemble. ```run_plass_SNAKEMAKE.sbatch```

2. Next, all the plass assembly files (.faa files) from each enrichment (N = 18) plus the plass co-assembly using a concatenated file from all the enrichments (N = 1) were concateated and then clustered to obtain the dereplicated protein using easy-cluster module from mmseqs2.
```
cat *_plass_assembly.faa > concatenated_all_plass_proteins.faa
mmseqs easy-cluster concatenated_all_plass_proteins.faa clustered_proteins tmp --min-seq-id 0.9 -c 0.95 --cov-mode 1
```
The number of protein sequences in ```concatenated_all_plass_proteins.faa``` = 122,825,777

Clustering parameters values where selected based on MMSEQS2 [TUTORIAL](https://github.com/soedinglab/MMseqs2/wiki/Tutorials)
- a maximum E-value threshold (option -e, default 10^-3) computed according to the gap-corrected Karlin-Altschul statistics;
- a minimum coverage (option -c, which is defined by the number of aligned residue pairs divided by either the maximum of the length of query/centre and target/non-centre sequences alnRes/max(qLen,tLen) (default mode, --cov-mode 0), by the length of the target/non-centre sequence alnRes/tLen (--cov-mode 1), or by the length of the query/centre alnRes/qLen (--cov-mode 2);

The output of the easy-clustering ```clustered_proteins_rep_seq.fasta``` = 5,679,443

## Annotation of the representative protein catalog
First create a DB of the representative plass protein (named: **plass_proteins_rep_DB**) and then used mmseqs2 search agains the eggNOG DB (run_mmseqs_search.sbatch)
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
where:  

 ```awk command: awk -F'\t' '$3 >= 30'```

```-F'\t'```: Sets tab as field separator    
```$3 >= 30```: Only keeps rows where the third column (alignment score) is >= 30    
```sort``` command: ```sort -t$'\t' -k1,1 -k3,3nr -k5,5g```    

```-t$'\t'```: Uses tab as field separator    
```-k1,1```: First sorts by sequence ID    
```-k3,3nr```: Then sorts by alignment score (column 3) numerically in reverse order (-nr) so highest scores come first    
```-k5,5g```: Finally sorts by E-value in ascending order using general numeric sort for scientific notation    
Second ```awk``` command: ```awk -F'\t' '!seen[$1]++'```    

Keeps only the first occurrence of each sequence ID, which will be the one with highest alignment score and lowest E-value due to our sorting

This filtering result in a tsv file with 1,910,319 rows or proteins named ```top_scoring_prot_rep_annotations_eggNOG.tsv```

***or can be filtering the best alignment matches using***

```
mmseqs filterdb Annotation_results topScoringAnnotationDB --extract-lines 1
```

This generates a DB named **topScoringAnnotationDB** which can be used for search against enrichments, environmental and mmDB fasta files to get relative abundance of each representative protein across the different samples.

## Relative abundance of PLASS representative protein catalog
To check the abundance of ORFs from raw read to the protein catalog, could be DB topScoringAnnotationDB or dereplicated marine protein catalog:
1. Create a read sequence DB from the fasta files using ```createdb```    
I copied the deep sequenced environmental files from GENICE to ~/Hudson_environmental_data and create the Site DB. ```mmseqs2 createdb``` accepts multiple FASTA files as input ```mmseqs createdb file1.fa file2.fa.gz file3.fa sequenceDB```
I need to convert the fastq.gz files to fasta files using ```seqkit fq2fa```

2. Extract the ORF from the read sequencing DB using ```extractorfs```
```mmseqs extractorfs <i:sequenceDB> <o:sequenceDB> --translation-table 11 (prokaryote) -v 3 (verbosity info)```

3. Translate the nucleotide ORFs to protein sequences using ```translatenucs```
   ```mmseqs translatenucs <i:sequenceDB> <o:sequenceDB> --translation-table 11 (prokaryote) -v 3 (verbosity info)```

4. Map the protein-translated ORFs to the dereplicated representative plass protein created from raw reads of the Enrichments (named: **plass_proteins_rep_DB**)

```mmseqs prefilter <i:queryDB> <i:targetDB> <o:prefilterDB> -s 7.5 #Sensitive mapping```    
query is the DB that you want to know (translated_ORF) and target is the DB to compare with or reference (topScoringAnnotationDB)




   


