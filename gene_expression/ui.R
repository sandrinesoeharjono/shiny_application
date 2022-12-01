library(shiny)
library(DT)
library(wesanderson)
library(shinythemes)

shinyUI(
    navbarPage(
        title = strong("Gene Expression Analyses"),
        theme = shinytheme("sandstone"),
        tabPanel(
            "Summary",
            icon = icon("clipboard"),
            mainPanel(width = 12, strong("Overview"), htmlOutput("general_description")),
            DT::dataTableOutput("dataframe"),
            tags$footer("Sandrine Soeharjono (2022)")
        ),
        tabPanel(
            title = "PCA",
            icon = icon("fa-light fa-share-nodes"),
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
                plotOutput(outputId = "pca"),
                htmlOutput("pca_description")
            ),
            tags$footer("Sandrine Soeharjono (2022)")
        ),
        tabPanel(
            title = "Hierarchical clustering",
            icon = icon("fa-solid fa-sitemap"),
            sidebarPanel(
                sliderInput(
                    inputId = "n_clusters",
                    label = "Select the desired number of clusters:",
                    min = 1,
                    max = 20,
                    value = c(1, 20)
                )
            ),
            mainPanel(plotOutput(outputId = "hierarchy")),
            tags$footer("Sandrine Soeharjono (2022)")
        )
    )
)