#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=04:00:00
#SBATCH --mem=80G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate checkm2

####### Run your script #########################
~/software/checkm2/bin/checkm2 predict --threads 40 --input $WORKDIR/Output_bins/*.fa \
--output-directory $SCRATCH/DasTool_CheckM2 \
--database_path //work/ebg_lab/referenceDatabases/checkm2/CheckM2_database/uniref100.KO.1.dmnd -x fa --remove_intermediates
