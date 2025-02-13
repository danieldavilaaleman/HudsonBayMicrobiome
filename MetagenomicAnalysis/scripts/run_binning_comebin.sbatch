#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=12:00:00
#SBATCH --mem=300G  # Need to increase the memory, if not is going to stuck 
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate pytorch
nvidia-smi

####### Run your script #########################
run_comebin.sh -a final.contigs_1000.fa \
-p comebine.coassembly.bamfiles/work_files/ \
-o COMEBin_output \
-n 6 \
-t 48
