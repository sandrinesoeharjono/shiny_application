# DASHBOARD DESCRIPTIONS/TEXT ########################################

# Overview description
gen_description <- paste0(
    "This dashboard uses a <a href='https://www.ncbi.nlm.nih.gov/geo/download/?acc=GDS5662'> publicly available dataset</a>
    from <a href='https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS5027'> Prat A, Bianchini G, Thomas M, Belousov A et al. (2014)</a> 
    to showcase examples of gene expression data manipulation as well as interactive visualizations of its results.
    This dataset contains gene expression values for ", n_features, " total features (reduced to 22,190 unique HGNC identifiers) from ", n_samples, " samples of the ", organism,
    " species from a ", title, ".<br><br><b>Experimental design:</b><br>Gene expression profiling was performed using RNA from formalin-fixed paraffin-embedded core biopsies from 114 pretreated 
    patients with HER2-positive (HER2+) tumour randomized to receive neoadjuvant doxorubicin/paclitaxel (AT) followed by cyclophosphamide/methotrexate/fluorouracil (CMF), or in the same 
    regimen in combination with trastuzumab for one year. A control court of 42 patients with HER2-negative tumours treated with AT-CMF was also included.
    <br><br><b>The tabs above allow the user to explore the data through:</b><br>- PCA;<br>- Hierarchical clustering;<br>- Differential expression;<br>- GSEA.",
    "<br><br><b>Feel free to explore the raw expression dataset (rows = genes, columns = samples) below:</b><br><br>"
)

# Description of Principal Component Analysis
pca_description <- "<b>Description:</b><br>PCA is a linear dimensionality reduction of data to project it onto a lower dimensional space.
    It increases interpretability while minimizing information loss, by creating new uncorrelated variables 
    that successively maximize variance. These principal components (PCs) reduce to solve an eigenvalue/eigenvector 
    problem (<a href='https://royalsocietypublishing.org/doi/10.1098/rsta.2015.0202'>Jolliffe IT & Cadima J, 2016</a>)."

# Description of hierarchical clustering
hier_description <- "<b>Description:</b><br><a href='https://towardsdatascience.com/understanding-the-concept-of-hierarchical-clustering-technique-c6e8243758ec'>Hierarchical clustering</a> 
    is an unsupervised clustering technique used to identify groups in the dataset using the observations' hierarchy. It is an alternative to the supervised
    <a href='https://towardsdatascience.com/understanding-k-means-clustering-in-machine-learning-6a6e67336aa1'>K-means clustering</a> 
    that does NOT require the user to pre-define the number of clusters, <i>k</i>.<br><br>It can be separated into 2 types:<br>
    <b>1) Agglomerative hierarchical clustering</b>: Each data point is originally considered an individual cluster. Similar clusters are then merged together at each 
    iteration until the algorithm is stabilized. This can be thought of as a <i>bottom-up</i> approach.<br>
    <b>2) Divisive hierarchical clustering</b>: All data points begin in one large cluster, which gets split up recursively as the algorithm moves down the hierarchy. 
    This can be thought of as a <i>top-down</i> approach.<br><br>In this application, you can compare 5 different methods of agglomerative clustering using the left-side panel.
    The slider for the number of clusters allows you to select your desired level of granularity."

# Description of silhouette width
silhouette_description <- "<a href='https://scikit-learn.org/stable/auto_examples/cluster/plot_kmeans_silhouette_analysis.html'> Silhouette width</a> 
    is a widely used index for assessing the fit of individual objects in the classification, as well as the quality of clusters and the entire classification. 
    The silhouette plot displays a measure of how close each point in one cluster is to points in the neighboring clusters and thus provides a way to assess parameters 
    like number of clusters visually. This measure has a range of [-1, 1]. Silhouette coefficients (as these values are referred to as) near +1 indicate that the sample 
    is far away from the neighboring clusters. A value of 0 indicates that the sample is on or very close to the decision boundary between two neighboring clusters and 
    negative values indicate that those samples might have been assigned to the wrong cluster. <br>In this example, the silhouette analysis is used to choose an optimal value 
    for the number of clusters <i>k</i>; try out different <i>k</i> to see which clustering shows the highest average silhouette score (dotted line)!"

# Description of expression histograms
histogram_description <- "<i><b>PLEASE NOTE: The dataset used in this tab and the following one us from a different source.</i></b><br><br>
    Here we show the distribution of gene expression in both raw and normalized datasets."

# Description of differential expression (DEG) using DESeq2
deg_description <- "<b>Description:</b><br><a href='https://genomebiology.biomedcentral.com/articles/10.1186/gb-2010-11-10-r106'>Differential gene expression</a> 
    (DGE) is an analysis that compares gene expression values between sample group types. Lists of genes that differ between 2 sample sets are often
    provided by RNA-seq tools, and are then typically normalized using RPKM or FPKM methods for samples-sequencing depth. DGE has been shown to 
    enable the identification of common elements that are significantly enriched in gene classes with particular functions such as protein synthesis, 
    hormone delivery, and morphological plasticity. It can be run using <a href='https://bioconductor.org/packages/release/bioc/html/DESeq2.html'>DESeq2</a>, 
    an R/Bioconductor package."

# Description of the top differentially-expressed genes from DEG
top_deg_description <- "We show below the top 20 differentially expressed genes by the adjusted p-value."

# Description of a volcano plot
vol_description <- "A <a href='https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/rna-seq-viz-with-volcanoplot/tutorial.html'>volcano plot</a> 
    is a type of scatterplot that shows statistical significance (P-value) versus magnitude of change (fold change).
    They are commonly used to display the results of RNA-seq or other omics experiments, since they enable a quick visual identification of genes 
    with large fold changes that are also statistically significant; these may be the most biologically significant genes. In a volcano plot, 
    the most upregulated genes are towards the right, the most downregulated genes are towards the left, and the most statistically significant 
    genes are towards the top.<br><br>This plot was generated using the R package 
    <a href='https://bioconductor.org/packages/devel/bioc/vignettes/EnhancedVolcano/inst/doc/EnhancedVolcano.html'>EnhancedVolcano</a>."
    
# Description of a conclusion to DEG
deg_conclusion <- "<b>Next steps:</b><br>Due to the large number of genes, (e.g., >20,000 in the human genome), multiple testing correction such as Bonferroni correction is usually applied. 
    Because the number of gene that are differentially expressed between samples may still be high (e.g., >1000), another method to better understand and interpret 
    the meaning of so many gene expression changes is needed. One example is “gene set enrichment” or GSEA (Hung et al., 2012; Subramanian et al., 2005): 
    here, a group of genes that belong to a particular category that are enriched in one sample is compared to another sample. 
    To view this analysis, navigate to the next 'GSEA' tab!"

# Description of GSEA
gsea_description <- "<a href='https://www.gsea-msigdb.org/gsea/index.jsp'> GSEA </a> is computational method that determines whether a set of genes shows 
    statistically significant, concordant differences between two biological states (e.g. phenotypes). It is typically used on mass spectrometry(MS)-based 
    proteomics or Next-Generation Sequencing (NGS) to identify insights into biological processes or pathways underlying a given phenotype."