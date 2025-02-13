For DasTool MAGs evaluation for completeness and contamination, 
CheckM2 was installed [CheckM2](https://github.com/chklovski/CheckM2) 
which improves the prediction of MAGs quality using ML. The version installed was CheckM2 version 1.0.2

For installation:
```
git clone --recursive https://github.com/chklovski/checkm2.git && cd checkm2
mamba env create -n checkm2 -f checkm2.yml
conda activate checkm2
```

After installation, CheckM2 was run for all the DasTool bins using ```script/run_checkm2.sbatch```

CheckM2 output:

```
[02/13/2025 10:25:35 AM] INFO: Running CheckM2 version 1.0.2
[02/13/2025 10:25:35 AM] INFO: Custom database path provided for predict run. Checking database at //work/ebg_lab/referenceDatabases/checkm2/CheckM2_database/uniref100.KO.1.dmnd...
[02/13/2025 10:25:50 AM] INFO: Running quality prediction workflow with 20 threads.
[02/13/2025 10:26:02 AM] INFO: Calling genes in 59 bins with 20 threads:
    Finished processing 59 of 59 (100.00%) bins.
[02/13/2025 10:28:38 AM] INFO: Calculating metadata for 59 bins with 20 threads:
    Finished processing 59 of 59 (100.00%) bin metadata.
[02/13/2025 10:28:39 AM] INFO: Annotating input genomes with DIAMOND using 20 threads
[02/13/2025 10:46:30 AM] INFO: Processing DIAMOND output
[02/13/2025 10:46:31 AM] INFO: Predicting completeness and contamination using ML models.
[02/13/2025 10:46:43 AM] INFO: Parsing all results and constructing final output table.
[02/13/2025 10:46:43 AM] INFO: CheckM2 finished successfully.
```

To count the number of "Medium Quality" MAGs >70% completenes and < 5% contamination, I used:
```
cat quality_report.tsv | awk '$2 > 70' | awk '$3 < 5'
```

CheckM2 analysis returned ***30*** Medium quality MAGs
