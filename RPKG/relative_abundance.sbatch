#!/bin/bash
#SBATCH --partition=cpu2023
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=02-00:00:00

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID
cd $SCRATCH

## Add color to the echo messages
BOLD_GREEN='\033[1;33m'
NC='\033[0m'

###### Pre-processing #########
module load bioconda/2024-10


##### Pipeline ###########
## Downsampling 10M reads from R1 CleanData from GENICE to SCRATCH ###
while read -r line
do
echo -e "${BOLD_GREEN}Downsampling file $line to 10M reads in SCRATCH directory${NC}"
seqkit sample -p 0.9 /work/ebg_lab/gm/GENICE/elaine/CleanData/$line | seqkit head -n 10000000 > $line 
echo -e "${BOLD_GREEN}File $line downsampled${NC}"
echo -e "${BOLD_GREEN}File $line stats${NC}"
seqkit stats -a $line
done < $WORKDIR/GetDataGenice.txt


### Create mmseqs DB for each Site using the converted fasta files
for site in *R1.fastq.gz
do
echo -e "${BOLD_GREEN}Creating mmseqs DB of $site${NC}"
sitename=$(basename $site .R1.fasta)
mmseqs createdb ${site} ${sitename}.DB
echo -e "${BOLD_GREEN}mmseqs DB from $site crated${NC}"
done

### Extract ORF from each sampleDB ###
for DB in *.DB
do
echo -e "${BOLD_GREEN}Extracting ORFs from reads in $DB${NC}"
mmseqs extractorfs $DB ${DB}.ORFs --translation-table 11 -v 3
echo -e "${BOLD_GREEN}Extracted ORFs from $DB${NC}"
done

## Translate ORF from nucleotides to protein sequence ###
for ORF_DB in *DB.ORFs
do
echo -e "${BOLD_GREEN}Translate Nucleotide ORFs of $ORF_DB to aminoacids${NC}"
mmseqs translatenucs $ORF_DB ${ORF_DB}.translated --translation-table 11 -v 3
echo -e"${BOLD_GREEN}$ORF_DB translated${NC}"
done

## Mapping protien-translated ORFs DBs to eggNOG DB
for translated_DB in *DB.ORFs.translated
do
echo -e "${BOLD_GREEN}Mapping with search module $translated_DB${NC}"
mmseqs search $translated_DB \
/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/mmseqs2_DB/eggNOG_DB \
${translated_DB}.mapeggNOG tmp -s 4
echo -e "${BOLD_GREEN}$translated_DB mapped against eggNOG DB${NC}"
done


## Keep best target mapping of each read-ORF ###
echo -e "${BOLD_GREEN}Keeping the best match for each read-ORFs${NC}"
for mapped_DB in *DB.ORFs.translated.mapeggNOG.dbtype
do
	db_name=$(basename $mapped_DB .dbtype)
	mmseqs filterdb ${db_name} ${db_name}.topScoring --extract-lines 1
done


# Create the final tsv file with counts of mapped read-ORFs per COG and size of the target COG ##
echo -e "${BOLD_GREEN}Creating tab file with mapping results${NC}"
for translated_DB in *DB.ORFs.translated #translated_DB was my initial query DB
do
	base_name=$(basename $translated_DB)
	mmseqs convertalis ${translated_DB} \
		/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/mmseqs2_DB/eggNOG_DB \
		${base_name}.mapeggNOG.topScoring \
		${base_name}.mapAbundance.tab --format-mode 2

	echo -e "${BOLD_GREEN}Cut, sort, uniq, and count hits per eggNOG target sequence${NC}"
	cut -f2,14 ${base_name}.mapAbundance.tab | sort | uniq -c | sort -nr > ${base_name}.unique.tab
	single_name=$(basename $translated_DB .fastq.gz.DB.ORFs.translated)
	mv ${base_name}.unique.tab ${single_name}.unique.tab
done

## Delete all mmseqs DBs
#echo -e "${BOLD_GREEN}Deleting all DB files${NC}"
#rm *.DB.*
echo -e "${BOLD_GREEN}All done!${NC}"

