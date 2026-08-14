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
2. Cluster assembled proteins to reduce redundancy and define representative protein sequences (use mmseqs2 or CD‑HIT).
3. Search clustered proteins against the CANT‑HYD HMM database (HMMER `hmmsearch` or HH-suite `hhsearch`) to identify hydrocarbon-degrading proteins.
4. Curate and filter hits to create an Arctic-specific protein reference set (e.g., cluster at high identity thresholds and keep representative sequences).
5. Map nucleotide reads from global metagenomes to the Arctic protein reference using translated search (DIAMOND blastx) and quantify abundance to determine geographic specificity.
6. Perform downstream analyses (presence/absence, abundance normalization, phylogenetics, diversity metrics) to confirm Arctic specificity.

Directory layout (recommended)
------------------------------
- data/
  - plass/                # raw PLASS assembled protein FASTA files
  - cant-hyd/             # CANT‑HYD HMMs (downloaded)
  - metagenomes/          # nucleotide read files (fastq) from global samples
- work/
  - clustered_proteins.faa
  - protein_db_mmseqs/    # mmseqs2 DBs
  - hmm_hits.tblout
  - arctic_hydro_proteins.faa
  - diamond_db.dmnd
  - mapping_results/
- results/
  - abundance_table.tsv
  - presence_absence_matrix.tsv
  - phylogeny/
- README.md               # (this file)
- workflow/                # optional: Snakemake / Nextflow pipeline files
- env/                     # conda/env specification (recommended)

Prerequisites & recommended software
-----------------------------------
- PLASS (protein assembler)
- mmseqs2 (preferred for clustering) or CD‑HIT
- HMMER3 (`hmmsearch`) or HH-suite (`hhsearch`) — user specified CANT‑HYD uses HMMs; HMMER is standard
- DIAMOND (blastx) for translated mapping of nucleotide reads to protein references
- samtools, seqtk, fastp or similar for read QC and handling
- python / R for downstream stats and plotting
- optional: Snakemake / Nextflow for reproducibility

Example commands (templates)
---------------------------

1) Assemble proteins with PLASS
- Typical PLASS command:
  plass assemble reads.fq assembled_proteins.faa --min-length 100
Note: adapt options to your data and PLASS version.

2) Cluster proteins to reduce redundancy (mmseqs2 example)
- Create mmseqs2 DB:
  mmseqs createdb data/plass/assembled_proteins.faa work/proteinsDB tmp
- Cluster (e.g. 0.95 identity, minimum coverage 0.8):
  mmseqs cluster work/proteinsDB work/clusterRes tmp --min-seq-id 0.95 -c 0.8
- Create representative FASTA:
  mmseqs createseqfiledb work/proteinsDB work/clusterRes work/clusterRepDB
  mmseqs result2flat work/proteinsDB work/clusterRes work/clusterRepDB work/clustered_proteins.faa

Alternative: CD‑HIT
  cd-hit -i assembled_proteins.faa -o clustered_proteins.faa -c 0.95 -aS 0.8 -M 0 -T 8

3) HMM search against CANT‑HYD
- Obtain CANT‑HYD HMMs and concatenate into `CANT-HYD.hmm` (or use provided file).
- HMMER `hmmsearch` example:
  hmmpress cant-hyd/CANT-HYD.hmm
  hmmsearch --cpu 8 --tblout work/hmm_hits.tblout --domtblout work/hmm_domtblout.txt --E 1e-5 cant-hyd/CANT-HYD.hmm work/clustered_proteins.faa > work/hmmsearch.log

Notes:
- Tune E-value and domain coverage thresholds for sensitivity vs specificity.
- Optionally use HH-suite (`hhsearch`) if you prefer profile-profile matching.

4) Filter HMM hits and build Arctic hydrocarbon protein reference
- Parse `work/hmm_hits.tblout` to retain high-confidence hits (e.g., E-value <= 1e-5, domain coverage >= 0.5, bitscore cutoff per model).
- Extract matching sequences from `clustered_proteins.faa` into `work/arctic_hydro_proteins.faa`.
- Optionally re-cluster this subset at a high identity (e.g., 97–99%) to produce representative sequences.

5) Build DIAMOND database from Arctic reference
  diamond makedb --in work/arctic_hydro_proteins.faa -d work/diamond_db

6) Map nucleotide reads from global metagenomes to the protein reference using DIAMOND blastx
- Example per-sample command:
  diamond blastx -d work/diamond_db -q data/metagenomes/sampleX_R1.fastq -a work/sampleX.daa --threads 8 --sensitive --evalue 1e-5 --max-target-seqs 5
  diamond view -a work/sampleX.daa -o work/mapping_results/sampleX.m8

- From `*.m8` outputs, summarize per-target counts, coverage (if paired reads or contig-level mapping), and convert to per-million normalization (RPM/TPM/RPKM) as required.

Mapping thresholds and QC
-------------------------
- Keep conservative initial thresholds (e.g., identity >= 60–70% for short read matches plus alignment coverage >= 50%) then explore sensitivity.
- Remove low-complexity or ambiguous matches.
- Consider mapping simulated reads from Arctic and non-Arctic sources to estimate false positive rates with your thresholds.

Analysis to confirm Arctic specificity
-------------------------------------
- Presence/absence matrix: samples (rows) × protein clusters (columns).
- Define "Arctic‑specific" candidates as proteins present in Arctic samples (above abundance threshold) and absent or extremely rare in non‑Arctic global samples.
- Use abundance normalization (reads per million, TPM) to compare across samples.
- Statistical testing: Fisher’s exact test or logistic regression models to test enrichment in Arctic vs non‑Arctic samples accounting for sequencing depth.
- Phylogenetic analysis: align candidate proteins (MAFFT), build tree (IQ‑TREE or FastTree) to inspect clustering of Arctic variants and check for deep-branching Arctic clades.
- Network / clustering: visualize sequence similarity networks (e.g., using MMseqs2 or Cytoscape) to check for Arctic-specific clusters.
- Examine environmental metadata (temperature, salinity, depth) to check correlations with variant distribution.

Reproducibility & workflow
--------------------------
- Provide a reproducible workflow (Snakemake or Nextflow) that:
  - runs PLASS assembly (if raw reads provided),
  - performs clustering,
  - executes HMM searches and filtering,
  - builds DIAMOND DB,
  - maps global reads,
  - produces normalized abundance tables and presence/absence matrices,
  - runs downstream stats and generates plots.

- Provide an `env/` folder with conda environment YAML or container (Docker/Singularity) recipe including specific versions of PLASS, mmseqs2, HMMER, DIAMOND, python, R, etc.

Caveats & notes
---------------
- HMM model accuracy and thresholds strongly affect sensitivity/specificity. Validate with known positive and negative controls where possible.
- Mapping short reads to protein references via DIAMOND blastx is sensitive but can produce ambiguous hits for conserved domains; require coverage & identity thresholds and manual curation for key candidates.
- Confirm candidate Arctic specificity with phylogeny and environmental metadata—absence in databases may reflect undersampling rather than true absence.

References
----------
- PLASS: Steinegger et al.
- MMseqs2: Steinegger & Söding
- HMMER: Eddy SR
- DIAMOND: Buchfink et al.
- CANT‑HYD database

Contact
-------
If you want me to commit this README.md into the repository (branch: default), or to scaffold a Snakemake pipeline and example config, tell me which branch to use and whether you want me to add any sample config/conda env files.
