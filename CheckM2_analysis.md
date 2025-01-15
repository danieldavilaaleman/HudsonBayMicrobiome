For updated MAGs evaluation for completeness and contamination, 
I installed [CheckM2](https://github.com/chklovski/CheckM2) 
which improves the prediction of MAGs quality using ML. The version that I am using is CheckM2 version 1.0.2

For installation:
```
git clone --recursive https://github.com/chklovski/checkm2.git && cd checkm2
mamba env create -n checkm2 -f checkm2.yml
conda activate checkm2
```

After installation, I ran CheckM2 for all bins created previously with MetaBat2
```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=01:00:00
#SBATCH --mem=20G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate checkm2

####### Run your script #########################
~/software/checkm2/bin/checkm2 predict --threads 10 --input ../All_bins/*.fa --output-directory Output \
--database_path //work/ebg_lab/referenceDatabases/checkm2/CheckM2_database/uniref100.KO.1.dmnd -x fa --remove_intermediates
```

[01/15/2025 11:38:24 AM] INFO: CheckM2 finished successfully.

I created a softlink for GENICE directory using ```ln -s //work/ebg_gm/gm/GENICE/M_Bautista/maria/GENICE``` - So the output of CheckM2 is on ```/home/franciscodaniel.davi/genice/Binning_MetaBAT2/CheckM2_allBins/Output```

To count the number of "Medium Quality" MAGs >70% completenes and < 5% contamination, I used:
```
cat quality_report.tsv | awk '$2 > 70' | awk '$3 < 5'
```

CheckM2 analysis returned ***150*** Medium quality MAGs
