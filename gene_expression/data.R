# Load packages
library(BiocManager)
options(repos = BiocManager::repositories())
library(dplyr)
library(tidyr)
library(cluster)
library(devtools)
library(ggbiplot)
library(Biobase)
library(GEOquery)
library(reshape2)
library(DESeq2)
library(fgsea)

# Set seed (for reproducibility purposes)
set.seed(1234)

# PREPARE DATA ###########################################################################################################

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

# PCA ####################################################################################################################
# Run PCA onto dataset
pc <- prcomp(t_gexp_data, center = TRUE, scale = TRUE)

# Proportion of variance (%) for 6 first PCs
prop_variance <- data.frame(summary(pc)$importance[2,][1:6])
colnames(prop_variance) <- c("prop_var")

# HIERARCHICAL CLUSTERING ################################################################################################
# Remove missing data
data_no_na <- na.omit(t_gexp_data)

# Standardize the data
df <- scale(data_no_na)

# Calculate the distance matrix
dist_mat <- dist(df, method = "euclidean")

# DIFFERENTIAL EXPRESSION ###############################################################################################
# TODO: use this dataset for all analyses
# Fetch count data & metadata
count_matrix <- read.csv(url("https://raw.githubusercontent.com/hbc/NGS_Data_Analysis_Course/master/sessionIII/data/Mov10_full_counts.txt"), sep = "\t", row.names = 1)
metadata <- read.csv(url("https://raw.githubusercontent.com/hbc/NGS_Data_Analysis_Course/master/sessionIII/data/Mov10_full_meta.txt"), sep = "\t", row.names = 1)

# Convert data to ‘tall’ format (for histogram)
tall_raw_gexp <- melt(count_matrix)

# Check that the sample names of count matrix match the row names of the phenotypic data (expected by DESeq2)
all(rownames(metadata) %in% colnames(count_matrix))
all(rownames(metadata) == colnames(count_matrix))

# Create DESeq2 object
dds <- DESeqDataSetFromMatrix(countData = count_matrix, colData = metadata, design = ~ sampletype)

# Pre-filter the genes that have low counts
dds <- dds[rowSums(counts(dds)) >= 10,]

# Add size factors to slot
dds <- estimateSizeFactors(dds)

# Perform differential expression analysis
dds <- DESeq(dds)
res <- results(dds)
res <- lfcShrink(dds, coef = 2, res = res, type = 'normal')

# Write results to file
DEG_df = as.data.frame(res[order(res$padj),])
write.csv(DEG_df, file = "DEG_results.csv")

# Generate normalized counts (median of ratios method)
normalized_counts <- counts(dds, normalized = TRUE)

# Convert normalized data to 'tall' format (for histogram)
tall_norm_gexp <- melt(normalized_counts)

# Select the top 20 differentially expressed genes & obtain their normalized counts
top20_sigDE <- DEG_df[head(order(DEG_df$padj), 20),]
top20_sigDE_normdf <- data.frame(normalized_counts[(rownames(normalized_counts) %in% rownames(top20_sigDE)),])
rownames(top20_sigDE_normdf) -> top20_sigDE_normdf$gene
top20_sigDE_normdf <- top20_sigDE_normdf[,c(ncol(top20_sigDE_normdf), (1:ncol(top20_sigDE_normdf)-1))] # reorder
top20_sigDE_normdfl <- top20_sigDE_normdf %>% 
    gather("Sample", "Normalized_Counts", (colnames(top20_sigDE_normdf)[-1]))

# Correct for different metadata factors such that different replicates are considered in the same group
metadata -> mov10_meta
rownames(metadata) -> mov10_meta$Sample
top20_sigDE_normdfl <- inner_join(mov10_meta, top20_sigDE_normdfl, multiple = "all")

# Select the top 100 differentially expressed genes
top100_sigDE <- DEG_df[head(order(DEG_df$padj), 100),]
top100_sigDE_normdf <- data.frame(normalized_counts[(rownames(normalized_counts) %in% rownames(top100_sigDE)),])

# GSEA ##################################################################################################################
# Generate gene list for GSEA
print("We will use the top 100 DE genes as a gene set.")
gene_list = t(top100_sigDE)
names(gene_list) <- colnames(gene_list)
if (any(duplicated(names(gene_list)))){
    warning("Duplicates in gene names")
    gene_list = gene_list[!duplicated(names(gene_list))]
}
gene_list = sort(gene_list, decreasing = TRUE)

# Load pathway data
go_pathways <- gmtPathways("Human_GO_AllPathways_no_GO_iea_April_15_2013_symbol.gmt")
print(paste0("RUNNING GSEA ON ", length(gene_list), " GENES AND ", length(go_pathways), " GO PATHWAYS."))

# Run GSEA analysis
print("Running GSEA...")
gsea_result <- fgsea(
    pathways=go_pathways, 
    stats=gene_list,
    minSize=10,
    maxSize=500,
    nperm=10000
) %>% as.data.frame()
print(paste("Obtained", nrow(gsea_result), "pathways in result."))

# Add 'Enrichment' column to easily separate the pathways in up/down-regulated categories
gsea_result$Enrichment = ifelse(gsea_result$NES > 0, "Up-regulated", "Down-regulated")

# Filter entries by p-value & sort by descending NES
pval = 0.05
sig_gsea_result <- gsea_result %>% 
    #dplyr::filter(padj < !!pval) #%>% 
    arrange(dplyr::desc(NES))
print(paste("Number of signficant gene sets =", nrow(sig_gsea_result)))