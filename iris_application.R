# Load packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

# Load dataset
data <- read_csv("data/iris.csv")

# Define UI of application
ui <- fluidPage(
    theme = shinytheme("lumen"),
    titlePanel("Iris dataset exploration"),
    sidebarLayout(
        # Side panel: criteria for user selection
        sidebarPanel(
            # Drop-down selector of class
            selectInput(
                inputId = "class",
                label = strong("Class:"),
                choices = unique(data$class)
            ),

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

            # Selector of scatter colour
            selectInput(
                inputId = "colour",
                label = strong("Scatterplot colour:"),
                choices = c("black", "red", "blue", "green", "orange", "purple")
            ),

            # Checkbox selector for addition of overlaid smooth trend line
            checkboxInput(
                inputId = "smoother",
                label = strong("Overlay smooth trend line"),
                value = FALSE
            ),

            # Slider selector for smoother span (to show only if 'smoother' is checked)
            conditionalPanel(
                condition = "input.smoother == true",
                sliderInput(
                    inputId = "f",
                    label = "Smoother span:",
                    min = 0.01,
                    max = 1,
                    value = 0.67,
                    step = 0.01,
                    animate = animationOptions(interval = 100)
                ),
                HTML("Higher values give more smoothness.")
            )
        ),

        # Main panel output: 2 scatterplots + reference
        mainPanel(
            plotOutput(outputId = "sepal_scatterplot", height = "300px"),
            br(),
            plotOutput(outputId = "petal_scatterplot", height = "300px"),
            textOutput(outputId = "desc"),
            tags$a(
                href = "https://archive.ics.uci.edu/ml/datasets/iris",
                title = "Source: Iris dataset (Fisher, 1936)",
                target = "_blank"
            )
        )
    )
)

# Define server function
server <- function(input, output) {
    # Validate the user-selected conditions & subset data accordingly
    selected_trends <- reactive({
        req(input$sepal_length_range, input$sepal_width_range, input$petal_length_range, input$petal_width_range)
        validate(need(!is.na(input$sepal_length_range[1]) & !is.na(input$sepal_length_range[2]), "Error: Please select a range of sepal length."))
        validate(need(input$sepal_length_range[1] < input$sepal_length_range[2], "Error: Minimum value should be smaller than maximum value."))
        validate(need(!is.na(input$sepal_width_range[1]) & !is.na(input$sepal_width_range[2]), "Error: Please select a range of sepal width."))
        validate(need(input$sepal_width_range[1] < input$sepal_width_range[2], "Error: Minimum value should be smaller than maximum value."))
        validate(need(!is.na(input$petal_length_range[1]) & !is.na(input$petal_length_range[2]), "Error: Please select a range of petal length."))
        validate(need(input$petal_length_range[1] < input$petal_length_range[2], "Error: Minimum value should be smaller than maximum value."))
        validate(need(!is.na(input$petal_width_range[1]) & !is.na(input$petal_width_range[2]), "Error: Please select a range of petal width."))
        validate(need(input$petal_width_range[1] < input$petal_width_range[2], "Error: Minimum value should be smaller than maximum value."))
        data %>%
        filter(
            class == input$class,
            sepal_length >= input$sepal_length_range[1] & sepal_length <= input$sepal_length_range[2],
            sepal_width >= input$sepal_width_range[1] & sepal_width <= input$sepal_width_range[2],
            petal_length >= input$petal_length_range[1] & petal_length <= input$petal_length_range[2],
            petal_width >= input$petal_width_range[1] & petal_width <= input$petal_width_range[2]
        )
    })

    # Create sepal scatterplot (length vs width)
    output$sepal_scatterplot <- renderPlot({
        par(mar = c(4, 4, 1, 1))
        plot(
            main = paste0("Sepal properties of ", input$class),
            x = selected_trends()$sepal_length,
            y = selected_trends()$sepal_width,
            type = "p",
            pch = 16,
            xlab = "Sepal length",
            ylab = "Sepal width",
            col = input$colour,
            fg = "#ffffff",
            col.lab = "#000000",
            col.axis = "#000000"
        )
        box(col = "#000000")
        
        # Add smoothing curve if smoother selector is checked
        if(input$smoother){
            smooth_curve <- lowess(
                x = as.numeric(selected_trends()$sepal_length),
                y = selected_trends()$sepal_width,
                f = input$f
            )
            lines(smooth_curve, col = input$colour, lwd = 3)
        }
    })

    # Create petal scatterplot (length vs width)
    output$petal_scatterplot <- renderPlot({
        par(mar = c(4, 4, 1, 1))
        plot(
            main = paste0("Petal properties of ", input$class),
            x = selected_trends()$petal_length,
            y = selected_trends()$petal_width,
            type = "p",
            pch = 16,
            xlab = "Petal length",
            ylab = "Petal width",
            col = input$colour,
            fg = "#ffffff",
            col.lab = "#000000",
            col.axis = "#000000"
        )
        box(col = "#000000")
        
        # Add smoothing curve if smoother selector is checked
        if(input$smoother){
            smooth_curve <- lowess(
                x = as.numeric(selected_trends()$petal_length),
                y = selected_trends()$petal_width,
                f = input$f
            )
            lines(smooth_curve, col = input$colour, lwd = 3)
        }
    })
}

# Create Shiny application
shinyApp(ui = ui, server = server)