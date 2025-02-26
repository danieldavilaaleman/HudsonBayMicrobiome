#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=23:00:00
#SBATCH --mem=80G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH
mkdir metabinner.output

###### Prepare .fastq.gz clean read files for gen_cov_file.sh ###### 
cp /work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz/*.fastq.gz .
gzip -d *.fastq.gz # fastq files need to be gunzip -d and with the name format _1.fastq
for item in `ls *.fastq`; do echo $item; newname=$(echo $item | sed 's/_R/_R_/g'); mv $item $newname; done # Rename the R1.fastq and R2.fastq files to R_1.fastq and R_2.fastq

##### Pre - processing #####
module load python/3.12.5
source /global/software/bioconda/init-2024-10

bash ~/software/miniconda3/envs/metabinner/bin/scripts/gen_coverage_file.sh -a $WORKDIR/final.contigs_1000.fa \
-o output_coverage -t 40 -m 80 *.fastq # This generates 18 sorted bam files that can be used as attribution in semibin2 after merge all sorted bam files 

python $WORKDIR/gen_kmer.py $WORKDIR/final.contigs_1000.fa 1000 4 # This generates the kmer file

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate metabinner

####### Run your script #########################
bash run_metabinner.sh -a $WORKDIR/final.contigs_1000.fa -o $SCRATCH/metabinner.output -d output_coverage/coverage_profile_f1k.tsv \
-k final.contigs_1000_kmer_4_f1000.csv -t 40 -s huge \
-p ~/software/miniconda3/envs/metabinner/bin
