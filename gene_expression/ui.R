library(shiny)
library(DT)
library(wesanderson)
library(shinythemes)

ui <- fluidPage(
    navbarPage(
        title = "Gene Expression Analyses",
        theme = shinytheme("sandstone"),

        # 1st panel: Summary
        tabPanel(
            title = "Summary",
            icon = icon("clipboard"),
            mainPanel(
                width = 12,
                strong("Overview"), 
                htmlOutput(outputId = "general_description")
            ),
            DT::dataTableOutput("orig_data"),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 2nd panel: PCA
        tabPanel(
            title = "PCA",
            icon = icon("circle"),
            sidebarPanel(
                checkboxGroupInput(
                    "pc",
                    "Select two principal components (PCs) for visualization:",
                    choiceNames = paste0("PC", 1:6),
                    selected = c(1, 2),
                    choiceValues = 1:6
                )
            ),
            mainPanel(
                plotOutput(outputId = "pca"),
                br(),
                htmlOutput(outputId = "pca_description"),
                br(),
                plotOutput(outputId = "prop_variance")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 3rd panel: Hierarchical clustering
        tabPanel(
            title = "Hierarchical clustering",
            icon = icon("sitemap"),
            sidebarPanel(
                sliderInput(
                    inputId = "n_clusters",
                    label = "Select the desired number of clusters:",
                    min = 2,
                    max = 15,
                    value = 2
                ),
                br(),
                selectInput(
                    inputId = "hclust_method",
                    label = strong("Select the agglomerative method to use for clustering:"),
                    choices = c("Complete", "Average", "McQuitty", "Median", "Centroid")
                )
            ),
            mainPanel(
                plotOutput(outputId = "hier_ddg"),
                htmlOutput(outputId = "hierarchy_description"),
                br(),
                plotOutput(outputId = "hier_silhouette"),
                htmlOutput(outputId = "silhouette_description")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 4th panel: Expression data distribution
        tabPanel(
            title = "Distribution",
            icon = icon("database"),
            sidebarPanel(
                sliderInput(
                    inputId = "bin_width",
                    label = "Select the desired bin width:",
                    min = 1,
                    max = 10,
                    value = 1
                ),
                br(),
                radioButtons(
                    inputId = "cutoff_threshold",
                    label = "Select the threshold for minimal value cut-off:",
                    choiceNames = list("None", 500, 1000, 1500),
                    choiceValues = list(0, 500, 1000, 1500)
                )
            ),
            mainPanel(
                htmlOutput(outputId = "histogram_description"),
                br(),
                plotOutput(outputId = "raw_exp_histogram"),
                br(),
                plotOutput(outputId = "norm_exp_histogram")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 5th panel: Differential expression
        tabPanel(
            title = "Differential Expression",
            icon = icon("dna"),
            mainPanel(
                DT::dataTableOutput("DE_sig_genes"),
                br(),
                htmlOutput(outputId = "diff_exp_description"),
                br(),
                htmlOutput(outputId = "top_de_description"),
                br(),
                plotOutput(outputId = "top_de_genes"),
                DT::dataTableOutput("top_de_df"),
                br(),
                br(),
                htmlOutput(outputId = "top_100_de_cluster_description"),
                br(),
                plotOutput(outputId = "top_100_de_cluster"),
                br(),
                br(),
                htmlOutput(outputId = "volcano_description"),
                plotOutput(outputId = "volcano_plot"),
                br(),
                htmlOutput(outputId = "diff_exp_conclusion")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        ),

        # 6th panel: Gene Set Enrichment Analysis (GSEA)
        tabPanel(
            title = "GSEA",
            icon = icon("computer"),
            mainPanel(
                htmlOutput(outputId = "gsea_description")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        )
    )
)