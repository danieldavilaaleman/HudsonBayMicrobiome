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

Steps
------------------------
1. Concatenation of all plass.faa files from all the enrichments (n=19 files) in "/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_assemblies/Enrichments/"
2. Clustering using default parameters of mmseqs easy-cluster
3. The representative proteins are in the file "canadian.enrichments_clustered_rep_seq.fasta". Total number of protein sequences = 7,441,786
4. To identify hydrocarbon degradation genes, CANT-HYD coupled with hmmsearch using --cut_tc for CANT_HYD.hmm and -E 1e-9 --incE 1e-9 --incdomE 1e-9 fro AlkB_MAB
5. To get the protein sequences ID identified as hydrocarbon degradation from CANT-HYD I used grep and cut on the tblout output from hmmsearch: grep "len:" hmmsearch.representative.tblout | cut -f1 -d " " > canadian_HCD_proteins.db.txt
6. Appended the sequence ID of the AlkB.representative.tblout to canadian_HCD_proteins.db.txt using: grep "len:" hmmsearch.AlkB.representative.tblout | cut -f1 -d " " >> canadian_HCD_proteins.db.txt
7. Keep unique protein sequences ID using cat canadian_HCD_proteins.db.txt | sort | uniq > uniq.arctic.HCD.proteins.db.ID.txt
8. Extract the sequence of HCD identified proteins using the ID.txt file: "seqtk subseq canadian.enrichments_clustered_rep_seq.fasta uniq.arctic.HCD.proteins.db.ID.txt > rep_arctic.HCD.proteins.faa"

