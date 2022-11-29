# Load packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)
library(DT)

# Load iris dataset
data <- read_csv("iris.csv")

# Define UI of application
ui <- fluidPage(
    tags$style('.container-fluid {background-color: #bddedf}'),
    theme = shinytheme("lumen"),
    titlePanel("Iris Dataset Exploration"),
    # Side panel: criteria for user selection
    sidebarLayout(
        sidebarPanel(
            # Drop-down selector of species
            selectInput(
                inputId = "species",
                label = strong("Species:"),
                choices = unique(data$species)
            ),

            br(),

            # Sepal-specific selectors
            HTML("<b>Sepal:</b>"),

            # Slider selector for sepal length
            sliderInput(
                inputId = "sepal_length_range",
                label = "Range of sepal length:",
                min = min(data$sepal_length),
                max = max(data$sepal_length),
                value = c(min(data$sepal_length), max(data$sepal_length))
            ),

            # Slider selector for sepal width
            sliderInput(
                inputId = "sepal_width_range",
                label = "Range of sepal width:",
                min = min(data$sepal_width),
                max = max(data$sepal_width),
                value = c(min(data$sepal_width), max(data$sepal_width))
            ),

            br(),

            # Petal-specific selectors
            HTML("<b>Petal:</b>"),

            # Slider selector for petal length
            sliderInput(
                inputId = "petal_length_range",
                label = "Range of petal length:",
                min = min(data$petal_length),
                max = max(data$petal_length),
                value = c(min(data$petal_length), max(data$petal_length))
            ),

            # Slider selector for petal width
            sliderInput(
                inputId = "petal_width_range",
                label = "Range of petal width:",
                min = min(data$petal_width),
                max = max(data$petal_width),
                value = c(min(data$petal_width), max(data$petal_width))
            ),

            br(),

            # Selector of scatter colour
            selectInput(
                inputId = "colour",
                label = strong("Scatterplot colour:"),
                choices = c("black", "red", "blue", "green", "orange", "purple")
            ),

            # Checkbox selector for addition of overlaid smooth trend line
            checkboxInput(
                inputId = "smoother",
                label = strong("Overlay 'loess' smooth trend line"),
                value = FALSE
            )
        ),

        # Main panel output: 2 scatterplots + reference
        mainPanel(
            plotOutput(outputId = "sepal_scatterplot", height = "300px"),
            br(), br(),
            plotOutput(outputId = "petal_scatterplot", height = "300px"),
            br(), br(),
            DT::dataTableOutput("dataframe"),
            textOutput(outputId = "desc"),
            tags$a(
                href = "https://archive.ics.uci.edu/ml/datasets/iris",
                title = "Source: Iris dataset (Fisher, 1936)",
                target = "_blank"
            )
        )
    )
)