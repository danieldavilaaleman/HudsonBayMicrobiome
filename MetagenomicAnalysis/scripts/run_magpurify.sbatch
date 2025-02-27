#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=23:00:00
#SBATCH --mem=80G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate magpurify

##### SET diff color for echo messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'

##### Run MAGpurify modules ######
for bin in $WORKDIR/Indiv.Mapping.ComeBinSemiBinMetaBinner_metaWRAP/*.fa;
do name=$(basename $bin .fa) # Remove the path and .fa suffix on the bin name (output name=bin.1)
echo -e "${YELLOW} Loading $name in magpurify";
echo -e "${GREEN} Creating output directory magpurify.output.${name}"
mkdir  $SCRATCH/magpurify.output.${name}
echo -e "${GREEN} Running phylo-markers module in $name";
magpurify phylo-markers $bin $SCRATCH/magpurify.output.${name} --db /work/ebg_lab/referenceDatabases/MAGpurify-db-v1.0;
echo -e "${GREEN} Running clade-markers module in $name";
magpurify clade-markers $bin $SCRATCH/magpurify.output.${name} --db /work/ebg_lab/referenceDatabases/MAGpurify-db-v1.0;
echo -e "${GREEN} Running tetra-freq module in $name";
magpurify tetra-freq $bin $SCRATCH/magpurify.output.${name};
echo -e "${GREEN} Running gc-content module in $name";
magpurify gc-content $bin $SCRATCH/magpurify.output.${name};
echo -e "${GREEN} Running known-contam module in $name";
magpurify known-contam $bin $SCRATCH/magpurify.output.${name} --db /work/ebg_lab/referenceDatabases/MAGpurify-db-v1.0;

ls $SCRATCH/magpurify.output.${name};
echo -e "${GREEN} Running cleaning module in $name";
magpurify clean-bin $bin $SCRATCH/magpurify.output.${name} $SCRATCH/magpurify.output.${name}/${name}.cleaned.fa;
echo -e "${YELLOW} MAGpurify ran successfully in $name"
done

echo -e "${RED} DONE"
