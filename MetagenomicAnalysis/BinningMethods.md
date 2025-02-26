# Binning tools implemented 
The output of the Megahit Co-assembly of the 18 enrichments and the single-enrichmet assemblies are the target of the binning into MAGs.

For Binning the output of MegaHit assembly, we used the tools [COMEBin](https://github.com/ziyewang/COMEBin), [SemiBin2](https://github.com/BigDataBiology/SemiBin), and [MetaBinner](https://github.com/ziyewang/MetaBinner).

## COMEBIN

### Installation

Conda environment for COMEBin was created following installation instrictions [here](https://github.com/ziyewang/COMEBin). With a few modifications:

```
conda create -n pytorch
conda activate pytorch
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge pytorch python=3.7.12
CONDA_OVERRIDE_CUDA="12.2" mamba install pytorch==1.10.1 torchvision==0.11.2 torchaudio==0.10.1 cudatoolkit=10.2 -c pytorch
CONDA_OVERRIDE_CUDA="12.2" mamba install pytorch==1.10.2 -c pytorch  ## REALLY Important that CUDA version and not cpu version of pytorch is installed
CONDA_OVERRIDE_CUDA="12.2" mamba install -c bioconda comebin
```

Then, I requested and interactive GPU environment to test that CUDA was succesfully installed
```
salloc -N1 -n1 -c4 --mem=25gb --gres=gpu:1 -p bigmem -t 00:10:00
```

Then crete a python file using nano ```scripts/test.cuda.gpu.py```

The output of the test should be ```CUDA is available```

### Pre-processing

Using `COMEBin/scripts/gen_cov_file.sh` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly. **NOTE: that the output are sorted bam files, whichc can be used in SemiBin2**

Single-enriched assemblies and the co-assembly of the 18 enrichments were binned independently using COMEBin. Starting with the co-assembly:

First step is to remove the contigs lower than 1,000 bp using the auxiliary scripts in `COMEBin/scripts` followed by generating .bam files required for COMEBin. 
```scripts/run_preprocessing_comebin.sbatch```

The python filter script generates ```contig_lengrh_filter1000.txt``` with the list of contiguous name and length, and the file ```final.contigs_1000.fa``` that is the input to generate bam file.

Final.contigs_1000.fa contains ***110,949 contigs.***

The next step was to generate *.bam* files of each sample fastq files to the filtered Co-Assembly fasta file **final.contigs_1000.fa**
```scripts/run_mapping_comebin.sbatch```

After getting all the sorted *.bam* files (mapping each sample read pairs to the filtered co-assembly - COMEBin sort *bam* files), **COMEBin** binning was run using ```scripts/run_binning_comebin.sbatch```

***Note***: Increasing the memory to 300 Gb solve the issue that Comebin pipeline stuck and finish the pipeline

COMEBin results:

```
Run unitem profile:	77

Followed by CheckM and then:

2025-02-11 18:14:23,074 - Final result:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv
2025-02-11 18:14:23,075 - Processing file:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/final.contigs_1000.fa
2025-02-11 18:14:23,474 - Reading Map:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv
Processing file:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/final.contigs_1000.fa
Reading Map:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv.filtersmallbins_200000.tsv
Writing bins:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/comebin_res_bins
```

The total number of bins in ```/COMEBin_output/comebin_res/comebin_res_bins``` is **235**

# SemiBin2

### Installation
Followed the same approach as before with COMEBin

```
conda create -n semibin
conda activate semibin
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge -c pytorch pytorch python=3.9
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge -c bioconda semibin=2.1.0 # I have to specify the version of SemiBin, if not downgrade Semibin to version 0.2
```

### Pre-processing
The 18 Sorted *bam* files created during COMEBin pre-processing, were merged using ***samtools*** and then used as -b parameter in SemiBin2 (To run SemiBin2, ```scripts/run_semibin.sbatch```). Filtered contig file <1Kb was used as -a parameter.

The output of SemiBin2 was:

```
[2025-02-11 13:55:31,089] INFO: Setting number of CPUs to 80
[2025-02-11 13:55:31,089] INFO: Binning for short_read
[2025-02-11 13:56:05,079] INFO: Running with GPU.
[2025-02-11 13:56:08,545] INFO: Generating training data...
[2025-02-11 14:06:51,933] INFO: Calculating coverage for every sample.
[2025-02-11 14:51:49,038] INFO: Processed: /scratch/33830640/allEnrichMappedCoassembly.bam
[2025-02-11 14:52:15,678] INFO: Start binning.
[2025-02-11 14:56:24,343] INFO: Number of bins prior to reclustering: 141
[2025-02-11 14:56:27,093] INFO: Running naive ORF finder
[2025-02-11 15:08:39,566] INFO: Number of bins after reclustering: 144
[2025-02-11 15:08:39,727] INFO: Binning finished
```

# Metabinner

The next tool implemented was [Metabinner](https://github.com/ziyewang/MetaBinner)

### Pre-processing
Generation of coverage and composition profiles was using ```MetaBinner/scripts```

Generation of the coverage profiles were using the gen_cov_file.sh from Metabinner on the filtered <1,000 contigs final assembly file. This generated 18 sorted bam files and the coverage file ```metaBinner.coverage_profile_f1k.tsv```.

Generation of composition profile was created using ```gen_kmer.py``` where ```k = 4```
```
module load python/3.12.5
source /global/software/bioconda/init-2024-10

python $WORKDIR/gen_kmer.py $WORKDIR/final.contigs_1000.fa 1000 4
```
Before running MetaBinner, **metabinner.output** directory was created and then run MetaBinner tool using ```scripts/run_metabinner.sbatch```

### Output
The output bins are stored in ```metabinner.output/metabinner_res/ensemble_res/greedy_cont_weight_3_mincomp_50.0_maxcont_15.0_bins/ensemble_3logtrans/addrefined2and3comps/greedy_cont_weight_3_mincomp_50.0_maxcont_15.0_bins```

MetaBinner generates **81 bins**

# Bin Refinement
For bin refinement, the module bin_refinement from [metaWRAP](https://github.com/bxlab/metaWRAP) was implemented using the output bins obtained from [COMEBin](https://github.com/ziyewang/COMEBin), [SemiBin2](https://github.com/BigDataBiology/SemiBin), and [MetaDecoder](https://github.com/ziyewang/MetaBinner) using ```scripts/run_metawrap.sbatch```.

The output of ***metaWRAP*** for the **Co-Assembly MAGs**: 85 bins

# QC using CheckM2
The QC of the obtained 85 bins were performed using [checkM2](https://github.com/chklovski/CheckM2) with ```scripts/run_checkm2.sbatch```

| Quality| Number of Bins |
|------- | --------------- |
|>50 comp / <10 cont| 82 |
|>70 comp / <5 cont| 52 |
|>90 comp / <5 cont| 24 |

# Remove contamination in obtained bins


# Binning of single 18 enrichment metagenomic assemblies



















