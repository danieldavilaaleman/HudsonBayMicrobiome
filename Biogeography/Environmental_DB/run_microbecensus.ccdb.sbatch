#! /bin/bash
#SBATCH --time=02:00:00
#SBATCH --account=def-chubert
#SBATCH --cpus-per-task=48
#SBATCH --mem=25G

module load python/3.11
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install -r ~/requirements.txt

for file in SRR10912852*
do
filename=$(basename -s .fastq.gz $file)
echo "Running MicrobeCensus in $filename"
run_microbe_census.py -t 48 -v $file ${filename}.AGS.out
echo "DONE"
done
