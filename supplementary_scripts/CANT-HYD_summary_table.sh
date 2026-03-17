for dir in */
do
dirname=${dir%/} # Remove / from dir variable
echo " Creating a summary table for $dirname" 
awk '
!/^#/ { # Skip lines that start with #
	count[$3][FILENAME]++  # For every non-commented line, grab the query name and add 1 to a counter for that query and file name
	queries[$3]
	files[FILENAME]
}
END {
	printf "Query_name"  # print formatted (no new line) 
	for (f in files) printf "\t%s", f  # %s placeholder for a string and get replaced by f
	printf "\n"
	for (q in queries) {
		printf "%s", q
		for (f in files) printf "\t%d", (count[q][f] > 0 ? count[q][f] : 0) # placeholder by a digit; condition "Is there a count for this query in this file?" "Yes, use the counter" "No, print 0 instead"
		printf "\n"
	}
}' ${dirname}/*CANT-HYD.hmmsearch.tblout > ${dirname}.summary_table.tsv
done
