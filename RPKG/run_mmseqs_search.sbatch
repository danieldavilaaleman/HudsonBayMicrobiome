#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=23:00:00

####### Set environment variables ###############
#WORKDIR=`pwd`
#SCRATCH=/scratch/$SLURM_JOBID

#cd $SCRATCH

###### Pre-processing ######
module load bioconda/2024-10
#Concatenate all plass individual assemblies and the plass co-assembly in one single file
#cat *_plass_assembly.faa > concatenated_all_plass_proteins.faa

#Easy-cluster to get dereplicated representative proteins
#mmseqs easy-cluster concatenated_all_plass_proteins.faa clustered_proteins tmp --min-seq-id 0.9 -c 0.95 --cov-mode 1

###Annotating the protein catalog
#First create a DB of the representative proteins file
#mmseqs createdb clustered_proteins/clustered_proteins_rep_seq.fasta plass_proteins_rep_DB

#Download the complete eggNOG DB for annotation
#mmseqs databases eggNOG mmseqs2_DB/eggNOG_DB tmp

#Search against eggNOG DB using -s 7 for high sensitivity
#mmseqs search plass_proteins_rep_DB mmseqs2_DB/eggNOG_DB Annotation_results tmp -s 7

#Create a human-readable resukts in TSV format
#mmseqs createtsv plass_proteins_rep_DB mmseqs2_DB/eggNOG_DB Annotation_results prot_rep_annotations_results_eggNOG.tsv
mmseqs createtsv plass_proteins_rep_DB mmseqs2_DB/eggNOG_DB Annotation_results prot_rep_annotations_results_eggNOG.tsv --full-header

