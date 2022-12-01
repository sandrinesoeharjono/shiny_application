library(shiny)
library(plotly)
library(ggdendro)
library(DT)
library(wesanderson)

# Import 'data' object from UI
source("data.R")

server <- function(input, output, session) {
    # Dataset
    output$dataframe <- renderDataTable(
        gexp_data,
        caption = htmltools::tags$caption(
            style = 'caption-side:top; text-align:center; color:#555555; font-weight:bold; font-size: 125%', 'Full Expression Dataset'
        )
    )

    # PCA
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

    # Hierarchical clustering
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

    # Text
    output$general_description <- renderUI({
      HTML(
        paste0(
        "This dashboard uses a <a href='https://www.ncbi.nlm.nih.gov/geo/download/?acc=GDS5662'> publicly available dataset</a>
        from <a href='https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS5027'> Prat A, Bianchini G, Thomas M, Belousov A et al. (2014)</a> 
        to showcase examples of gene expression data manipulation as well as interactive visualizations of its results.
        This dataset contains gene expression values for ", n_features, " total features (reduced to 22,190 unique HGNC identifiers) from ", n_samples, " samples of the ", organism,
        " species from a ", title, ".<br><br><b>The tabs above allow the user to explore the data through:</b><br>- PCA;<br>- Hierarchical clustering;<br>- Differential expression;<br>- Expression heatmap;<br>- GSEA.",
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
        "<b>Description:</b><br>Hierarchical clustering works by [definition]."
      )
    })
}