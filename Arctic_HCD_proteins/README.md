# Arctic-specific hydrocarbon-degrading protein discovery pipeline

Purpose
-------
This directory contains a reproducible pipeline and documentation to:
1. Cluster protein sequences assembled with PLASS from Arctic metagenomes.
2. Identify hydrocarbon-degrading proteins from the clustered protein set using HMM searches against the CANT‑HYD database.
3. Build an Arctic-specific hydrocarbon protein reference and map nucleotide reads from global metagenomes to that reference to test whether these protein variants are Arctic-specific.

Overview of the approach
------------------------
1. Assemble proteins from Arctic metagenomic reads with PLASS (Enrichments).
2. Cluster assembled proteins to reduce redundancy and define representative protein sequences with LINCLUST.
3. Search clustered proteins against the CANT‑HYD HMM database (HMMER `hmmsearch`) to identify hydrocarbon-degrading proteins.
4. Filter hits using the highest identify valué to create an Arctic-specific protein reference set.
5. Map nucleotide reads from global metagenomes to the Arctic protein reference using translated search (DIAMOND blastx) and quantify abundance to determine geographic specificity.
6. Perform downstream analyses (presence/absence, abundance normalization, phylogenetics, diversity metrics) to confirm Arctic specificity.

Steps for Generation of Arctic Hydrocarbon proteins
------------------------
1. Concatenation of all plass.faa files from all the enrichments (n=19 files) in "/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_assemblies/Enrichments/"

**NOTE:** This generates a file with all the proteins. Same protein ID can be shared across different protein sequences. Therefore, rename the fasta headers with sample name:

```
for file in *.faa
do name=$(basename $file _plass_assembly.faa)
echo $name
cat $file | sed "s/^>/>${name}_"/g > ${name}_plass_assembly_UHeaders.faa
done

cat *_UHeaders.faa > all_plass_assemblies_UH.faa
```

2. Clustering using mmseqs easy-linclust using a bit more stringent parameters for increase gene diversity

```
mmseqs easy-linclust $WORKDIR/all_plass_assemblies_UH.faa $WORKDIR/all.enrichments.plass tmp --min-sed-id 0.98 --cov-mode 0 -c 0.9
```

3. The representative proteins are in the file `all.enrichments.plass_rep_seq.fasta`. Total number of representative protein sequences = 70,539,633 from a total of = 117,146,334

4. To identify hydrocarbon degradation genes, CANT-HYD coupled with hmmsearch using --cut_tc for CANT_HYD.hmm and AlkB-MAB.hmm using hmmsearch -E 1e-9 --incE 1e-9 --incdomE 1e-9

5. To get the protein sequences ID identified as hydrocarbon degradation from CANT-HYD I used grep and cut on the tblout output from hmmsearch: 

```
cat hmmsearch.representative.tblout | grep "len:" | cut -f1 -d " " | sort > proteins.IDs.txt
```

6. Append the protein IDs from hhsearch.AlkB.representative.tblout, sort and remove duplicate protein IDs and extract the sequence of HCD identified proteins using the ID.txt file: 

```
cat hmmsearch.AlkB.representative.tblout | grep "len:" | cut -f1 -d " " | sort >> proteins.IDs.txt

cat proteins.IDs.txt | sort | uniq > uniq.proteins.IDs.txt

seqtk subseq all.enrichments.plass_rep_seq.fasta uniq.proteins.IDs.txt > rep_arctic.HCD.proteins.faa
```

**This created an Arctic HCD protein DB of 502 representative sequences**

Steps for Abundance quantification
------------------------
### This is the steps that were perfomred for the abundance analysis of the HCD degrading representative proteins present in the Arctic enrichements. All the quantification steps were performed with 10M reads as normalization step.
1. Generate a mmseqs database format of the rep.arctic.HCD.proteins.faa
   
```
mmseqs createdb rep_arctic.HCD.proteins.faa rep.arctic.HCD.proteins.db
```

3. Create sequencing reads database

```
mmseqs createdb /work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_assemblies/Environment/${sample_name}* $sample_name.db
```

4. Extract ORFs from the reads DB

```
mmseqs extractorfs $sample_name.db $sample_name.orfs
```

5. Translate the ORFs in AA 

```
mmseqs translatenucs $sample_name.orfs $sample_name.trans
```

6. Mapping the proteins using pre-filter

```
mmseqs prefilter $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter -s 2
```

7. Score the prefilter hits with gapless alignment

```
mmseqs rescorediagonal $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter $sample_name.rescore \
-c 1 --cov-mode 2 --min-seq-id 0.95 --rescore-mode 2 -e 0.000001 --sort-results 1
```

8. Keep the best mapping target

```
mmseqs filterdb $sample_name.rescore $sample_name.tophit --extract-lines 1
```

9. Transpose DB to create, so at the end we can create a TSV file with Protein ID as first column and number of reads mapped to that protein as second

```
mmseqs swapresults $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.tophit $sample_name.swap
```

10. Now To make the counting of the reads per protein ID I should swap the DBs in the command as well 

#NOTICE that target and query DBs are now swapped in position

```
mmseqs result2stats $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.swap $sample_name.stats --stat linecount
```

11. Now just create the TSv file using the same order of the DBs in the command

```
mmseqs createtsv $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.stats $sample_name.abundances.tsv --target-column 0
```

**You can count have many reads mapped to the Arctic HCD proteins using:**

```
for f in *.tsv; do
printf "%s\t%s\n" "$f" "$(awk -F'\t' '{sum += $3} END {print sum}' "$f")"; done
```


Steps for merging tsv files
------------------------
```
# Step 1. Sort protein ID and get column headers for summary tsv file
mkdir -p sorted_tmp

header="Protein_ID"
for f in *.tsv; do
    prefix=$(basename "$f" .tsv)
    header+=$'\t'"$prefix"
    sort -k1,1 -t$'\t' "$f" > "sorted_tmp/${prefix}.sorted"
done
echo -e "$header" > merged_counts.tsv

# Step 2. Extract the protein IDs order from one of the sorted files (in this example the first file)

first_file=$(ls sorted_tmp/*.sorted | head -n 1)
cut -f1 "$first_file" > sorted_tmp/ids.txt

# Step 3. Read and collect read count values and stored in the merge tsv file

cut_cmds=()
for f in sorted_tmp/*.sorted; do
    cut_cmds+=(<(cut -f3 "$f"))
done

paste sorted_tmp/ids.txt "${cut_cmds[@]}" >> merged_counts.tsv
```

IMPORTANT NOTES
------------------------
1. mmseqs quantification was run using only the **R1/_1** file in marinemetagenomicsDB, marinemetagenomicsDB_Arctic and in TARA datasets.
2. Some samples from marinemetagenomicsDB and marinemetagenomicsDB_Arctic contain less than 10M reads

