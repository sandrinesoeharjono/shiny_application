# Load packages
library(Biobase)
library(GEOquery)
#if (!requireNamespace("BiocManager", quietly = TRUE)) {
#    install.packages("BiocManager")
#    BiocManager::install(c("DESeq2", "GEOquery", "canvasXpress", "ggplot2", "clinfun", "GGally", "factoextra"))
#}

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
#head(gexp_data, 5)

# 1) PCA
library(devtools)
library(ggbiplot)
set.seed(1234)
pc <- prcomp(gexp_data, center = TRUE, scale. = TRUE)
attributes(pc)

# 2) Hierarchical clustering

# 3) Differential expression

# 4) Heatmap

# 5) GSEA
