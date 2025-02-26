#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=12:00:00
#SBATCH --mem=160G
#SBATCH --partition=cpu2023
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate metawrap-env

## BIN REFINEMENT ##
metawrap bin_refinement -o Refinement_Binning_metaWRAP -t 40 -A $WORKDIR/metabinner.output/ \
-B $WORKDIR/SemiBin2.Indiv.Mapping/ -C $WORKDIR/COMEBinIndivMapping_output/ -c 50 -x 10 -m 160
