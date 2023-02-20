# Gene Expression

## Author
Sandrine Soeharjono (sandrinesoeharjono@hotmail.com), 2023.

## Overview
This folder performs basic analyses onto patient transcriptomic data:
1. PCA (principal component analysis);
2. Hierarchical clustering of patients;
3. Differential expression;
4. GSEA (gene set enrichment analysis).

## Data
The publicly available dataset (N=156) used for these analyses originates from [Prat A, Bianchini G, Thomas M, Belousov A et al. (2014)](https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS5027) and can be downloaded from the [Gene Expression Omnibus database (GEO) hosted by NCBI](https://www.ncbi.nlm.nih.gov/geo/download/?acc=GDS5662) as a SOFT file. SOFT (Simple Omnibus Format in Text) is not human-readable, but can be opened and manipulated using the R programming language, as shown in this repository.

## Requirements
The following are the packages required to recreate these analyses and Shiny application:
1. GEOquery:
```R
source("http://bioconductor.org/biocLite.R")
biocLite("GEOquery")
```
