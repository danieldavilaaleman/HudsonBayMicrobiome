library(ggplot2)
library(maps)
library(dplyr)
library(scatterpie)

world <- map_data("world")

p <- ggplot(world, aes(long, lat)) +
    geom_map(map=world, aes(map_id=region), fill="lightgray", color="black", linewidth = 0.1) +
    coord_quickmap() + theme_bw()

### Get the df db_precense from coverM_pie.R
source("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Figures/coverM_pie.R")


#### Read HC Cant-HYD output (Manual curated) ####
hc <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/world_map/dRep_HQ_Bins_HC.csv", sep = ",",skip = 2, header = TRUE)

# Keep only values columns
hc <- hc[,1:26]
hc[is.na(hc)] <- 0

# Define the HC groups
alkanes <- c("AlkB","CYP.153.00") 
aromatics <- c("non_NdoB", "NdoB.NdoC","MAH", "TmoA", "TmoE", "DmpO")

#Select specific columns from hc. using select() function, you can use a vector with all_of() to give the names of the columns to select
mags_hc <- hc %>% select(`MAG`, all_of(alkanes), all_of(aromatics))

# Create a new data frame with HC characteristics 
mags_categories <- mags_hc %>% mutate(has_alkanes=if_any(all_of(alkanes), ~. > 0),
                   has_aromatics = if_any(all_of(aromatics), ~. > 0)
                   ) %>% mutate(Category = case_when(
                     has_alkanes & has_aromatics ~ "Both",
                     has_alkanes ~ "Alkanes",
                     has_aromatics ~ "Aromatics",
                     TRUE ~ NA_character_ # If a genome has no value > 0 in any column
                   )) %>% select(MAG, Category)

# Change colnames for proper merging with db_precense in subsequent steps
colnames(mags_categories) <- c("Genome", "HC_Group")

# Merge mags_categories and db_precense to get the sum of each HC category
hc_count <- merge(db_precense, mags_categories, by = "Genome")

# Create a summary DF with number of MAGs per Location (longitude, Latitude)
hc_count <- hc_count %>% group_by(accession, HC_Group) %>% summarise(number_of_MAGs_per_HC = n())

# Covert from long to wide format for merging with Metadata
hc_count <- spread(hc_count, HC_Group, number_of_MAGs_per_HC)

# Change the name of the columns
colnames(hc_count) <- c("accession", "Alkanes","Aromatics", "Both", "No_HD")

# Add a column with the total number of MAGs found (> 0.1% Relative abundance) in each accession
hc_count <- hc_count %>% rowwise() %>% mutate(total_MAGs_in_accession = sum(Alkanes, Both, No_HD, na.rm = TRUE))

#### Create the final data frame by merging with Longitude and latitude data frame #####
# Read Metadata from Cao.et.al 
cao_sra <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/Cao_sra_result.csv", header = TRUE)
colnames(cao_sra)[2] <- "Sample"
cao_depth <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/Cao.et.al.metadata.csv", skip = 2, header = TRUE)
cao_metadata <- merge(cao_sra, cao_depth, by = "Sample")
cao_metadata <- cao_metadata[,c(1,9,18,20,21,22)] # Keep only valuable columns
cao_metadata$Sample.Title.SRAToolKit <- noquote(cao_metadata$Sample.Title.SRAToolKit)
cao_metadata$Sample.Title.SRAToolKit <- gsub("^'|'\\.\\.\\.$", "",cao_metadata$Sample.Title.SRAToolKit) # Removes special characters from SRAToolKit column
colnames(cao_metadata) <- c("sample", "accession", "region", "depth","Longitude", "Latitude")

# Format Metadata from tara oceans and tara polar database
tara_oceans <- tara_metadata[,c(1,3,7,11,10,9)]
colnames(tara_oceans) <- c("sample", "accession", "region", "depth","Longitude", "Latitude")
tara_polar <- polar_metadata[,c(1,4,13,12,11,10)]
colnames(tara_polar) <- c("sample", "accession", "region", "depth","Longitude", "Latitude")

# Create Hudson Sampling metadata
hudson_metadata <- read.csv("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/Hudson_Sample_metadata.csv", skip = 2)
hudson_accession <- read.table("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/AGS_MicrobeCensus/Hudson_seq_metadata.txt")
hudson_metadata <- hudson_metadata[c(1:9),c(2:11)] # Remove unnecessary rows and columns
hudson_metadata <- hudson_metadata[,c(1,3,4,3,6,5)] # Get required data
colnames(hudson_metadata) <- c("sample", "date", "region", "depth","Longitude", "Latitude")
colnames(hudson_accession) <- c("Sample", "accession")
# Remove full name in accession
hudson_accession$accession <- gsub(".*Li","Li",hudson_accession$accession)
hudson_accession$accession <- gsub(".fastq.gz","",hudson_accession$accession)
# Change position of B1 and R3
temp <- hudson_accession[8,]
hudson_accession[8,] <- hudson_accession[9,]
hudson_accession[9,] <- temp
# Merge both Hudson DF, select desired columns and order
hudson_metadata <- cbind(hudson_metadata, hudson_accession)
hudson_metadata <- hudson_metadata[,c(1,8,7,2,5,6)]
colnames(hudson_metadata) <- c("sample", "accession", "region", "depth","Longitude", "Latitude")
# Last step, need to convert degree minutes seconds to decimal degrees for long, latitude
# I create a function to convert dms to decimal degrees
dms_to_decimal <- function(dms_string) {
  cleaned_string <- dms_string %>%
    gsub("°", " ", .) %>%
    gsub("'", " ", .) %>%
    gsub("\"", "", .)
    
  parts <- strsplit(cleaned_string, " ")[[1]]
  parts <- parts[parts != ""] # Remove empty strings
  
  deg <- as.numeric(parts[1])
  minutes <- as.numeric(parts[2])
  sec_hem <- parts[3]
  
  hemisphere <- substr(sec_hem, nchar(sec_hem), nchar(sec_hem))
  sec <- as.numeric(substr(sec_hem,1,nchar(sec_hem) - 1))
  
  decimal_degree <- deg + (minutes/60) + (sec / 3600)
  
  if (hemisphere %in% c("S", "W")) {
    decimal_degree <- -decimal_degree
  }
  
  return(decimal_degree)
}

hudson_metadata$Longitude <- sapply(hudson_metadata$Longitude, dms_to_decimal)
hudson_metadata$Latitude <- sapply(hudson_metadata$Latitude, dms_to_decimal)


# Concatenate all metadata df# Concatenate all metaLatitudedata df
all_metadata <- rbind(cao_metadata,tara_oceans,tara_polar, hudson_metadata)

# Create the final FD for plotting in the map by merging metadata with HC type and total number of MAGs per accession

plotting_coordinates <- merge(hc_count, all_metadata, by = "accession")

# Summary the total number of MAGS with Alkanes, Both and no_HC per Location (longitude, Latitude)
test <- plotting_coordinates %>% group_by(Longitude, Latitude) %>% summarise(total_num_of_Alkanes = sum(Alkanes, na.rm = TRUE),total_num_of_Aromatics = sum(Aromatics, na.rm = TRUE), total_both = sum(Both, na.rm = TRUE), total_no_HC = sum(No_HD, na.rm = TRUE)) %>% ungroup()

# Create percentage columns for pie chart
test2 <- test %>% 
  rowwise() %>% 
  mutate(total_MAGS_per_site = sum(total_num_of_Alkanes, total_both,total_no_HC, na.rm = TRUE),
         percentage_alkanes = ifelse(total_MAGS_per_site > 0, (total_num_of_Alkanes / total_MAGS_per_site), 0),
         percentage_aromatics = ifelse(total_MAGS_per_site > 0, (total_num_of_Aromatics / total_MAGS_per_site), 0),
         percentage_both = ifelse(total_MAGS_per_site > 0, (total_both / total_MAGS_per_site), 0),
         percentage_no_HC = ifelse(total_MAGS_per_site > 0, (total_no_HC / total_MAGS_per_site), 0),
  ) %>% 
  ungroup() 

## Plotting map with pie
test2$Longitude <- as.numeric(test2$Longitude) 
test2$Latitude <- as.numeric(test2$Latitude) 
n = 1.1
p + geom_scatterpie(aes(x=Longitude, y=Latitude, r=total_MAGS_per_site), data=test2, cols = colnames(test2[8:11]), color=NA, alpha=0.8) + geom_scatterpie_legend(test2$total_MAGS_per_site/n, x = -160, y=0)


#### Next step add X for the rest of points with no MAGs detected ###
## Using anti_join to subtract the sites 
test2$Longitude <- as.numeric(test2$Longitude)
test2$Latitude <- as.numeric(test2$Latitude)
all_metadata$Longitude <- as.numeric(all_metadata$Longitude)
all_metadata$Latitude <- as.numeric(all_metadata$Latitude)
no_mags_detected <- all_metadata %>% anti_join(test2, by = "Longitude")

# Change from character to integer Longitude and Latitude
no_mags_detected$Longitude <- as.numeric(no_mags_detected$Longitude)
no_mags_detected$Latitude <- as.numeric(no_mags_detected$Latitude)

# Plotting map with X sites (for now includes RA >0.05, modify this by coverM_RA.R and remove aromatics here because >0.1 does not contain aromatics)
p + geom_scatterpie(aes(x=Longitude, y=Latitude, r=total_MAGS_per_site/n), data=test2, cols = colnames(test2[8:11]), color=NA, alpha=0.8) + geom_scatterpie_legend(test2$total_MAGS_per_site/n, x = -160, y=0) + geom_text(data = no_mags_detected, aes(x = Longitude, y = Latitude, label = "x"))















