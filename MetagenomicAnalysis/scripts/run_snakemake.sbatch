#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=20:00:00

####### Set environment variables ###############
#WORKDIR=`pwd`
#SCRATCH=/scratch/$SLURM_JOBID

#cd $SCRATCH

###### Pre-processing ######
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --sdm conda --cores 24
