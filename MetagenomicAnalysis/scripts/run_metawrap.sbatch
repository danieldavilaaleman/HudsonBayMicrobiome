#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=12:00:00
#SBATCH --mem=160G
#SBATCH --partition=cpu2023
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate metawrap-env

## BIN REFINEMENT ##
metawrap bin_refinement -o Refinement_Binning_metaWRAP -t 4 -A $WORKDIR/comebin_res_bins/ \
-B $WORKDIR/metadecoder.output.bins/ -C $WORKDIR/SemiBin2_output_bins/ -c 70 -x 5 -m 160

## Bin RE-Assembly ##
#metawrap reassemble_bins -o BIN_REASSEMBLY_Replicate1_raw_reads_hybrid \
#-1 CRD_H_R1_T2_CKDN240006505-1A_HCH7FDSXC_L4_1.fastq.gz \
#-2 CRD_H_R1_T2_CKDN240006505-1A_HCH7FDSXC_L4_2.fastq.gz \
#-t 8 -m 40 -c 50 -x 10 -b Refinement_Binning_Rep1_raw_reads_hybrid/metawrap_50_10_bins
