## Here, you will find some important notes about the data analysis about abundance quantification using MMSEQS2

### LINCLUST
The initial protein clustering was performed using default parameters of `easy-linclust`. After using HMM search against the CANT-HYD.hmm --trusted_cutoff, this generates a representative fasta file of **502 ARCTIC HCD rep proteins**. After running the quantification of this rep proteins against a sub-sample of 10M reads of each of the enrichments raw reads, I got the following results:

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

This approach generates a HCD representative fasta file of **2,756 ARCTIC HCD rep proteins** but still only 3 rep protein sequences of 015_, 4 rep portein sequences from 018_, and 0 from sample 016_. While having 365 from samples B1_, 592 from samples 046_, and 409 from sample R3_.

After running the quantification pipeline with this new representative proteins db, I got the following results:
| File | Number of READS |
| :--- | ---: |
| 015_E1_qc.abundances.tsv | 101 |
| 015_E2_qc.abundances.tsv | 2 |
| 016_E1_qc.abundances.tsv | 0 |
| 016_E2_qc.abundances.tsv | 1 |
| 018_E1_qc.abundances.tsv | 2191 |
| 018_E2_qc.abundances.tsv | 8 |
| 021_E1_qc.abundances.tsv | 49 |
| 021_E2_qc.abundances.tsv | 47 |
| 034_E1_qc.abundances.tsv | 38 |
| 034_E2_qc.abundances.tsv | 48 |
| 044_E1_qc.abundances.tsv | 264 |
| 044_E2_qc.abundances.tsv | 451 |
| 046_E1_qc.abundances.tsv | 13120 |
| 046_E2_qc.abundances.tsv | 15177 |
| B1_E1_qc.abundances.tsv | 4730 |
| B1_E2_qc.abundances.tsv | 5171 |
| R3_E1_qc.abundances.tsv | 4557 |
| R3_E2_qc.abundances.tsv | 8922 |

One possible explanation about this results could be the lack of HCD representative in 016 using the hmm file CANT-HYD --trusted-cutoff. I asked if the 016 plass assembly proteins contains HCD in CANT-HYD.hmm and the result was 0 sequences. Now, running again the same 016 PLASS assembly against ALKB_MAB.hmm with 1e-9 cutoff I got 626 protein identified as AlkB. Another point to consider is that with AlkB_MAB.hmm, there are some targets with <100 aa. Since AlkB length is 408 aa, I will consider only target proteins with length > 300 aa.

Applying this strategy over the representative protein (--min-seq-id 0.98 -c 9) and running AlkB-MAB.hmm, I got 19,622 target proteins identified as AlkB. After removing the target protein < 300 aa, 5,314 remained. Now this collection of AlkB proteins includes 63 proteins derived from 016_, 105 from samples 015_, and 423 from samples 018_. This protein IDs were append with IDs obtained from CANT-HYD.hmm, sorted and remove duplicates (uniq) before using seqkit to extract the sequences of the protein IDs for further quantification.

The total number of protein IDs before sorting and uniq is 2,756 + 5,314 = 8,070 protein IDs (proteins_IDs.txt -> This file contains one single column with protein IDs).

After removing duplicate values (uniq) the total number of protein IDs is 7,010. This is the number of representative Arctic proteins identified as HCD!

Here are the results of the quantification (total number of reads mapped to the 7,010 protein DBs)

| File | Number of READS |
| :--- | ---: |
| 015_E1_qc.abundances.tsv | 1813 |
| 015_E2_qc.abundances.tsv | 1458 |
| 016_E1_qc.abundances.tsv | 1554 |
| 016_E2_qc.abundances.tsv | 2035 |
| 018_E1_qc.abundances.tsv | 6878 |
| 018_E2_qc.abundances.tsv | 1871 |
| 021_E1_qc.abundances.tsv | 997 |
| 021_E2_qc.abundances.tsv | 863 |
| 034_E1_qc.abundances.tsv | 10390 |
| 034_E2_qc.abundances.tsv | 9335 |
| 044_E1_qc.abundances.tsv | 365 |
| 044_E2_qc.abundances.tsv | 740 |
| 046_E1_qc.abundances.tsv | 13823 |
| 046_E2_qc.abundances.tsv | 15272 |
| B1_E1_qc.abundances.tsv | 8426 |
| B1_E2_qc.abundances.tsv | 9822 |


This indicates that the created DB contains a diverse number of HCD proteins which can be identified using this Enrichment controls. So if an environmental sample shows a low quantification number (10<) it is not because of a Canadian protein diversity. **ONE IMPORTANT QUESTION** that reviewers can ask is that I do not see large numbers of reads in other samples in the ARCTIC or ANTARCTIC due to there would be different variants of HCD proteins in each location. SO a way to answer this question would be performing a PLASS assembly of each sample location across the ARCTIC and ANTARCTIC run against CANT-HYD and AlkB-MAB.hmm, clustering with the Canadian HCD protein DB and quantify in each location.

In the meantime, the quantification results for the environmental samples where the enrichments were inoculated are the following:

| File | Number of READS |
| :--- | ---: |
| GEN-0015-JN0518W00000-000-00..abundances.tsv | 12 |
| GEN-0016-JN0618W00000-000-00..abundances.tsv | 5 |
| GEN-0018-JN0818W00000-000-00..abundances.tsv | 6 |
| GEN-0021-JN1018W00000-000-00..abundances.tsv | 8 |
| GEN-0034-JN2018W00000-000-00..abundances.tsv | 88 |
| GEN-0044-JN2818W00000-000-00..abundances.tsv | 51 |
| GEN-0046-JL0118W00000-000-00..abundances.tsv | 27 |
| R3_AU0118_W_0_0020um_80C_11..abundances.tsv | 1 |
| X0B1_AP0918_W_0_0020um_80C_11..abundances.tsv | 1 |
