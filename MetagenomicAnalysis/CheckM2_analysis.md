All the bins obtained by Bin refinement module of metaWRAP were evaluation for completeness and contamination, using [CheckM2](https://github.com/chklovski/CheckM2) 
which improves the prediction of MAGs quality using ML. The version installed was CheckM2 version 1.0.2

For installation:
```
git clone --recursive https://github.com/chklovski/checkm2.git && cd checkm2
mamba env create -n checkm2 -f checkm2.yml
conda activate checkm2
```

After installation, CheckM2 was run for all the metaWRAP bins (single enrichment + co-assembly) using ```script/run_checkm2.sbatch```

CheckM2 output:

```
[03/18/2025 05:30:46 PM] INFO: Running CheckM2 version 1.0.2
[03/18/2025 05:30:46 PM] INFO: Custom database path provided for predict run. Checking database at //work/ebg_lab/referenceDatabases/checkm2/CheckM2_database/uniref100.KO.1.dmnd...
[03/18/2025 05:30:55 PM] INFO: Running quality prediction workflow with 48 threads.
[03/18/2025 05:31:51 PM] INFO: Calling genes in 228 bins with 48 threads:
    Finished processing 228 of 228 (100.00%) bins.
[03/18/2025 05:33:17 PM] INFO: Calculating metadata for 228 bins with 48 threads:
    Finished processing 228 of 228 (100.00%) bin metadata.
[03/18/2025 05:33:18 PM] INFO: Annotating input genomes with DIAMOND using 48 threads
[03/18/2025 05:40:55 PM] INFO: Processing DIAMOND output
[03/18/2025 05:40:59 PM] INFO: Predicting completeness and contamination using ML models.
[03/18/2025 05:41:14 PM] INFO: Parsing all results and constructing final output table.
[03/18/2025 05:41:15 PM] INFO: CheckM2 finished successfully.
```

To count the number of "Medium Quality" MAGs >70% completenes and < 5% contamination, I used:
```
cat quality_report.tsv | awk '$2 > 70' | awk '$3 < 5' | wc -l
```
Medium quality Bins = 167
HQ Bins (>90 completeness <5% Contamination) = 100
