# Binning tools implemented 
The output of the Megahit Co-assembly of the 18 enrichments and the single-enrichmet assemblies are the target of the binning into MAGs.

For Binning the output of MegaHit assembly, we used the tools [COMEBin](https://github.com/ziyewang/COMEBin), [SemiBin2](https://github.com/BigDataBiology/SemiBin), and [MetaDecoder](https://github.com/liu-congcong/MetaDecoder).

## COMEBIN
### Preprocessing of Assembly data
Conda environment for COMEBin was created following installation instrictions [here](https://github.com/ziyewang/COMEBin).

1. Using `COMEBin/scripts/gen_cov_file.sh` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly.

Single-enriched assemblies and the co-assembly of the 18 enrichments were binned independently using COMEBin. Starting with the co-assembly:

First step is to remove the contigs lower than 1,000 bp using the auxiliary scripts in `COMEBin/scripts` followed by generating .bam files required for COMEBin:

```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=04:00:00
#SBATCH --mem=50G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate comebin

####### Run your script #########################
python ~/software/COMEBin/COMEBin/scripts/Filter_tooshort.py ../MegaHIT_Coassembly/All_Coassembly_megahit_out/final.contigs.fa 1000


```

The python filter script generates `contig_lengrh_filter1000.txt` with the list of contiguous name and length, and the file `final.contigs_1000.fa` that is the input to generate bam file.

Final.contigs_1000.fa contains ***110,949 contigs.***










