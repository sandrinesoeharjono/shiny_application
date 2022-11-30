library(shiny)
library(cluster)
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
            mainPanel(width = 12, strong("Overview"), htmlOutput("general")),
            DT::dataTableOutput("dataframe"),
            tags$footer("sandrinesoeharjono@hotmail.com (2022)")
        ),
        tabPanel(
            title = "PCA",
            icon = icon("circle-nodes"),
            tabPanel(
                "PANEL NAME",
                sidebarPanel(
                    checkboxGroupInput(
                        "pc",
                        "Choose two principal components (PCs) for visualisation",
                        choiceNames = paste0("PC",1:6),
                        selected = c(1,2),
                        choiceValues = 1:6
                    )
                ),
                mainPanel(plotOutput(outputId = "pca")),
                tags$footer("sandrinesoeharjono@hotmail.com (2022)")
            )
        )
    )
)