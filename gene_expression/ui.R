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
            mainPanel(width = 12, strong("Overview"), htmlOutput("general_description")),
            DT::dataTableOutput("dataframe"),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 2nd panel: PCA
        tabPanel(
            title = "PCA",
            icon = icon("chart-scatter"),
            sidebarPanel(
                checkboxGroupInput(
                    "pc",
                    "Select two principal components (PCs) for visualization:",
                    choiceNames = paste0("PC",1:6),
                    selected = c(1,2),
                    choiceValues = 1:6
                )
            ),
            mainPanel(
                plotOutput(outputId = "pca")
                htmlOutput("pca_description"),
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
                htmlOutput("hierarchy_description"),
                plotOutput(outputId = "hier_silhouette")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        ),
        
        # 4th panel: Differential expression
        tabPanel(
            title = "Differential Expression",
            icon = icon("dna"),
            #sidebarPanel(
            #    HTML('<script type="text/javascript">
            #        $(document).ready(function() {
            #        $("#DownloadButton").click(function() {
            #            $("#Download").text("Loading...");
            #        });
            #        });
            #    </script>
            #    '),
            #    sliderInput(
            #        inputId = "bin_width",
            #        label = "Select the desired bin width:",
            #        min = 1,
            #        max = 10,
            #        value = 1
            #    ),
            #    br(),
            #    radioButtons("cutoff_threshold", "Select the threshold for minimal value cut-off:",
            #    choiceNames = list("None", 500, 1000, 1500),
            #    choiceValues = list(0, 500, 1000, 1500)
            #    )
            #),
            mainPanel(
                htmlOutput("diff_exp_description"),
                #br(),
                #plotOutput(outputId = "raw_exp_histogram"),
                #plotOutput(outputId = "norm_exp_histogram"),
                #br(),
                plotOutput(outputId = "top_de_genes"),
                htmlOutput("top_de_description"),
                plotOutput(outputId = "volcano_plot"),
                htmlOutput("volcano_description"),
                br(),
                htmlOutput("diff_exp_conclusion")
            ),
            tags$footer("Sandrine Soeharjono (2023)")
        )
    )
)