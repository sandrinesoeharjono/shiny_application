# Load packages
#options(repos = BiocManager::repositories())
library(dplyr)
library(cluster)
library(devtools)
library(ggbiplot)
library(BiocManager)
library(Biobase)
library(GEOquery)
library(reshape2)

# Load the GDS file
data <- getGEO(filename='GDS5027_full.soft.gz')

# Meta() allows us to take a look at the dataset's metadata
description <- Meta(data)$description
n_features <- Meta(data)$feature_count
n_samples <- Meta(data)$sample_count
organism <- Meta(data)$sample_organism
sample_type <- Meta(data)$sample_type
title <- Meta(data)$title
data_type <- Meta(data)$type

# Table() allows us to take a look at the expression counts
gexp_data <- Table(data)

# Drop rows with duplicate gene symbols, going from 54,675 -> 22,190 entries
gexp_data = gexp_data[order(gexp_data[,"Gene symbol"]),]
gexp_data = gexp_data[!duplicated(gexp_data$"Gene symbol"),]

# Set gene symbols as index (row names)
rownames(gexp_data) <- gexp_data$"Gene symbol"

# Select columns of interest (i.e samples)
gexp_data <- gexp_data %>%
    dplyr::select(dplyr::starts_with("GSM"))

# Take transpose of dataset (rows=samples, columns=genes)
t_gexp_data = t(gexp_data)

# 1) PCA
set.seed(1234)
pc <- prcomp(t_gexp_data, center = TRUE, scale = TRUE)
attributes(pc)

# 2) Hierarchical clustering
# Remove missing data
data_no_na <- na.omit(t_gexp_data)
# Standardize the data
df <- scale(data_no_na)
# Calculate the distance matrix
dist_mat <- dist(df, method = "euclidean")

# 3) Differential expression
# Select expression columns only
my_x = select(gexp_data, contains("GSM"))
# Convert data to ‘tall’ format
d <- melt(my_x)

# 4) GSEA
