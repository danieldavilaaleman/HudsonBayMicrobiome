# Arctic-specific hydrocarbon-degrading protein discovery pipeline

Purpose
-------
This directory contains a reproducible pipeline and documentation to:
1. Cluster protein sequences assembled with PLASS from Arctic metagenomes.
2. Identify hydrocarbon-degrading proteins from the clustered protein set using HMM searches against the CANT‑HYD database.
3. Build an Arctic-specific hydrocarbon protein reference and map nucleotide reads from global metagenomes to that reference to test whether these protein variants are Arctic-specific.

Overview of the approach
------------------------
1. Assemble proteins (or obtain PLASS-assembled protein FASTA files) from Arctic metagenomic reads with PLASS.
2. Cluster assembled proteins to reduce redundancy and define representative protein sequences with LINCLUST.
3. Search clustered proteins against the CANT‑HYD HMM database (HMMER `hmmsearch`) to identify hydrocarbon-degrading proteins.
4. Filter hits using the highest identify valué to create an Arctic-specific protein reference set.
5. Map nucleotide reads from global metagenomes to the Arctic protein reference using translated search (DIAMOND blastx) and quantify abundance to determine geographic specificity.
6. Perform downstream analyses (presence/absence, abundance normalization, phylogenetics, diversity metrics) to confirm Arctic specificity.

Steps for Generation of Arctic Hydrocarbon proteins
------------------------
1. Concatenation of all plass.faa files from all the enrichments (n=19 files) in "/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_assemblies/Enrichments/"
2. Clustering using default parameters of mmseqs easy-cluster
3. The representative proteins are in the file "canadian.enrichments_clustered_rep_seq.fasta". Total number of protein sequences = 7,441,786
4. To identify hydrocarbon degradation genes, CANT-HYD coupled with hmmsearch using --cut_tc for CANT_HYD.hmm and -E 1e-9 --incE 1e-9 --incdomE 1e-9 fro AlkB_MAB
5. To get the protein sequences ID identified as hydrocarbon degradation from CANT-HYD I used grep and cut on the tblout output from hmmsearch: grep "len:" hmmsearch.representative.tblout | cut -f1 -d " " > canadian_HCD_proteins.db.txt
6. Appended the sequence ID of the AlkB.representative.tblout to canadian_HCD_proteins.db.txt using: grep "len:" hmmsearch.AlkB.representative.tblout | cut -f1 -d " " >> canadian_HCD_proteins.db.txt
7. Keep unique protein sequences ID using cat canadian_HCD_proteins.db.txt | sort | uniq > uniq.arctic.HCD.proteins.db.ID.txt
8. Extract the sequence of HCD identified proteins using the ID.txt file: "seqtk subseq canadian.enrichments_clustered_rep_seq.fasta uniq.arctic.HCD.proteins.db.ID.txt > rep_arctic.HCD.proteins.faa"

Steps for Abundance quantification
------------------------
#This is the steps that were perfomred for the abundance analysis of the HCD degrading representative proteins present in the Arctic enrichements
1. Generate a mmseqs database format of the rep.arctic.HCD.proteins.faa
   
`mmseqs createdb rep_arctic.HCD.proteins.faa rep.arctic.HCD.proteins.db`

3. Create sequencing reads database

`mmseqs createdb /work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_assemblies/Environment/${sample_name}* $sample_name.db`

4. Extract ORFs from the reads DB

`mmseqs extractorfs $sample_name.db $sample_name.orfs`

5. Translate the ORFs in AA 

`mmseqs translatenucs $sample_name.orfs $sample_name.trans`

6. Mapping the proteins using pre-filter

`mmseqs prefilter $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter -s 2`

7. Score the prefilter hits with gapless alignment

`mmseqs rescorediagonal $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter $sample_name.rescore \
-c 1 --cov-mode 2 --min-seq-id 0.95 --rescore-mode 2 -e 0.000001 --sort-results 1`

8. Keep the best mapping target

`mmseqs filterdb $sample_name.rescore $sample_name.tophit --extract-lines 1`

9. Transpose DB to create, so at the end we can create a TSV file with Protein ID as first column and number of reads mapped to that protein as second

`mmseqs swapresults $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.tophit $sample_name.swap`

10. Now To make the counting of the reads per protein ID I should swap the DBs in the command as well 

#NOTICE that target and query DBs are now swapped in position

`mmseqs result2stats $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.swap $sample_name.stats --stat linecount`

11. Now just create the TSv file using the same order of the DBs in the command

`mmseqs createtsv $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.stats $sample_name.abundances.tsv --target-column 0`

**You can count have many reads mapped to the Arctic HCD proteins using:**

```
for f in *.tsv; do
printf "%s\t%s\n" "$f" "$(awk -F'\t' '{sum += $3} END {print sum}' "$f")"; done
```


Steps for merging tsv files
------------------------

1. Sort protein ID and get column headers for summary tsv file
```
mkdir -p sorted_tmp

header="Protein_ID"
for f in *.tsv; do
    prefix=$(basename "$f" .tsv)
    header+=$'\t'"$prefix"
    sort -k1,1 -t$'\t' "$f" > "sorted_tmp/${prefix}.sorted"
done
echo -e "$header" > merged_counts.tsv
```
2. Extract the protein IDs order from one of the sorted files (in this example the first file)
```
first_file=$(ls sorted_tmp/*.sorted | head -n 1)
cut -f1 "$first_file" > sorted_tmp/ids.txt
```

IMPORTANT NOTES
------------------------
mmseqs quantification was run using only the **R1/_1** file in marinemetagenomicsDB, marinemetagenomicsDB_Arctic and in TARA datasets.


