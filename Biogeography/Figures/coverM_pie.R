### This code creates the pie chart of figure 1 
library(ggplot2)
library(tidyr)
library(dplyr)
library(gridExtra)
library(RColorBrewer)

# Get the path of each of the abundance files
cao <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/Cao.et.al", full.names = TRUE)
hudson <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/dereplicatedBinsVsEnvironments/coverm", full.names = TRUE)
tara <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/tara.oceans", full.names = TRUE)
polar <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/tara.polar", full.names = TRUE)

# Create a data frame with all the coverM output files
all_files <- c(cao, hudson, tara, polar)

for (i in 1:length(all_files)) {
  if (i == 1) {
    db <- read.table(all_files[i], sep = "\t", header = TRUE)
  } else {
    db_temp <- read.table(all_files[i], sep = "\t", header = TRUE)
    db <- merge(db, db_temp, by = "Genome")
  }
}

# Replace NAs with 0 and remove unmapped row
db[is.na(db)] <- 0
db <- db[-grep("unmapped",db$Genome),]

# Re-shape from wide to long
db_long <- gather(db, Sample, abundance, colnames(db)[2:ncol(db)])

# Filter samples with RA > 0.1% minimum detected level under metagenomic methods
db_precense <- db_long[db_long$abundance > 0.05,]


### Add DB metadata for each sample
# Add accession number column
db_precense$accession <- NA


# Fill accession column with sample name. This column is going to be used for grep DB column in the next steps
db_precense$accession <- gsub("\\..*","",db_precense$Sample)
db_precense$accession <- gsub("_1","", db_precense$accession)


# Add DB column
db_precense$DB <- NA


# Read metadata files
cao_metadata <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/Cao_sra_result.csv")
tara_metadata <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/tara.oceans.metadata.csv")
polar_metadata <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/tara.polar.metadata.csv")


# Fill DB column using loaded metadata
for (i in 1:nrow(db_precense)) {
  if (length(grep(db_precense$accession[i], cao_metadata$Sample.Title.SRAToolKit)) > 0) {
    db_precense$DB[i] <- "Bipolar"
  } else if (length(grep(db_precense$accession[i], tara_metadata$INSDC.run.accession.number.s.)) > 0) {
    db_precense$DB[i] <- "Tara Oceans"
  } else if (length(grep(db_precense$accession[i], polar_metadata$ENA_Run_ID)) > 0) {
    db_precense$DB[i] <- "Tara Polar"
  } else {
    db_precense$DB[i] <- "This study"
  }
}


### Create a summary table of the data
# Count the number of occurrences n() to tell how many times each genome appears
# .groups = "drop" removes the grouping structure after summary
# group by genome and percentage to calculate percent for pie chart
summary <- db_precense %>% group_by(Genome, DB) %>% summarise(n = n(), .groups = "drop") %>% group_by(Genome) %>% mutate(percentage = n / sum(n))


### Create the pie charts
# Create a list of unique Genomes
genome_list <- unique(summary$Genome)


# Create a list of unique DB
all_DB <- unique(summary$DB)
color_mapping <- setNames( c("lightcoral","skyblue", "forestgreen", "darkgoldenrod2"),all_DB)

# Create a function and lapply for create a list of plots and then plot all of them in the same figure
plot_list <- lapply(genome_list, function(genome){
  genome_data <- summary %>% filter(Genome == genome)
  print(genome_data)
  genome_data$DB <- factor(genome_data$DB, levels = names(color_mapping))
  ggplot(genome_data, aes(x = "", y = n, fill = DB)) + geom_bar(stat = "identity", width = 1) +
    coord_polar(theta = "y", start = 0) +
    theme_void() +
    labs(title = paste("Genome:", genome)) +
    theme(plot.title = element_text(hjust = 0.5)) +
    geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 10) +
    scale_fill_manual(values = color_mapping)
})


# Plot all the pie charts using grid.arrange
grid.arrange(grobs=plot_list)





