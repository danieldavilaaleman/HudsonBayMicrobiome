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
####### Run your script #########################
###### Prepare .fastq.gz clean read files for gen_cov_file.sh ###### 
cp /work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz/*.fastq.gz .
gzip -d *.fastq.gz # fastq files need to be gunzip -d and with the name format _1.fastq
for item in `ls *.fastq`; do echo $item; newname=$(echo $item | sed 's/_R/_R_/g'); mv $item $newname; done # Rename the R1.fastq and R2.fastq files to R_1.fastq and R_2.fastq

###### Pre-processing ######
module load python/3.12.5
source /global/software/bioconda/init-2024-10

### filter short contigs from assembly and create the filtered file final.contigs_1000.fa
python ~/software/COMEBin/COMEBin/scripts/Filter_tooshort.py $WORKDIR/../MegaHIT_Coassembly/All_Coassembly_megahit_out/final.contigs.fa 1000

### Generate the 18 bam files mapping clean read samples to filtered final.contigs_1000.fa
cp $WORKDIR/final.contigs_1000.fa .
bash ~/software/COMEBin/COMEBin/scripts/gen_cov_file.sh -a $SCRATCH/final.contigs_1000.fa \
-o comebine.coassembly.bamfile -t 40 -m 300 *.fastq # fastq files need to be gunzip -d and with the name format _1.fastq (map all clean reads individually
# to the assembly to generate 18 sorted bam files which will be the -p attribute in run_comebin.sh)

###### Run COMEBin ######
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate pytorch
nvidia-smi

run_comebin.sh -a $SCRATCH/final.contigs_1000.fa \
-p /scratch/33931773/comebine.coassembly.bamfile/work_files/ \
-o COMEBinIndivMapping_output \
-n 6 \
-t 48
