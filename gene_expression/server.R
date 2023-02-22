library(shiny)
library(plotly)
library(ggdendro)
library(DT)
library(wesanderson)
library(EnhancedVolcano)

# Import 'data' object from UI
source("data.R")

server <- function(input, output, session) {
    # OVERVIEW PAGE ###############################################################################################
    # Dataset in table format
    output$dataframe <- renderDataTable(
      gexp_data,
      caption = htmltools::tags$caption(
          style = 'caption-side:top; text-align:center; color:#555555; font-weight:bold; font-size: 125%', 'Full Expression Dataset'
      )
    )

    # PCA ###############################################################################################################
    output$pca <- renderPlot({
      ggbiplot(
        pc,
        obs.scale = 1,
        var.scale = 1,
        var.axes = FALSE,
        groups = data@dataTable@columns[["genotype/variation"]],
        # TODO: Use 'groups' in reactive mode for interactive ellipse 
        ellipse = TRUE,
        circle = TRUE,
        ellipse.prob = 0.68
      ) + scale_color_discrete(name = 'Subtype') +
      scale_shape_discrete(name = "Treatment") +
      geom_point(
        aes(
          colour = data@dataTable@columns[["genotype/variation"]],
          shape = data@dataTable@columns[["protocol"]]
        ), size = 2
      ) +
      ggtitle(paste0("Principal Component Analysis of PC", input$pc[1], " vs. PC", input$pc[2])) +
      # TODO: update plot according to PC choice in reactive mode
      theme(
        legend.direction = 'vertical',
        legend.position = 'right',
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555"),
      )
    })

    # HIERARCHICAL CLUSTERING ###############################################################################################
    # Dendrogram
    hclust_obj <- reactive({hclust(dist_mat, method = tolower(input$hclust_method))})
    dendro <- reactive({dendro_data(as.dendrogram(hclust_obj()), type = "rectangle")})
    clusters <- reactive({cutree(hclust_obj(), k = input$n_clusters)})
    clusters_df <- reactive({data.frame(label=names(clusters()), Cluster=factor(clusters()))})
    labeled_samples = reactive({merge(dendro()[["labels"]], clusters_df(), by = "label")})
    output$hierarchy <- renderPlot({
      ggplot(segment(dendro())) + 
      geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) + 
      geom_text(data = labeled_samples(), aes(x, y, label = label, hjust = 0, color = Cluster), size = 3) +
      coord_flip() + 
      scale_y_reverse(expand = c(0.2, 0)) +
      ggtitle(paste0("Hierarchical Clustering of Samples by the ", input$hclust_method, " Method")) +
      ylab("Cluster Distance") +
      xlab("Samples") +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555"),
      )
    })
    
    # DIFFERENTIAL EXPRESSION ###############################################################################################
    # Histogram of raw counts
    output$raw_exp_histogram <- renderPlot({
      selected_data <- subset(tall_raw_gexp, value > input$cutoff_threshold)
      ggplot(selected_data, aes(x = value)) + geom_histogram(binwidth = input$bin_width, color = "black", fill = "#787878") +
      xlab("Raw expression counts") +
      ylab("Number of genes") + 
      ggtitle("Histogram of Raw Expression Values") + 
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555"),
      )
    })
    
    # Histogram of normalized counts
    output$norm_exp_histogram <- renderPlot({
      selected_data <- subset(tall_norm_gexp, value > input$cutoff_threshold)
      ggplot(selected_data, aes(x = value)) + geom_histogram(binwidth = input$bin_width, color = "black", fill = "#787878") +
      xlab("Normalized expression counts") +
      ylab("Number of genes") + 
      ggtitle("Histogram of Normalized Expression Values") + 
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555"),
      )
    })

    # Plot of top 20 differentially-expressed genes
    output$top_de_genes <- renderPlot({
      ggplot(top20_sigDE_normdfl) +
      geom_point(aes(x = gene, y = Normalized_Counts, color = sampletype)) +
      scale_y_log10() +
      xlab("Genes") +
      ylab("log10 Normalized Counts") +
      ggtitle("Top 20 Significant DE Genes by padj value") +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      theme(plot.title = element_text(hjust = 0.5))
    })
    
    # Volcano scatter plot
    output$volcano_plot <- renderPlot({
      EnhancedVolcano(
        res,
        lab = rownames(res),
        x = 'log2FoldChange',
        y = 'pvalue'
      )
    })

    # TEXT (ON ALL PAGES) ###############################################################################################
    output$general_description <- renderUI({
      HTML(
        paste0(
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
      )
    })

    output$pca_description <- renderUI({
      HTML(
        "<b>Description:</b><br>PCA is a linear dimensionality reduction of data to project it onto a lower dimensional space.
        It increases interpretability while minimizing information loss, by creating new uncorrelated variables 
        that successively maximize variance. These principal components (PCs) reduce to solve an eigenvalue/eigenvector 
        problem (<a href='https://royalsocietypublishing.org/doi/10.1098/rsta.2015.0202'>Jolliffe IT & Cadima J, 2016</a>)."
      )
    })

    output$hierarchy_description <- renderUI({
      HTML(
        "<b>Description:</b><br><a href='https://towardsdatascience.com/understanding-the-concept-of-hierarchical-clustering-technique-c6e8243758ec'>Hierarchical clustering</a> 
        is an unsupervised clustering technique used to identify groups in the dataset using the observations' hierarchy. It is an alternative to the supervised
        <a href='https://towardsdatascience.com/understanding-k-means-clustering-in-machine-learning-6a6e67336aa1'>K-means clustering</a> 
        that does NOT require the user to pre-define the number of clusters, <i>k</i>.<br><br>It can be separated into 2 types:<br>
        <b>1) Agglomerative hierarchical clustering</b>: Each data point is originally considered an individual cluster. Similar clusters are then merged together at each 
        iteration until the algorithm is stabilized. This can be thought of as a <i>bottom-up</i> approach.<br>
        <b>2) Divisive hierarchical clustering</b>: All data points begin in one large cluster, which gets split up recursively as the algorithm moves down the hierarchy. 
        This can be thought of as a <i>top-down</i> approach.<br><br>In this application, you can compare 5 different methods of agglomerative clustering using the left-side panel.
        The slider for the number of clusters allows you to select your desired level of granularity."
      )
    })

    output$diff_exp_description <- renderUI({
      HTML(
        "<i><b>PLEASE NOTE: The dataset used in this tab and the following one us from a different source.</i></b><br><br>
        <b>Description:</b><br><a href='https://genomebiology.biomedcentral.com/articles/10.1186/gb-2010-11-10-r106'>Differential gene expression</a> 
        (DGE) is an analysis that compares gene expression values between sample group types. Lists of genes that differ between 2 sample sets are often
        provided by RNA-seq tools, and are then typically normalized using RPKM or FPKM methods for samples-sequencing depth. DGE has been shown to 
        enable the identification of common elements that are significantly enriched in gene classes with particular functions such as protein synthesis, 
        hormone delivery, and morphological plasticity. It can be run using <a href='https://bioconductor.org/packages/release/bioc/html/DESeq2.html'>DESeq2</a>, 
        an R/Bioconductor package."
      )
    })

    output$top_de_description <- renderUI({
      HTML(
        "Above we show the top 20 differentially expressed genes by the adjusted p-value."
      )
    })

    output$vocano_description <- renderUI({
      HTML(
        "A <a href='https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/rna-seq-viz-with-volcanoplot/tutorial.html'>volcano plot</a> 
        is a type of scatterplot that shows statistical significance (P-value) versus magnitude of change (fold change).
        They are commonly used to display the results of RNA-seq or other omics experiments, since they enable a quick visual identification of genes 
        with large fold changes that are also statistically significant; these may be the most biologically significant genes. In a volcano plot, 
        the most upregulated genes are towards the right, the most downregulated genes are towards the left, and the most statistically significant 
        genes are towards the top.<br><br>This plot was generated using the R package 
        <a href='https://bioconductor.org/packages/devel/bioc/vignettes/EnhancedVolcano/inst/doc/EnhancedVolcano.html'>EnhancedVolcano</a>."
      )
    })

    output$diff_exp_conclusion <- renderUI({
      HTML(
        "Due to the large number of genes, (e.g., >20,000 in the human genome), multiple testing correction such as Bonferroni correction is usually applied. 
        Because the number of gene that are differentially expressed between samples may still be high (e.g., >1000), another method to better understand and interpret 
        the meaning of so many gene expression changes is needed. One example is “gene set enrichment” or GSEA (Hung et al., 2012; Subramanian et al., 2005): 
        here, a group of genes that belong to a particular category that are enriched in one sample is compared to another sample. 
        To view this analysis, navigate to the next 'GSEA' tab!"
      )
    })
}