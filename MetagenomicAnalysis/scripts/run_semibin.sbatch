#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=23:00:00
#SBATCH --mem=150G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source /global/software/bioconda/init-2024-10

####### Run your script #########################
# Pre-processing
cp $WORKDIR/final.contigs_1000.fa $SCRATCH
samtools merge gen_cov_file_mergedSorted.bam /scratch/33930605/output_coverage/work_files/*.bam -@ 64 # MErge all sorted bam files created by MetaBinner/COMEBin

####### Run SemiBin2 ############################
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate semibin

SemiBin2 single_easy_bin --environment ocean \
-i final.contigs_1000.fa \
-b gen_cov_file_mergedSorted.bam \
-o SemiBin2.Indiv.Mapping
