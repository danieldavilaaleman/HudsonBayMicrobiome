#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --partition=gpu-v100
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate metadecoder
nvidia-smi

####### Run your script #########################

# Step 1 - Obtain the coverage of the contigs
metadecoder coverage -b $WORKDIR/comebine.coassembly.bamfiles/work_files/*.bam -o $SCRATCH/metadecoder.coverage

# Step 2 - Map Single-copy marker genes to the assembly
metadecoder seed --threads 50 -f $WORKDIR/final.contigs_1000.fa -o $SCRATCH/metadecoder.seedsolved 

#Step 3 - Run Metadecoder algorithm to cluster contigs
metadecoder cluster -f $WORKDIR/final.contigs_1000.fa -c $SCRATCH/metadecoder.coverage \
-s $SCRATCH/metadecoder.seed -o $SCRATCH/metadecoder.bins
