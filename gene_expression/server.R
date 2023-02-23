library(shiny)
library(plotly)
library(ggdendro)
library(DT)
library(wesanderson)
library(EnhancedVolcano)
library(factoextra)

# Import data & dashboard descriptions
source("data.R")
source("descriptions.R")

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
    # Only two PCs can be selected at a time
    observe({
      if(length(input$pc) > 2){
          selected = tail(input$pc, 2)
          updateCheckboxGroupInput(session, "pc", selected = selected)
      }
      if(length(input$pc) == 1){
          selected = c(1, ifelse (input$pc == 1, 2, 1))
          updateCheckboxGroupInput(session, "pc", selected = selected)
      }
    })

    # PCA scatterplot
    ### TODO: Use 'groups' in reactive mode for interactive ellipse
    output$pca <- renderPlot({
      ggbiplot(
        pc,
        choices = c(as.numeric(input$pc[1]), as.numeric(input$pc[2])),
        obs.scale = 1,
        var.scale = 1,
        var.axes = FALSE,
        groups = data@dataTable@columns[["genotype/variation"]], 
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
      theme_bw() +
      ggtitle(paste0("Principal Component Analysis of PC", input$pc[1], " vs. PC", input$pc[2])) +
      theme(
        legend.direction = 'vertical',
        legend.position = 'bottom',
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555")
      )
    })

    # HIERARCHICAL CLUSTERING ###############################################################################################
    hier_result <- reactive({hcut(dist_mat, k = input$n_clusters, hc_method = tolower(input$hclust_method))})

    # Dendrogram plot
    output$hier_ddg <- renderPlot({
      fviz_dend(hier_result(), show_labels = FALSE, rect = TRUE) +
      xlab("Samples") +
      ylab("Cluster Distance") + 
      ggtitle(paste0("Hierarchical Clustering of Samples by the ", input$hclust_method, " Method")) +
      theme_bw() +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555")
      )
    })

    # Silhouette width bar plot
    output$hier_silhouette <- renderPlot({
      fviz_silhouette(hier_result()) +
      xlab("Samples") +
      ylab("Silhouette Width") + 
      ggtitle(paste0("Silhouette Width of Hierarchical Clustering by the ", input$hclust_method, " Method")) +
      labs(fill = "Cluster") +
      theme_bw() +
      theme(
        axis.text.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text.y = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555"),
        axis.ticks.x = element_blank()
      )
    })
    
    # DIFFERENTIAL EXPRESSION ###############################################################################################
    # Histogram of raw counts
    output$raw_exp_histogram <- renderPlot({
      selected_data <- subset(tall_raw_gexp, value > input$cutoff_threshold)
      ggplot(selected_data, aes(x = value)) + 
      geom_histogram(binwidth = input$bin_width, color = "black", fill = "red") +
      xlab("Raw Expression Counts") +
      ylab("Number of Genes") + 
      ggtitle("Histogram of Raw Expression Values") + 
      theme_bw() +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555")
      )
    })
    
    # Histogram of normalized counts
    output$norm_exp_histogram <- renderPlot({
      selected_data <- subset(tall_norm_gexp, value > input$cutoff_threshold)
      ggplot(selected_data, aes(x = value)) + 
      geom_histogram(binwidth = input$bin_width, color = "black", fill = "red") +
      xlab("Normalized Expression Counts") +
      ylab("Number of Genes") + 
      ggtitle("Histogram of Normalized Expression Values") + 
      theme_bw() +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text = element_text(size = 11, colour = "#555555"),
        axis.title = element_text(size = 14, colour = "#555555")
      )
    })

    # Plot of top 20 differentially-expressed genes
    output$top_de_genes <- renderPlot({
      ggplot(top20_sigDE_normdfl) +
      geom_point(aes(x = gene, y = Normalized_Counts, color = sampletype)) +
      scale_y_log10() +
      xlab("Genes") +
      ylab("log10 Normalized Counts") +
      ggtitle("Top 20 Significant DE Genes by padj Value") +
      labs(fill = "Sample Type") +
      theme_bw() +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.title = element_text(size = 14, colour = "#555555")
      )
    })
    
    # Volcano scatter plot
    output$volcano_plot <- renderPlot({
      EnhancedVolcano(
        res,
        lab = rownames(res),
        x = 'log2FoldChange',
        y = 'pvalue'
      ) #+ theme_bw +
      #theme(
      #  plot.title = element_text(hjust = 0.5, face = "bold", colour = "#555555", size = 17),
      #  axis.text = element_text(size = 11, colour = "#555555"),
      #  axis.title = element_text(size = 14, colour = "#555555"),
      #)
    })

    # TEXT (ON ALL PAGES) ###############################################################################################
    output$general_description <- renderUI({HTML(gen_description)})

    output$pca_description <- renderUI({HTML(pca_description)})

    output$hierarchy_description <- renderUI({HTML(hier_description)})

    output$diff_exp_description <- renderUI({HTML(deg_description)})

    output$top_de_description <- renderUI({HTML(top_deg_description)})

    output$volcano_description <- renderUI({HTML(vol_description)})

    output$diff_exp_conclusion <- renderUI({HTML(deg_conclusion)})
}