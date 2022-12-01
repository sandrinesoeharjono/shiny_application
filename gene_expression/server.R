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
        strip.text = element_blank()
      )
    })

    # Hierarchical clustering
    output$hierarchy <- renderPlot({
      p <- ggplot(segment(dendro_complete)) + 
        geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) + 
        coord_flip() + 
        scale_y_reverse(expand = c(0.2, 0)) +
        ggtitle("Hierarchical clustering of samples")
      #p <- ggdendrogram(hclust_complete, rotate = FALSE, size = 2)
      ggplotly(p)
    })

    # Text
    output$general_description <- renderUI({
      HTML(
        paste0(
        "Here, I use a <a href='https://www.ncbi.nlm.nih.gov/geo/download/?acc=GDS5662'> publicly available dataset</a>
        from <a href='https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS5027'> Prat A, Bianchini G, Thomas M, Belousov A et al. (2014)</a> 
        to demonstrate examples of gene expression data manipulation and interactive visualization of its results.
        This dataset contains gene expression values for ", n_features, " features from ", n_samples, " samples of the ", organism,
        " species from a ", title, ".<br><br><b>The tabs allow the user to explore the data through:</b><br>- PCA;<br>- Hierarchical clustering;<br>- Differential expression;<br>- Heatmap;<br>- GSEA.",
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
}