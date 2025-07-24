#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --mem=150G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=23:00:00

####### Set environment variables ###############
#WORKDIR=`pwd`
#SCRATCH=/scratch/$SLURM_JOBID

#cd $SCRATCH

###### Pre-processing ######
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

#snakemake --sdm conda --cores 32
