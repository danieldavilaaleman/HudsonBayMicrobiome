## Here, you will find some important notes about the data analysis about abundance quantification using MMSEQS2

### LINCLUST
The initial protein clustering was performed using default parameters of `easy-linclust`. After using HMM search against the CANT-HYD.hmm --trusted_cut, this generates a representative fasta file of **502 ARCTIC HCD rep proteins**. After running the quantification of this rep proteins against a sub-sample of 10M reads of each of the enrichments raw reads, I got the following results:

| File | Number of READS |
| :--- | ---: |
| 015_E1_qc.abundances.tsv | 76 |
| 015_E2_qc.abundances.tsv | 2 |
| 016_E1_qc.abundances.tsv | 0 |
| 016_E2_qc.abundances.tsv | 1 |
| 018_E1_qc.abundances.tsv | 1889 |
| 018_E2_qc.abundances.tsv | 6 |
| 021_E1_qc.abundances.tsv | 38 |
| 021_E2_qc.abundances.tsv | 38 |
| 034_E1_qc.abundances.tsv | 35 |
| 034_E2_qc.abundances.tsv | 49 |
| 044_E1_qc.abundances.tsv | 235 |
| 044_E2_qc.abundances.tsv | 422 |
| 046_E1_qc.abundances.tsv | 12730 |
| 046_E2_qc.abundances.tsv | 14724 |
| B1_E1_qc.abundances.tsv | 3984 |
| B1_E2_qc.abundances.tsv | 4702 |
| R3_E1_qc.abundances.tsv | 3935 |
| R3_E2_qc.abundances.tsv | 8349 |

This is ODD because I was expected to have a similar number of reads in each sample.

After exploring the possibilities, I found that the rep portein fasta file is concised of 188 proteins originated from 044_ samples and 93 proteins originated from B1_ samples, with 1 rep proteins sequence from 018_, 2 rep proteins from 015_, and no rep preotein from 016_. So this results are bias toward the origin of te HCD protein. My understanding is that with default clustering values `(--min-seq-id 0.9 -c 0.8)` will decrease the diversity of HCD proteins present in all sample sites. So, I re-run the clustering with higher values in `--min-seq-id 0.98` and `-c 0.9` in order to get a better representation of HCD protein variants from all sampled sites.

This approach generates a HCD representative fasta file of **### ARCTIC HCD rep proteins**
