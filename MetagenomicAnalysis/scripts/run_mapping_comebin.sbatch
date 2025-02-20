#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=08:00:00
#SBATCH --mem=60G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate comebin_env

####### Run your script #########################
#python ~/software/COMEBin/COMEBin/scripts/Filter_tooshort.py ../MegaHIT_Coassembly/All_Coassembly_megahit_out/final.contigs.fa 1000

bash ~/software/COMEBin/COMEBin/scripts/gen_cov_file.sh -a final.contigs_1000.fa \
-o comebine.coassembly.bamfiles -f _R1.fastq -r _R2.fastq AllEnrichmentSamples* -t 40 -m 50 -l 1000
