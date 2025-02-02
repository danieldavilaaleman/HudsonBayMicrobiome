For taxonomic classification, I used GTDB-Tk v2.4.0 with the most recent reference data version r220 with the following command

```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=08:00:00
#SBATCH --mem=100G
#SBATCH --partition=bigmem

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate gtdbtk
####### Run your script #########################
gtdbtk classify_wf --genome_dir Refinement_pypolca_DL1/metawrap_50_10_bins/ \
--out_dir gtdbtk_classify_wf --cpus 8 -x fa --skip_ani_screen
```
