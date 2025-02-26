#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=23:00:00
#SBATCH --mem=300G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate pytorch
nvidia-smi

####### Run your script #########################
#### Pre-processing ####
cp $WORKDIR/final.contigs_1000.fa .
#bash ~/software/COMEBin/COMEBin/scripts/gen_cov_file.sh -a $SCRATCH/final.contigs_1000.fa \
-o comebine.coassembly.bamfile -t 40 -m 300 /scratch/33930474/*.fastq # fastq files need to be gunzip -d and with the name format _1.fastq (map all clean reads individually
# to the assembly to generate 18 sorted bam files which will be the -p attribute in run_comebin.sh)

#### Run COMEBin ####
run_comebin.sh -a $SCRATCH/final.contigs_1000.fa \
-p /scratch/33931773/comebine.coassembly.bamfile/work_files/ \
-o COMEBinIndivMapping_output \
-n 6 \
-t 48
